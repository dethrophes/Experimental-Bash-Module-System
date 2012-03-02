#!/bin/bash +x
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/RemoveFollowLink.sh $
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
#I  File Name            : RemoveFollowLink.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 38 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-05 04:16:37 +0100 (Thu, 05 Jan 2012) $
#I  ID                   : $Id: RemoveFollowLink.sh 38 2012-01-05 03:16:37Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__RemoveFollowLink_sh__}" ]; then
	__RemoveFollowLink_sh__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	#[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"
	#[ -f "${ScriptDir}/ScriptWrappers.sh" ] && source "${ScriptDir}/ScriptWrappers.sh"

	#########################################################################
	# Procedures
	#########################################################################
	function FollowSymLinks {
		local CFile="${2}"
		while [ -e "${CFile}" ]; do
			local DName="$(dirname "${CFile}")"
			[ -n "${DName}" ] && cd "${DName}"
			push_element "${1}" "$(pwd)/$(basename "${CFile}")"
			[ -h "${CFile}" ] || break
			CFile="$(readlink "${CFile}")"
		done
	}
	function RemoveFollowLink {
		local -a CFiles
		while [ $# -gt 0 ]; do
			FollowSymLinks CFiles "${1}" ; shift
			local CFile
			for CFile in "${CFiles[@]}"; do
				if [ -h "${CFile}" ]; then
					SimpleDelFile "${CFile}"
				elif [ -d "${CFile}" ]; then
					if PromptYN_Alt "$(gettext "Should I really remove this folder and all contents?") "\
											"${CFile}" ; then
								SimpleRmdirRecursive "${CFile}"
					fi
				elif [ -f "${CFile}" ]; then
					if PromptYN_Alt "$(gettext "Should I really remove this file?") "\
											"${CFile}" ; then
								SimpleDelFile "${CFile}"
					fi
				fi
			done
		done
	}
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	RemoveFollowLinkRevision=$(CleanRevision '$Revision: 38 $')
	if [ "${SBaseName2}" = "RemoveFollowLink.sh" ]; then 
		ScriptRevision="${RemoveFollowLinkRevision}"

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

		SetLogFileName "&1"

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
		RemoveFollowLink "${ArgFiles[@]}"
		#PrintArray "${CFiles[@]}"
		sNormalExit 0
	fi
fi

