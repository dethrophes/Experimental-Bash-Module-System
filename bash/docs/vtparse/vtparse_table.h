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
 *I Description: Auto Created for vtparse_table.h
 *I
 *+-------------------------------------------------------------------------
 *I
 *I  File Name            : vtparse_table.h
 *I  File Location        : Experimental-Bash-Module-System/bash/docs/
 *I                         vtparse
 *I
 *+=========================================================================
 *</KHeader>
 */
typedef enum {
   VTPARSE_STATE_ANYWHERE = 0,
   VTPARSE_STATE_CSI_ENTRY = 1,
   VTPARSE_STATE_CSI_IGNORE = 2,
   VTPARSE_STATE_CSI_INTERMEDIATE = 3,
   VTPARSE_STATE_CSI_PARAM = 4,
   VTPARSE_STATE_DCS_ENTRY = 5,
   VTPARSE_STATE_DCS_IGNORE = 6,
   VTPARSE_STATE_DCS_INTERMEDIATE = 7,
   VTPARSE_STATE_DCS_PARAM = 8,
   VTPARSE_STATE_DCS_PASSTHROUGH = 9,
   VTPARSE_STATE_ESCAPE = 10,
   VTPARSE_STATE_ESCAPE_INTERMEDIATE = 11,
   VTPARSE_STATE_GROUND = 12,
   VTPARSE_STATE_OSC_STRING = 13,
   VTPARSE_STATE_SOS_PM_APC_STRING = 14,
   VTPARSE_STATE_SS2_ENTRY = 15,
   VTPARSE_STATE_SS3_ENTRY = 16,
   VTPARSE_STATE_SS3_PARAM = 17,
} vtparse_state_t;

typedef enum {
   VTPARSE_ACTION_CLEAR = 1,
   VTPARSE_ACTION_COLLECT = 2,
   VTPARSE_ACTION_CSI_DISPATCH = 3,
   VTPARSE_ACTION_ESC_DISPATCH = 4,
   VTPARSE_ACTION_ESC_EXECUTE = 5,
   VTPARSE_ACTION_EXECUTE = 6,
   VTPARSE_ACTION_HOOK = 7,
   VTPARSE_ACTION_IGNORE = 8,
   VTPARSE_ACTION_OSC_END = 9,
   VTPARSE_ACTION_OSC_PUT = 10,
   VTPARSE_ACTION_OSC_START = 11,
   VTPARSE_ACTION_PARAM = 12,
   VTPARSE_ACTION_PRINT = 13,
   VTPARSE_ACTION_PUT = 14,
   VTPARSE_ACTION_SS2_DISPATCH = 15,
   VTPARSE_ACTION_SS3_DISPATCH = 16,
   VTPARSE_ACTION_UNHOOK = 17,
} vtparse_action_t;

typedef unsigned short state_change_t;
extern state_change_t STATE_TABLE[18][256];
extern vtparse_action_t ENTRY_ACTIONS[18];
extern vtparse_action_t EXIT_ACTIONS[18];
extern char *ACTION_NAMES[18];
extern char *STATE_NAMES[18];

