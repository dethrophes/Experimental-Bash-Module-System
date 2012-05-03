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
 *I Description: Auto Created for vtparse.h
 *I
 *+-------------------------------------------------------------------------
 *I
 *I  File Name            : vtparse.h
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

#include "vtparse_table.h"

#define MAX_INTERMEDIATE_CHARS 2
#define ACTION(state_change) (state_change & 0x0F)
#define STATE(state_change)  (state_change >> 4)

struct vtparse;

typedef void (*vtparse_callback_t)(struct vtparse*, vtparse_action_t, unsigned char);

typedef struct vtparse {
    vtparse_state_t    state;
    vtparse_callback_t cb;
    unsigned char      intermediate_chars[MAX_INTERMEDIATE_CHARS+1];
    char               ignore_flagged;
    int                params[16];
    int                num_params;
    void*              user_data;
} vtparse_t;

void vtparse_init(vtparse_t *parser, vtparse_callback_t cb);
void vtparse(vtparse_t *parser, unsigned char *data, int len);

