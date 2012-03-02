#!/bin/bash
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/testcolors.sh $
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
#I  File Name            : SOURCES
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: testcolors.sh 51 2012-01-17 12:33:18Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__testcolors_SH__}" ]; then
	__testcolors_SH__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"


	#########################################################################
	# PROCEDURES
	#########################################################################


	if [ "${SBaseName2}" = "testcolors.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 51 $')

		function InstallDependencies {
			InstallPackages "${@}"  
		}

		#########################################################################
		# PROCEDURES
		#########################################################################

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
		MainOptionArg ArgFiles  "${ArgFiles[@]}"

		#########################################################################
		# MAIN PROGRAM
#########################################################################
#
		#   This file echoes a bunch of color codes to the 
		#   terminal to demonstrate what's available.  Each 
		#   line is the color code of one forground color,
		#   out of 17 (default + 16 escapes), followed by a 
		#   test use of that color on all nine background 
		#   colors (default + 8 escapes).
		#

		T='gYw'   # The test text

		echo -e "\n                 40m     41m     42m     43m\
		     44m     45m     46m     47m";

		for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
		           '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
		           '  36m' '1;36m' '  37m' '1;37m';
		  do FG=${FGs// /}
		  echo -en " $FGs \033[$FG  $T  "
		  for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
		    do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
		  done
		  echo;
		done
		echo

		      for a in 0 1 4 5 7; do
		              echo "a=$a " 
		              for (( f=0; f<=9; f++ )) ; do
		                      for (( b=0; b<=9; b++ )) ; do
		                              #echo -ne "f=$f b=$b" 
		                              echo -ne "\e[${a};3${f};4${b}m"
		                              echo -ne "\\\\e[${a};3${f};4${b}m"
		                              echo -ne "\e[0m "
		                      done
		              echo
		              done
		              echo
		      done
		      echo

		sNormalExit $?
	fi
fi
