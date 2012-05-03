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
#I Description: 
#I              File Name            : JobQueue.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : JobQueue.sh
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

if [ -z "${__JobQueue_sh__:-}" ]; then
	__JobQueue_sh__=1

	#SourceCoreFiles_ "ScriptWrappers.sh"

	#########################################################################
	# Procedures
	#########################################################################
	function SetJobQueueFlags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdout "I    -j --jobs <Job Count>                                                       "
						ConsoleStdout "I             $(gettext "Specify number of process to use")                      "
						ConsoleStdout "I       --CloseQueue                                                             "
						ConsoleStdout "I             $(gettext "Close Job Queue Daemon")										            "
						ConsoleStdout "I       --ListQueuedJobs                                                         "
						ConsoleStdout "I             $(gettext "List Currently Queued Jobs")			                      "
						ConsoleStdout "I       --GetQueueVersion                                                        "
						ConsoleStdout "I             $(gettext "Get Current Queued Version")			                      "
						ConsoleStdout "I       --StartJobQueue                                                          "
						ConsoleStdout "I             $(gettext "Start Job Queue Daemon    ")			                      "
						ConsoleStdout "I       --RestartJobQueue                                                        "
						ConsoleStdout "I             $(gettext "Restart Job Queue Daemon ")			                        "
						ConsoleStdout "I       --JobQueueInfo                                                           "
						ConsoleStdout "I             $(gettext "List stats about running daemon ")			                  "
					fi
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN "--jobs" --CloseQueue --ListQueuedJobs --GetQueueVersion --StartJobQueue --RestartJobQueue --JobQueueInfo
					break
					;;
				'--JobQueueInfo') JobQueueInfo "$(tty)" ; exit ;;
				'--StartJobQueue') InitJobQueue  ; exit ;;
				'--RestartJobQueue') CloseJobQueue Wait  "$(tty)" && InitJobQueue
					exit 
					;;
				'--CloseQueue') CloseJobQueue "$(tty)" ; exit ;;
				'--ListQueuedJobs') ListQueuedJobs  "$(tty)" ; exit ;;
				'--GetQueueVersion') GetJobQueueVersion  "$(tty)" ;  exit ;;
				'--jobs'|'-j')
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ")"
					shift && let PCnt+=1
					MaxJobs="${1}"
					SetMaxJobCnt "${MaxJobs}"
					;;
				*)
					break
					;;
			esac
			let PCnt+=1
			shift
		done
		return ${PCnt}
	}

	CNiceLevel="$(nice)"
	JobQueuePipe="${TMP}/${SBaseName}_JobQueue.pipe"
	function EncodeArgs {
		IFS=$'\v' eval echo \"\${*}\" 
	}
	function WriteFifoTimeout {
		local ReturnValue=$(${@:3} >${1} && echo 0 &  KillProcess ${2:-1} $! || fg  &>/dev/null )
		return ${ReturnValue:-1}
	}
	function SendEncodedArgs {
		sDebugOut "${@}"
		local lockfile="${1}.lock"
		local ELevel=0
		[ -p "${1}" ] || return 1
		GetLockFile_Blocking 10 || return 2
		WriteFifoTimeout "${1}" 2 EncodeArgs "${@:2}" || ELevel=3
		RemoveLockFile || true
		return ${ELevel}
	}
	function DecodedArgs {
		IFS=$'\v' read -ra ${1} <<< "${2}"
	#	IFS=$'\v'  eval ${1}=\( \${2} \)
	}
	function RecieveCmd {
		DecodedArgs "${1}" "$(head -1 "${2}")"
	}
	function SendJobQueueCmd {
		local ELevel=0
		#sLogOut "${@:2}" 
	 SendEncodedArgs "${JobQueuePipe}" "${@}"|| ELevel=$?
	 if [ ${ELevel} -eq 3  ]; then 
		InitJobQueue Force || return $?
		SendEncodedArgs "${JobQueuePipe}" "${@}"|| ELevel=$?
	 fi
	 return ${ELevel}
	}
  function CloseJobQueue {
		#sLogOut "${@}"
		SendJobQueueCmd "Exit" "${@}" || return $?
		if [ "${1:-}" = "Wait" ]; then
			while [ -p "${JobQueuePipe}" ]; do
				sleep 1s
			done
		fi
		return 0
	}
  function SetMaxJobCnt {
		#sLogOut "${@}"
		SendJobQueueCmd "SetMaxJobCnt" "${@}"
	}
  function AddJobNice {
		#sLogOut "${@}"
		SendJobQueueCmd "AddJob" "${@}"
	}
  function GetJobQueueVersion {
		if [ -c "${1:-}" -o -f "${1:-}" ];then
			SendJobQueueCmd "Version" "${1}"
		else
			local TmpPipe="${BASHPID}.PIPE"
			local -a Answer
			CreatePipe "${TmpPipe}"
			SendJobQueueCmd "Version" "${TmpPipe}"
			RecieveCmd Answer "${TmpPipe}"
			RemovePipe "${TmpFile}"
		fi
	}
  function AddJob {
		#sLogOut "${@}"
		AddJobNice  ${CNiceLevel} "${@}"
	}
  function ListQueuedJobs {
		#sLogOut "${@}"
		SendJobQueueCmd ListQueuedJobs "${@}"
	}
  function JobQueueInfo {
		#sLogOut "${@}"
		SendJobQueueCmd Info "${@}"
	}
  function RemovePipe {
		[ -e "${1}" ] || return 0
		local lockfile="${1}.lock"
		if GetLockFile_Blocking 10 ; then
			#sLogOut "$(EncodeArgs "${@:2}")" 
			if [ -e "${1}" ]; then rm --interactive=never "${1}" || exit 5 ; fi
			RemoveLockFile || return $?
			return 0
		fi
		return 1 

	}
  function CreatePipe {
		[ -p "${1}" ] && return 0
		local lockfile="${1}.lock"
		if GetLockFile_Blocking 10 ; then
			#sLogOut "$(EncodeArgs "${@:2}")" 
			if [ -e "${1}" ]; then rm --interactive=never "${1}" || exit 5 ; fi
			mkfifo "${1}" || exit 3
			RemoveLockFile || return $?
			return 0
		fi
		return 1 

	} 
	function ArgsOutPutWrapper {
		local Dest=${1} && shift
		if [ -z "§{Dest}" ]; then
			CreateEscapedArgList "${@}"
		elif [ -p "§{Dest}" ]; then
			SendEncodedArgs "§{Dest}"  "${@}"	
		else
			CreateEscapedArgList "${@}" >"§{Dest}"
		fi
	}
	function OutPutWrapper {
		local Dest=${1} && shift
		if [ -z "§{Dest}" ]; then
			"${@}"
		else
			"${@}" >"§{Dest}"
		fi
	}
  function InitJobQueue {
		[ "${1:-}" != "Force" -a -p "${JobQueuePipe}" ] && return 0
		CreatePipe "${JobQueuePipe}" || exit
		#sLogOut "${@}"

		function JobWrapper {
			#sLogOut "${@}"
			#sLogOut Launching Job "${@:4}"
			[ ${CNiceLevel} -lt ${2} ] && renice ${2} ${BASHPID} >/dev/null
			sRunProg "${@:3}"
			SendJobQueueCmd "JobFinished" $? "${@}"
		}
		function JobQueue {
			local -a JobQueue
			local -i AddPtr=0
			local -i JobCnt=0
			local -i RunPtr=0
			local -i MaxJobs=2
			local -i ReqExit=0
			local -ir MaxQueue=200-1
			local -a Cmd

			sLogOut "Starting ${BASHPID} $(whoami) ${SBaseName}(${ScriptRevision}) , JobQueue.sh(${JobQueueRevision})"

			function CleanExit {
					RemovePipe "${JobQueuePipe}"
					sLogOut "Exiting $$ $(whoami) ${SBaseName}(${ScriptRevision}) , JobQueue.sh(${JobQueueRevision})"
					exit
			}
			function TestExit {
				if [ ${ReqExit} -eq 1 ] && [ ${JobCnt} -eq 0 ]; then
					exit
				fi
			}
			#trap CloseJobQueue		SIGTERM
			trap CleanExit  EXIT 
			function RunJob {
				#sLogOut "${@}"
				while [ ${JobCnt} -lt ${MaxJobs} ] && [ ${RunPtr} -ne ${AddPtr} ] ; do
					local -a Job
					DecodedArgs Job "${JobQueue[${RunPtr}]}"
					#sLogOut "${Job[@]}"
					unset JobQueue[${RunPtr}]
					let JobCnt+=1
					JobWrapper  "${RunPtr}" "${Job[@]}" &
					RunPtr=$(IncQueuePtr ${RunPtr})
				done
			}
			echo Hello
			while true; do 
				CreatePipe "${JobQueuePipe}" || exit
				while read Cmd  ; do
					#sDebugOut "${Cmd}"
					RunJob
					DecodedArgs Cmd "${Cmd}"
					#sLogOut "Cmd=" "${Cmd[@]}"

					case "${Cmd[0]}" in 
						Version)
							ArgsOutPutWrapper "${Cmd[1]}" "${SBaseName}=${ScriptRevision}" "JobQueue=${JobQueueRevision}"
							;;
						SetMaxJobCnt)
							echo MaxJobs="${Cmd[1]}"
							MaxJobs="${Cmd[1]}"
							RunJob
							;;
						Exit)
							ReqExit=1
							;;
						AddJob)
							if [ $(IncQueuePtr ${AddPtr}) -ne ${RunPtr} ] ; then
								#sDebugOut "${Cmd[@]:1}"
								JobQueue[${AddPtr}]="$(EncodeArgs "${Cmd[@]:1}")"
								#sLogOut "JobQueue[${AddPtr}]=${JobQueue[${AddPtr}]}"
								AddPtr=$(IncQueuePtr ${AddPtr})
							else
								sErrorOut "Job Queue Full Skipping Cmd" "$(CreateEscapedArgList "${Cmd[@]}")"
							fi
							RunJob
							;;
						JobFinished)
							#sLogOut Job Ended "${Cmd[@]}"
							(( JobCnt-- ))
							RunJob
							;;
						Info)
							ArgsOutPutWrapper "${Cmd[1]}" "RunPtr=${RunPtr}" "AddPtr=${AddPtr}" "JobCnt=${JobCnt}" \
									"MaxJobs=${MaxJobs}" "MaxQueue=${MaxQueue}" "MaxQueue=${MaxQueue}" "ReqExit=${ReqExit}"
							;;
						ListQueuedJobs)
							#sLogOut Job Ended "${Cmd[@]}"
							function lcl_LQJ {
								local Cnt=${RunPtr}
								local Cmd
								while [ ${Cnt} -ne ${AddPtr} ]; do 
									DecodedArgs Cmd "${JobQueue[${Cnt}]}"
									echo -n "[${Cnt}]"
									CreateEscapedArgList "${Cmd[@]}"
									echo  ""
									Cnt=$(IncQueuePtr ${Cnt}) 
								done
							}
							OutPutWrapper "${Cmd[1]:-}" lcl_LQJ
							;;
						*)
							if [ -n "${Cmd}" ]; then
								sErrorOut "Unknown Command: ${Cmd}"
							fi
							;;
					esac 
				done < "${JobQueuePipe}"
				TestExit
			done 
		}
		JobQueue &
	}

  function IncQueuePtr {
		if [ ${1} -eq ${MaxQueue} ]; then
			ReturnString 0
		else
			let value=${1}+1
			ReturnString $value
		fi
	}
  function DecQueuePtr {
		if [ ${1} -eq 0 ]; then
			ReturnString ${MaxQueue}
		else
			let value=${1}-1
			ReturnString ${value}
		fi
	}









	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	JobQueueRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "JobQueue.sh;${JobQueueRevision}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "JobQueue.sh" ]; then 
	ScriptRevision="${JobQueueRevision}"

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
	push_element ModulesArgHandlers  SetJobQueueFlags Set_JobQueue_exec_Flags
	push_element SupportedCLIOptions $(ListFunctionsAsArgs "${0}")
	function Set_JobQueue_exec_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdoutN ""
						#ConsoleStdout "I    -h --help                                                                   "
						#ConsoleStdout "I             $(gettext "Display This message")                                  "
					fi
					;;
				--*)
					FuncName="${1:2}"
					if [ "$(type -t "${FuncName}")" = "function" ]; then
						shift
						"${FuncName}" "${@}"
						exit 
					else
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
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
					break
					;;
			esac
			let PCnt+=1
			shift
		done
		return ${PCnt}
	}
	MainOptionArg "" "${@}"

	#########################################################################
	# MAIN PROGRAM
	#########################################################################

	echo "###############################################"
	echo "# ${SBaseName2} $(gettext "Test Module")"
	echo "###############################################"
	function TestProcess {
		#sLogOut "${@}"
		echo "${FUNCNAME}" "${LINENO}" $$ ${BASHPID} $(nice) "${@}"
		sleep 1s
		return 0
	}
	InitJobQueue
	#for CArg in Proc1 Proc2 Proc3 Proc4 Proc5 Proc6 Proc7 Proc8 Proc9 Proc10 Proc11 Proc12 ; do
	for CArg in "Proc 1" "Proc 2" ; do
		echo AddJobNice 10 TestProcess "${CArg}" || exit $?
		AddJobNice 10 TestProcess "${CArg}" || exit $?
	done
	ListQueuedJobs
	CloseJobQueue 

	sNormalExit 0
fi

