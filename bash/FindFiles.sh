#!/bin/bash
#set -o errexit 
#set -o errtrace 
set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/FindFiles.sh $
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
#I  File Name            : FindFiles.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: FindFiles.sh 53 2012-02-17 13:29:00Z dethrophes $
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

if [ -z "${__FindFiles_sh__:-}" ]; then
	__FindFiles_sh__=1

	SourceCoreFiles_ "JobQueue.sh" "SigFuncs.sh"

	IndexFolders=(
		"/mnt/DETH00/media/Drives/Drive16"
		"/mnt/DETH00/media/Drives/Drive17"
		"/mnt/DETH00/media/Drives/Drive18"
		"/mnt/DETH00/media/Drives/Drive19"
		"/mnt/DETH00/media/Drives/Drive20"
		"/mnt/DETH00/media/Drives/Drive21"
		"/mnt/DETH00/media/Drives/Drive22"
		"/mnt/DETH00/media/Drives/Drive23"
	)
	function GrabOutput {
	  echo "${@:2}" ">${1}"
	  "${@:2}" >"${1}"
	}
	function IndexFolder {
		find "${1}" -type f -regextype posix-extended \! -regex "${IgnoreFiles}" >"${2}" 2>/dev/null || true
	  return 0
	}
	function IndexFolders {
		local CFolder
		local CFile
		InitJobQueue
		#SetMaxJobCnt "${MaxJobs}"
		for CFolder in "${IndexFolders[@]}"; do 
			CFile="${CFolder}/file.lst"
			if [ -w "${CFolder}" ]; then
				AddJobNice 10 IndexFolder "${CFolder}" "${CFile}"
				#IndexFolder "${CFolder}" "${CFile}"
			fi
		done
		CloseJobQueue Wait
	}
	function LstFilesRaw {
		local CFolder
		local CFile
		if [ -n "${1}" ]; then
			for CFolder in "${IndexFolders[@]}"; do 
				CFile="${CFolder}/file.lst"

				[ -f "${CFile}" ] && grep "${@}" "${CFile}"
			done
		fi
	}
	function LstFiles {
		if [ -n "${1}" ]; then
			LstFilesRaw --ignore-case --perl-regexp --regexp="${1}" "${@:2}" 
		fi
	}
	function LstCatagory {
		if [ -n "${1}" ]; then
		  LstFilesRaw -F "${1}" | grep --ignore-case --perl-regexp --regexp="$2"
		fi
	}
	function LstaBooks {
		LstCatagory "/aBooks/" "${1}"
	}
	function LstFilms {
		LstCatagory "/Films/" "${1}"
	}
	function LstManga {
		LstCatagory "/Manga/" "${1}"
	}
	function LstEpisodes {
		LstCatagory "/Episodes/" "${1}"
	}
 	CreateMissingFolderMem=0
	function AskForEach {
		local CLine
		while read CLine; do
			[ -z "${CLine}" ] && continue
			PromptYesNoAll_Alt "${AskForEachMem}" "$(gettext "Should I List ?") "\
					"${CLine}" >&2 <&3 
			AskForEachMem=$?
			[ ${AskForEachMem} -lt 2 ] && echo "${CLine}"
		done
	}

	if [ "${SBaseName2}" = "FindFiles.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 53 $')

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

		[ -t 1 ] && sLogOut "${0}" "$@"

		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers SetJobQueueFlags
		FindFuncs=( "--FindFile LstFiles" "--FindaBooks LstaBooks" "--FindFilms LstFilms" 
		"--FindManga LstManga" "--FindEpisode LstEpisodes" )
		push_element SupportedCLIOptions --IndexFiles ${FindFuncs[@]% *}
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				for LCargHandler in "${ModulesArgHandlers[@]}"; do
					${LCargHandler} "${@}" || shift $? && continue 
				done
				case "${1}" in
					'--IndexFiles')
						IndexFolders
						;;
					--*)
					  for CFunc in "${FindFuncs[@]}"; do 
						CFuncDesc=( ${CFunc} )
						if [ "${CFuncDesc[0]}" = "${1}" ]; then
						  sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ")"
						  shift
						  "${CFuncDesc[1]}" "${1}" | AskForEach
						  exit
						fi
					  done
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
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
		MainOptionArg ArgFiles  "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		#echo "###############################################"
		#echo "# ${SBaseName2} $(gettext "Test Module")"
		#echo "###############################################"

		#IndexFolders

		sNormalExit 0
	fi
fi

