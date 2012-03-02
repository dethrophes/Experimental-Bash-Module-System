#!/bin/bash
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/sedit.sh $
#+=========================================================================
#I   Copyright: Copyright (c) 2002-2009, Kontron Embedded Modules GmbH
#I      Author: John Kearney,                  John.Kearney@kontron.com
#I
#I     License: All rights reserved. This program and the accompanying 
#I              materials are licensed and made available under the 
#I              terms and conditions of the BSD License which 
#I              accompanies this distribution. The full text of the 
#I              license may be found at 
#I              http://opensource.org/licenses/bsd-license.php
#I              
#I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "
#I              AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
#I              ANY KIND, EITHER EXPRESS OR IMPLIED.
#I
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : template.sh
#I  File Location        : bash
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: sedit.sh 51 2012-01-17 12:33:18Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__sedit_SH__:-}" ]; then
	__sedit_SH__=1

	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -f "${ScriptDir}/GenFuncs.sh" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	SourceCoreFiles_ "EditTxtFile.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################

	seditRevision=$(CleanRevision '$Revision: 51 $')
	push_element	ScriptsLoaded "sedit.sh;${seditRevision}"
	if [ "${SBaseName2}" = "sedit.sh" ]; then 
		ScriptRevision="${seditRevision}"

		#########################################################################
		# Usage
		#########################################################################
		function Usage {
  		ConsoleStdout "."
			ConsoleStdout "+=============================================================================="
			ConsoleStdout "I  ${SBaseName2} ................................................... ${ScriptRevision}"
			ConsoleStdout "+=============================================================================="
			ConsoleStdout "I " 
			UsageCommon
			ConsoleStdout "I                                                                                "
			ConsoleStdout "I                                                                                "
			sNormalExit 0
		}


		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers Set_EditTxtFile_Flags Set_sedit_exec_Flags
		#push_element SupportedCLIOptions
		function Set_sedit_exec_Flags {
			local -i PCnt=0
			while [ $# -gt 0 ] ; do
				#echo "3 ${1}"
				case "${1}" in
					--Usage)
						if [ $PCnt -eq 0 ]; then
							ConsoleStdoutN ""
							#ConsoleStdout "I    -h --help                                                                   "
							#ConsoleStdout "I             $(gettext "Display This message")                                  "
						fi
						;;
					--SupportedOptions)
						[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
						break
						;;
					-*)
							sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
					*)
						if [ ! -z "$(type -p "${1}")" ]; then
							PrgName="$(type -p "${1}")" 
							let PCnt+=1
						elif [ ! -z "$(type -p "${1}.sh")" ]; then
							PrgName="$(type -p "${1}.sh")" 
							let PCnt+=1
						fi
						break
						;;
				esac
				let PCnt+=1
				shift
			done
			return ${PCnt}
		}
		MainOptionArg "" "${@}"

		FindTextEditor

		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		Edit "${PrgName}" "${LineNum:-0}" "${LineCol:-0}"

		sNormalExit $?
	fi
fi

