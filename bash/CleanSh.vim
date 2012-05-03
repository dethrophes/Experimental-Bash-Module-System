"<KHeader>
"+=========================================================================
"I  Project Name: Scripts
"+=========================================================================
"I   Copyright: Copyright (c) 2004-2012, John Kearney
"I      Author: John Kearney,                  dethrophes@web.de
"I
"I     License: All rights reserved. This program and the accompanying 
"I              materials are licensed and made available under the 
"I              terms and conditions of the BSD License which 
"I              accompanies this distribution. The full text of the 
"I              license may be found at 
"I              http://opensource.org/licenses/bsd-license.php
"I              
"I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN '
"I              AS IS' BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
"I              ANY KIND, EITHER EXPRESS OR IMPLIED.
"I
"I Description: Auto Created for CleanSh.vim
"I
"+-------------------------------------------------------------------------
"I
"I  File Name            : CleanSh.vim
"I  File Location        : Experimental-Bash-Module-System/bash
"I
"+=========================================================================
"</KHeader>
:g/$\(\w\+\)/s//${\1}/
:g/${\(Revision\|Rev\|HeadURL\|Author\|Date\|Id\)}:/s//$\1:/
:g/awk\s\+\'{\s*print\s*${\(\d\)}\s*}/s//awk \'{ print $\1 }/
