#!/bin/bash +x
#if [ "${DEBUG}" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/oc.sh $
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
#I  File Name            : oc.sh
#I  File Location        : bash
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: oc.sh 51 2012-01-17 12:33:18Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh"
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
SourceCoreFiles_ "DiskFuncs.sh" 

if [ -z "${__oc_SH__:-}" ]; then
	__oc_SH__=1

	#Browser=""
	SupportedBrowsers=(s3dfm gentoo emelfm2 bsc mc gnome-commander tuxcmd krusader tuxcmd krusader tkdesk thunar xfe worker vifm xfm nautilus pcmanfm rox-filer dolphin konqueror)


	#########################################################################
	# PROCEDURES
	#########################################################################
	function FindBrowser {
		
		if [ -z "${Browser:-}" ]; then Browser="$(which dolphin					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which thunar					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which nautilus					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which tkdesk					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which tuxcmd					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which emelfm2					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which bsc   					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which pcmanfm					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which krusader					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which xfe    					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which vifm   					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which rox-filer					)"; fi
		#if [ -z "${Browser}" ]; then Browser="$(which s3dfm  					)"; fi
		#if [ -z "${Browser}" ]; then Browser="$(which ttfm   					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which xfm						)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which gollem					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which gnome-commander			)"; fi
		#if [ -z "${Browser}" ]; then Browser="$(which xnc    					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which mc     					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which worker 					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which gentoo 					)"; fi
		if [ -z "${Browser}" ]; then Browser="$(which konqueror					)"; fi
		if [ -z "${Browser}" ]; then sError_Exit 4 "$(gettext "No Browser Found")"; fi
		return 0
	}

	function OptionalArg {
		if [ ! -z "${1}" ]; then
			echo "${2}${1}${3}"
		fi
	}


	#########################################################################
	# Open Browser
	#########################################################################
	function Browse {
		local LFNAME="$(CleanFolderName "${1}")"
		local LFNAME2="$(CleanFolderName "${2:-}")"

		local LANAME
		if [ -f "${1}" ]; then 
			LANAME="${LFNAME}/$(basename "${1}")"
		else
			LANAME="${LFNAME}"
		fi
		pushd "${LFNAME}" >/dev/null 2>&1
		local ProgArgs=("${Browser}" )
		case "$(basename "${Browser}")" in
			s3dfm)
				push_element ProgArgs --s3d-url "${LFNAME}" 
				;;
			gentoo)
				push_element ProgArgs -1 "${LFNAME}" 
				if [ -n "${LFNAME2}" ]; then
					push_element ProgArgs -2 "${LFNAME2}" 
				fi
				;;
			emelfm2)
				push_element ProgArgs "--one=${LFNAME}" 
				if [ -n "${LFNAME2}" ]; then
					push_element ProgArgs "--two=${LFNAME2}" 
				fi
				;;
			bsc)
				push_element ProgArgs "-lp=${LFNAME}" 
				if [ -n "${LFNAME2}" ]; then
					push_element ProgArgs "-rp=${LFNAME2}" 
				fi
				;;
			#mc)
			#	;;
			gnome-commander)
				push_element ProgArgs "--start-left-dir=${LFNAME}" 
				if [ -n "${LFNAME2}" ]; then
					push_element ProgArgs "--start-right-dir=${LFNAME2}" 
				fi
				;;
			tuxcmd|krusader)
				push_element ProgArgs "--left=${LFNAME}" 
				if [ -n "${LFNAME2}" ]; then
					push_element ProgArgs "--right=${LFNAME2}" 
				fi
				;;
			tkdesk)
				push_element ProgArgs -startdir "${LFNAME}" 
				;;
			vifm|worker)
				push_element ProgArgs "${LFNAME}" 
				if [ -n "${LFNAME2}" ]; then
					push_element ProgArgs "${LFNAME2}" 
				fi
				;;
			thunar|xfe)
				push_element ProgArgs "${LFNAME}" 
				;;
			xfm)
				push_element ProgArgs "-filemgr" 
				;;
			nautilus|pcmanfm)
				push_element ProgArgs ..no-desktop "${LFNAME}" 
				;;
			rox-filer)
				if [ -f "${LANAME}" ]; then 
					push_element ProgArgs "--show=${LANAME}" 
				else
					push_element ProgArgs "--dir=${LFNAME}" 
				fi
				;;
			dolphin|konqueror)
				if [ -f "${LANAME}" ]; then 
					push_element ProgArgs --select "${LANAME}" 
				else
					push_element ProgArgs "${LFNAME}" 
				fi
				;;
			#*)
			#	;;
		esac
		#sRunProg "${ProgArgs[@]}" &
		"${ProgArgs[@]}" &
		popd  &>/dev/null
		return $?
	}



	function Set_oc_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			#echo "2 ${1}"
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdout "I    ${SupportedBrowsers[*]}                                                     "
						ConsoleStdout "I             $(gettext "Supported Editor Options")                              "
					fi
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN "${SupportedBrowsers[*]}"
					break
					;;
				*)
					for COPT in ${SupportedBrowsers[@]}; do
						if [ "${1}" == "${COPT}" ]; then
							Browser=${1}
							AskInstall "${Browser}"
							let PCnt+=1
							shift
							break 2
						fi
					done
					break
					;;
			esac
			let PCnt+=1
			shift
		done
		return ${PCnt}
	}


	declare -gr ocFileRevision=$(CleanRevision '$Revision: 51 $')
	declare -gr ocFileDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "oc.sh;${ocFileRevision};${ocFileDescription}"
	if [ "${SBaseName2}" = "oc.sh" ]; then 
		declare -gr ScriptRevision=${ocFileRevision}


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
		push_element ModulesArgHandlers  Set_oc_Flags 
		#push_element SupportedCLIOptions 
		
		MainOptionArg ArgFiles "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		FindBrowser

		if [ -z "${ArgFiles[0]:-}" ]; then
			Browse "$(pwd)"
		elif [ -e "${ArgFiles[0]}" ]; then
			Browse "${ArgFiles[0]}" "${ArgFiles[1]:-}"
		else
			sError_Exit 1 "$(gettext "non existent file") \"${ArgFiles[0]}\""
		fi

		sNormalExit $?
	fi
fi




