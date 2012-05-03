#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
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
#I  File Name            : DiskFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -n "${ScriptDir:-}"	] || ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh"
	else
		echo "# " >&2
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# " >&2
		exit 7
	fi
fi

if [ -z "${__DISKFUNCS_SH__:-}" ]; then
	__DISKFUNCS_SH__=1

	#########################################################################
	# PROCEDURES
	#########################################################################
	function GetDfLine {
		ReturnString $(LANGUAGE=en df --block-size=1 "$(FindExistingPathPart "${1}")" | grep -vE '^Filesystem|tmpfs|cdrom')
	}
	function GetDeviceName {
		GetDfLine "${1}" | awk '{ print $1 }'
	}
	function GetDeviceNameShort {
		GetDeviceName "${1}"  | sed -e 's/\/dev\///'
	}
	function GetDeviceNameAbs {
		realpath "$(GetDeviceName "${1}")" | sed -e 's/\/dev\///'
	}
	function GetFreeDiskSize {
		GetDfLine "${1}" | awk '{ print $2 }'
	}
	function GetFreeDiskUsed  {
		GetDfLine "${1}" | awk '{ print $3 }'
	}
	function GetFreeDiskSpace {
		GetDfLine "${1}" | awk '{ print $4 }'
	}
	function GetMountPoint {
		GetDfLine "${1}" | awk '{ print $6 }'
	}
	function GetFolderFileName {
		echo "$(ls -l "${1}" 2>/dev/null | grep "$(GetDeviceNameAbs "${2}")" | awk '{ print $8 }')"
	}
	function GetDeviceUUID {
		GetFolderFileName /dev/disk/by-uuid/ "${1}"
	}
	function GetDeviceLabel {
		GetFolderFileName /dev/disk/by-label/ "${1}"
	}
	function GetDeviceIds {
		GetFolderFileName /dev/disk/by-id/ "${1}"
	}
	function GetDevicePath {
		GetFolderFileName /dev/disk/by-path/ "${1}"
	}

	function CheckSameDevice {
		TestEmptyArg "${1}" "Path1" || return $?
		TestEmptyArg "${2}" "Path2" || return $?
		[ "$(GetDeviceName "${1}")" = "$(GetDeviceName "${2}")" ] || { ReturnString $? ; return 0; }
		ReturnString 0
		return 0
	}

	if [ "${SBaseName2}" = "DiskFuncs.sh" ]; then 
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
		MainOptionArg ArgFiles  "${ArgFiles[@]}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"
		TestFuncs=( "GetDfLine" "GetDeviceName" "GetDeviceNameShort" "GetDeviceNameAbs" "GetFreeDiskSize" "GetFreeDiskUsed" "GetFreeDiskSpace" "GetMountPoint" 
								"GetDeviceUUID" "GetDeviceLabel" "GetDeviceIds" "GetDevicePath")
		#TestData=( "/media" "/home" "/media/Drives/Drive22")
		TestData=( "/media" )


		for CId in "${TestData[@]}"; do 
			for CFunc in "${TestFuncs[@]}"; do 
				Cnt=
				CResults=($(eval ${CFunc} \"${CId}\"))
				for CResult in "${CResults[@]}"; do
					if [ -z "${Cnt}" ]; then 
						sDebugOut "$(printf "%-25s %-25s = %-25s" "${CFunc}" "${CId}" "${CResult}")"
						Cnt=1
					else
						sDebugOut "$(printf "%-25s %-25s = %-25s" "   ||" "   ||" "${CResult}")"
					fi
				done
			done
		done
		sNormalExit 0
	fi
fi

