#!/bin/bash +x
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
#I  File Name            : CreateMasterList.sh
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

if [ -z "${__CreateMasterList_sh__:-}" ]; then
	__CreateMasterList_sh__=1

	#SourceCoreFiles_ "ScriptWrappers.sh"



	#########################################################################
	# PROCEDURES
	#########################################################################

	function RemoveLnkFilesFromFolder {
		local CurArg
		local file
		for CurArg in "$@"; do
			#echo  CurArg=${CurArg}
			for file in "${CurArg}"/*; do
				#echo file=${file}
				if [ -L "${file}" ]; then
						#echo Linkfile "${file}"; 
						sRunProg rm "${file}"
					#else
						#echo NotLinkfile "${file}"; 
				fi
			done
		done
		return $?
	}
	function LinkIfReal {
		local CPath
		local CFile
		for CPath in "${@:2}"; do
			#echo "${CPath}"
			if [ -d "${CPath}" ]; then
				#ln --symbolic --target-directory="${1}" "${CPath}/"*
				#echo "${CPath}"
				for CFile in "${CPath}/"* ; do
					local Dst="${1}/$(basename "${CFile}")" 
					if [ -d "${CFile}" ]; then
						if [ -e "${Dst}" ]; then
							sErrorOut "File already Exists" "$(cd "$(dirname "${1}")"; pwd)/$(basename "${CFile}")"
						else
							sRunProg ln --symbolic "${CFile}" "${1}"
						fi
					#else
					#	echo ln --symbolic "${CFile}" "${1}"
					fi
				done
			else
				sErrorOut "Missing Folder" "${CPath}"
			fi
		done
		return $?
	}
	DrivesPath="../Drives"
	EpisodesMap=(
					"${DrivesPath}/Drive19/Episodes"
					"${DrivesPath}/Drive20/Episodes"
					"${DrivesPath}/Drive21/Episodes"
					"${DrivesPath}/Drive22/Episodes"
					"${DrivesPath}/Drive23/Episodes"
		)
	pushd "/mnt/DETH00/media/Films"  >/dev/null
	FilmsMap=(
					"${DrivesPath}/Drive18/Films" 
					"${DrivesPath}/Drive18/Films/00.Collections/"*
		)
	popd   >/dev/null
	FictionPath="../../Fiction"
	DuneMap=(
					"${FictionPath}/Frank.Herbert"
					"${FictionPath}/Brian.Herbert.&.Kevin.J..Anderson"
		)
	VirtFolderMap=( 
					"/mnt/DETH00/media/Episodes;EpisodesMap"
					"/mnt/DETH00/media/Films;FilmsMap"
					"/mnt/DETH00/media/aBooks/Series/Dune;DuneMap"
		)
	function UpdateVirtualFolder_sub {
		if [ -w "${1}" ]; then 
			RemoveLnkFilesFromFolder "${1}"

			pushd "${1}" >/dev/null
			LinkIfReal "."  "${@:2}"                                                                  
			popd >/dev/null
		fi
	}
	function UpdateVirtualFolder {
		local -a CurDesc
		if [ $# -gt 0 ]; then
			for Val in "${@}"; do
				Val="$(PrintArray "${VirtFolderMap[@]}" | grep "$(realpath "${Val}");" || true)"
				SplitCsvToArray CurDesc "${Val}"
				eval UpdateVirtualFolder_sub '"${CurDesc[0]}" "${'"${CurDesc[1]}"'[@]}"'
			done
		else
			for Val in "${VirtFolderMap[@]}"; do
				SplitCsvToArray CurDesc "${Val}"
				eval UpdateVirtualFolder_sub '"${CurDesc[0]}" "${'"${CurDesc[1]}"'[@]}"'
			done
		fi
	}

fi
if [  -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "CreateMasterList.sh" ]; then 
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

	#########################################################################
	# Argument Processing
	#########################################################################
	MainOptionArg ArgFiles  "${@}"
	ArgFiles[0]=""


	#########################################################################
	# MAIN PROGRAM
	#########################################################################
	if CreateLockFile ; then 
		UpdateVirtualFolder "${ArgFiles[@]}"
		RemoveLockFile
	fi


	sNormalExit 0
fi


