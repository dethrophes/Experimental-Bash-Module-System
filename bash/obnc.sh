#!/bin/bash +x
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I  Project Name: Scripts
#+=========================================================================
#I   Copyright: Copyright (c) 2004-2012, John Kearney
#I      Author: John Kearney,                  dethrophes@web.de
#I
#I     License: All rights reserved. This program and the accompanying 
#I              materials are licensed and made available under the 
#I              terms and conditions of the BSD License which 
#I              accompanies this distribution. The full text of the 
#I              license may be found at 
#I              http://opensource.org/licenses/bsd-license.php
#I              
#I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN '
#I              AS IS' BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
#I              ANY KIND, EITHER EXPRESS OR IMPLIED.
#I
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : obnc.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__oc_SH__}" ]; then
	__oc_SH__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"
	[ -f "${ScriptDir}/ScriptWrappers.sh" ] && source "${ScriptDir}/ScriptWrappers.sh"

	#ConsoleName=""
	SupportedConsoles=(gnome-terminal tilda konsole sakura guake evilvte xiterm pterm lxterminal lxterm koi8rxterm uxterm xterm gtkterm kterm eterm stterm wterm mrxvt mrxvt-mini mrxvt-cjk yakuake roxterm Eterm)


	#########################################################################
	# PROCEDURES
	#########################################################################
	function FindConsoleName {
		if [ -z "${ConsoleName:-}" ]; then ConsoleName="$(which gnome-terminal		)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which konsole				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which sakura 				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which guake  				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which yakuake				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which mrxvt					)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which mrxvt-mini			)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which mrxvt-cjk				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which evilvte				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which xiterm 				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which pterm  				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which lxterm    			)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which lxterminal			)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which koi8rxterm			)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which uxterm				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which xterm					)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which gtkterm				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which kterm  				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which stterm 				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which wterm  				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which tilda  				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which roxterm				)"; fi
		if [ -z "${ConsoleName}" ]; then ConsoleName="$(which Eterm					)"; fi
		if [ -z "${ConsoleName}" ]; then sError_Exit 4 "$(gettext "No ConsoleName Found")"; fi
		return 0
	}



	function OptionCmdArgs {
		if [ $1 -gt 0 ]; then
			ReturnString "$2"
		fi
	}
	#########################################################################
	# Open ConsoleName
	#########################################################################
	function OpenConsole {
		local LFNAME="$(CleanFolderName "${1}")"
		local LANAME
		if [ -f "${1}" ]; then 
			LANAME="${LFNAME}/$(basename "${1}")"
		else
			LANAME="${LFNAME}"
		fi
		shift
		pushd "${LFNAME}" >/dev/null 2>&1
		local ProgArgs=("${ConsoleName}" )
		case "$(basename "${ConsoleName}")" in
			tilda)
				push_element ProgArgs --working-directory="${LFNAME}"
				;;
			gnome-terminal)
				push_element ProgArgs --working-directory="${LFNAME}"
				if [ $# -gt 0 -a -n "${1:-}" ]; then
					push_element ProgArgs -x "${@}"
				fi
				;;
			lxterminal)
				push_element ProgArgs --working-directory="${LFNAME}"
				if [ $# -gt 0 -a -n "${1:-}" ]; then
					push_element ProgArgs -e "${@}"
				fi
				;;
			konsole)
				push_element ProgArgs --workdir="$LFNAME"
				if [ $# -gt 0 -a -n "${1:-}" ]; then
					push_element ProgArgs -e "${@}"
				fi
				;;
			#gtkterm|yakuake|stterm)
			#	;;
			#sakura|lxterm|koi8rxterm|uxterm|xterm|kterm|wterm|mrxvt|mrxvt-mini|mrxvt-cjk|ETerm)
			#	;;
			roxterm)
				push_element ProgArgs --directory="${LFNAME}"
				if [ $# -gt 0 -a -n "${1:-}" ]; then
					push_element ProgArgs -e "${@}"
				fi
				;;
			#*)
			#	;;
		esac
		sRunProg "${ProgArgs[@]}" &
		popd  >/dev/null 2>&1
		return $?

	}



	if [ "${SBaseName2}" = "obnc.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 64 $')

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


		sLogOut "${0}" "$@"
		File1=""
		CmdArg=""

		#########################################################################
		# Argument Processing
		#########################################################################
		push_element SupportedCLIOptions -c --exec "${SupportedConsoles[@]}"
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
					-c|--exec)
						sTestEnoughArgs $# 1 "$1 $(gettext "Requires Arg ")"
						shift
						CmdArg=( "${@}" )
						break
						;;
					-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
					*)
						for COPT in "${SupportedConsoles[@]}"; do
						if [ "${1}" == "${COPT}" ]; then
								ConsoleName="${1}"
								AskInstall "${ConsoleName}"
								break
							fi
						done
						if [ "${1}" != "${ConsoleName:-}" ]; then 
							if [ -e  "${1}" ]; then 
								if [ -z  "${File1}" ]; then 
									File1="${1}"
								else
									sError_Exit 5 "$(gettext "Supports a max of 1 Folders") \"${1}\""
								fi
							else
								sError_Exit 5 "$(gettext "Unsupported Arg") \"${1}\""
							fi
						fi
						push_element "${ArrayName}" "${1}"
						;;
				esac
				shift
			done
		}
		CommonOptionArg ArgFiles "${@}"
		[ ${#ArgFiles[@]} -gt 0 ] && MainOptionArg ArgFiles "${ArgFiles[@]}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		FindConsoleName

		if [ -z "${File1}" ]; then
			OpenConsole "$(pwd)" "${CmdArg[@]}"
		elif [ -e "${File1}" ]; then
			OpenConsole "${File1}" "${CmdArg[@]}"
		else
			sError_Exit 1 "$(gettext "non existent file") \"${File1}\""
		fi

		sNormalExit $?
	fi
fi




