/*
 *<KHeader>
 *+=========================================================================
 *I  Project Name: Scripts
 *+=========================================================================
 *I   Copyright: Copyright (c) 2004-2012, John Kearney
 *I      Author: John Kearney,                  dethrophes@web.de
 *I
 *I     License: All rights reserved. This program and the accompanying 
 *I              materials are licensed and made available under the 
 *I              terms and conditions of the BSD License which 
 *I              accompanies this distribution. The full text of the 
 *I              license may be found at 
 *I              http://opensource.org/licenses/bsd-license.php
 *I              
 *I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN '
 *I              AS IS' BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
 *I              ANY KIND, EITHER EXPRESS OR IMPLIED.
 *I
 *I Description: Auto Created for vtparse_test.c
 *I
 *+-------------------------------------------------------------------------
 *I
 *I  File Name            : vtparse_test.c
 *I  File Location        : Experimental-Bash-Module-System/bash/docs/
 *I                         vtparse
 *I
 *+=========================================================================
 *</KHeader>
 */
/*
 * VTParse - an implementation of Paul Williams' DEC compatible state machine parser
 *
 * Author: Joshua Haberman <joshua@reverberate.org>
 *
 * This code is in the public domain.
 */

#include <stdio.h>
#include "vtparse.h"

void parser_callback(vtparse_t *parser, vtparse_action_t action, unsigned char ch)
{
    int i;

    printf("Received action %s, char=0x%02x\n", ACTION_NAMES[action], ch);
    printf("Intermediate chars: '%s'\n", parser->intermediate_chars);
    printf("%d Parameters:\n", parser->num_params);
    for(i = 0; i < parser->num_params; i++)
        printf("\t%d\n", parser->params[i]);
    printf("\n");
}

int main()
{
    unsigned char buf[1024];
    int bytes;
    vtparse_t parser;

    vtparse_init(&parser, parser_callback);

    while(1) {
        bytes = read(0, buf, 1024);
        vtparse(&parser, buf, bytes);
    }
}

