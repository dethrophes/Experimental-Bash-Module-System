/*
 * VTParse - an implementation of Paul Williams' DEC compatible state machine parser
 *
 * Author: Joshua Haberman <joshua@reverberate.org>
 *
 * This code is in the public domain.
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "vtparse.h"

void vtparse_init(vtparse_t *parser, vtparse_callback_t cb)
{
    parser->state                 = VTPARSE_STATE_GROUND;
    parser->intermediate_chars[0] = '\0';
    parser->num_params            = 0;
    parser->ignore_flagged        = 0;
    parser->cb                    = cb;
}

static void do_action(vtparse_t *parser, vtparse_action_t action, char ch)
{
    /* Some actions we handle internally (like parsing parameters), others
     * we hand to our client for processing */

    switch(action) {
        case VTPARSE_ACTION_PRINT:
        case VTPARSE_ACTION_EXECUTE:
        case VTPARSE_ACTION_HOOK:
        case VTPARSE_ACTION_PUT:
        case VTPARSE_ACTION_OSC_START:
        case VTPARSE_ACTION_OSC_PUT:
        case VTPARSE_ACTION_OSC_END:
        case VTPARSE_ACTION_UNHOOK:
        case VTPARSE_ACTION_CSI_DISPATCH:
        case VTPARSE_ACTION_ESC_DISPATCH:
            parser->cb(parser, action, ch);
            break;

        case VTPARSE_ACTION_IGNORE:
            /* do nothing */
            break;

        case VTPARSE_ACTION_COLLECT:
        {
            /* Append the character to the intermediate params */
            int num_intermediate_chars = strlen((char*)parser->intermediate_chars);

            if(num_intermediate_chars + 1 > MAX_INTERMEDIATE_CHARS)
                parser->ignore_flagged = 1;
            else
                parser->intermediate_chars[num_intermediate_chars++] = ch;

            break;
        }

        case VTPARSE_ACTION_PARAM:
        {
            /* process the param character */
            if(ch == ';')
            {
                parser->num_params += 1;
                parser->params[parser->num_params-1] = 0;
            }
            else
            {
                /* the character is a digit */
                int current_param;

                if(parser->num_params == 0)
                {
                    parser->num_params = 1;
                    parser->params[0]  = 0;
                }

                current_param = parser->num_params - 1;
                parser->params[current_param] *= 10;
                parser->params[current_param] += (ch - '0');
            }

            break;
        }

        case VTPARSE_ACTION_CLEAR:
            parser->intermediate_chars[0] = '\0';
            parser->num_params            = 0;
            parser->ignore_flagged        = 0;
            break;

        default:
            fprintf(stderr, "Internal error, unknown action %d", action);
    }
}

static void do_state_change(vtparse_t *parser, state_change_t change, char ch)
{
    /* A state change is an action and/or a new state to transition to. */

    vtparse_state_t  new_state = STATE(change);
    vtparse_action_t action    = ACTION(change);


    if(new_state)
    {
        /* Perform up to three actions:
         *   1. the exit action of the old state
         *   2. the action associated with the transition
         *   3. the entry actionk of the new action
         */

        vtparse_action_t exit_action = EXIT_ACTIONS[parser->state];
        vtparse_action_t entry_action = ENTRY_ACTIONS[new_state];

        if(exit_action)
            do_action(parser, exit_action, 0);

        if(action)
            do_action(parser, action, ch);

        if(entry_action)
            do_action(parser, entry_action, 0);

        parser->state = new_state;
    }
    else
    {
        do_action(parser, action, ch);
    }
}

void vtparse(vtparse_t *parser, unsigned char *data, int len)
{
    int i;
    for(i = 0; i < len; i++)
    {
        unsigned char ch = data[i];

        /* If a transition is defined from the "anywhere" state, always
         * use that.  Otherwise use the transition from the current state. */

        state_change_t change = STATE_TABLE[VTPARSE_STATE_ANYWHERE][ch];

        if(!change)
            change = STATE_TABLE[parser->state][ch];

        do_state_change(parser, change, data[i]);
    }
}

