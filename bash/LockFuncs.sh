#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/LockFuncs.sh $
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
#I  File Name            : LockFuncs.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: LockFuncs.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>
[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__LockFuncs_sh__:-}" ]; then
	__LockFuncs_sh__=1

	lockfile="${HOME}/.${SBaseName2}"
	function CreateLockFile_sub {
		( set -o noclobber; echo "${BASHPID}" > "${1}") 2> /dev/null || return $?
	}
	function CreateLockFile {
		if CreateLockFile_sub "${lockfile}" ; then
			return 0
		else
			ErrorOut 1	"Failed to acquire lockfile: \"${lockfile}\"" \
									"Held by PID $(< "${lockfile}")"
			return 1
		fi 
	}
	function WaitPid {
		local -i TimeoutCnt=${2:-100}
		#while ps -p ${1} >/dev/null 2>&1; do
		while kill -0 ${1} >/dev/null 2>&1; do
			[ ${TimeoutCnt} -gt 0 ] || return 1
			sleep 1s
			let TimeoutCnt-=1
		done
		return 0
	}


	function KillProcessEx {
		local Action
		for Action in "${1//;/ }"; do 
			if [[ ${Action} =~ ^(SIG)?(ALRM|HUP|INT|KILL|PIPE|POLL|PROF|TERM|USR1|USR2|VTALRM|STKFLT|PWR|WINCH|CHLD|URG|TSTP|TTIN|TTOU|STOP|CONT|ABRT|FPE|ILL|QUIT|SEGV|TRAP|SYS|EMT|BUS|XCPU|XFSZ)$ ]]; then
				kill -s "${Action}" ${1} || true &>/dev/null
			else 
				! WaitPid ${1} "${Action}" || return 0
			fi
		done
		return 1
	}
	function KillProcess {
		KillProcessEx "${2:-};SIGTERM;2;SIGHUP;2;SIGKILL" "${@}"
	}
	function WaitLockFile {
		local wpid=""
		local wlpid
		local -i TimeoutCnt=${2:-10}

		while [ ${TimeoutCnt} -gt 0 ]; do
			wlpid="${wpid}" wpid="$(cat "${lockfile}" 2>/dev/null  || true)"
			[ -n "${wpid}" ] || return 0
			if [ "${wpid}" != "${wlpid}" ]; then
				sDebugOut "$$ waiting for ${lockfile} held by ${wpid}" 
				TimeoutCnt=${2:-10} # New process has taken lock so reset counter
			fi

			WaitPid "${wpid}" 1 || true
			let TimeoutCnt-=1
		done

		[ -f "${lockfile}" ] && rm -f "${lockfile}" || return 8
	}
	function GetLockFile_Blocking {
		local -i TimeoutCnt=${1:-100}
		while ! CreateLockFile_sub "${lockfile}" ; do
			[ ${TimeoutCnt} -gt 0 ] || return 1
			WaitLockFile ${1:-100}
			let TimeoutCnt-=1
		done
		return 0
	}
	function RemoveLockFile {
		if [ -f "${lockfile}" ];then
			rm --interactive=never "${lockfile}"
		fi
		
	}
	push_element CleanupFunctions RemoveLockFile


	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	LockFuncsRevision=$(CleanRevision '$Revision: 53 $')
	push_element	ScriptsLoaded "LockFuncs.sh;${LockFuncsRevision}"
	if [ "${SBaseName2}" = "LockFuncs.sh" ]; then 
		ScriptRevision="${LockFuncsRevision}"


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
		sLogOut "${0}" "${@}"


		#########################################################################
		# Argument Processing
		#########################################################################
		#push_element ModulesArgHandlers  
		#push_element SupportedCLIOptions 
		MainOptionArg "" "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"
		CreateLockFile
		CreateLockFile
		RemoveLockFile
		RemoveLockFile

		sNormalExit 0
	fi
fi

