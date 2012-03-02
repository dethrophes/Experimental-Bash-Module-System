#!/bin/bash +x
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/svndiff.sh $
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
#I Description: 
#I
#+------------------------------------------------------------------------=
#I
#I  File Name            : svndiff.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 37 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-01 01:50:56 +0100 (Sun, 01 Jan 2012) $
#I  ID                   : $Id: svndiff.sh 37 2012-01-01 00:50:56Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__svndiff_sh__}" ]; then
	__svndiff_sh__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	#[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"
	#[ -f "${ScriptDir}/ScriptWrappers.sh" ] && source "${ScriptDir}/ScriptWrappers.sh"

	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	svndiffRevision=$(CleanRevision '$Revision: 37 $')
	if [ "${SBaseName2}" = "svndiff.sh" ]; then 
		ScriptRevision="${svndiffRevision}"

		function InstallDependencies {
			InstallPackages "${@}"  
		}

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

		#SetLogFileName "&1"

		sLogOut "${0}" "$@"

		#########################################################################
		# Argument Processing
		#########################################################################
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
					-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
					*)
						push_element "${ArrayName}" "${1}"
						;;
				esac
				shift
			done
		}
		CommonOptionArg ArgFiles "${@}"
		MainOptionArg ArgFiles "${ArgFiles[@]}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		# Configure your favorite diff program here.
		DIFF="/usr/bin/vimdiff"

		# Subversion provides the paths we need as the sixth and seventh
		# parameters.
		LEFT=${6}
		RIGHT=${7}

		# Call the diff command (change the following line to make sense for
		# your merge program).
		"$DIFF" "$LEFT" "$RIGHT"

		# Return an errorcode of 0 if no differences were detected, 1 if some were.
		# Any other errorcode will be treated as fatal.

		sNormalExit 
	fi
fi

