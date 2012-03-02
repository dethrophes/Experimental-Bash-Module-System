#!/bin/bash +x
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/CreateStorageFolder.sh $
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
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: CreateStorageFolder.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>
#########################################################################
# Source Files
#########################################################################
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

if [ -z "${__CreateStorageFolder_sh__:-}" ]; then
	__CreateStorageFolder_sh__=1

	SourceCoreFiles_ "DiskFuncs.sh" "CreateMasterList.sh" "ScriptWrappers.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################
	AllowedStorageDevicesUUIDS=(
				"f72a5496-f858-4653-8a37-9f845c7d9b2b"    # Drive16
				"2580b9b3-bd34-4fbf-95a5-76059d9b69ef"    # Drive18
				"6620CBF320CBC7EF"												# Drive19
				"72442c2e-7427-4641-9139-24e83bca2c24"    # Drive20
				"5f296f19-014a-4d25-abd2-b08a17126814"    # Drive21
				"39178bcd-65e9-45a7-8860-72e19b543804"    # Drive22
				"6ba868cd-0cdc-4523-9c35-53962de5e0d3"    # Drive23
			)
	AllowedStorageDevicesLabels=(
	#			[0]="Drive16"
			)
	AllowedStorageDevices=(
	#			[0]="sde1"																		# Drive16
			)
	function TestInArray {
			local OptionList
			local CurOption
			[ -z "${2}" ] && return 2
			eval OptionList=("\${${1}[@]}")
			for CurOption in "${OptionList[@]}"; do 
				#[ "${CurOption}" = "${2}" ] && echo 8888 Match "${2}" ${CurOption} 
				[ "${CurOption}" = "${2}" ] && return 0
			done
			return 1
	}
	function TestAllowedDevice {
		sLogOut "${@}"
		[ -z "${1}" ] && return 2
		local DUUID="$(GetDeviceUUID		"${1}")"
		[ ${#AllowedStorageDevicesUUIDS[@]}	 -gt 0 ] &&	TestInArray "AllowedStorageDevicesUUIDS"  "${DUUID}"  && return 0
		local DLabel="$(GetDeviceLabel		"${1}")"                                                                      
		[ ${#AllowedStorageDevicesLabels[@]} -gt 0 ] &&	TestInArray "AllowedStorageDevicesLabels" "${DLabel}" && return 0
		local DName="$(GetDeviceNameAbs		"${1}")"
		[ ${#AllowedStorageDevices[@]}			 -gt 0 ] &&	TestInArray "AllowedStorageDevices"				"${DName}"  && return 0
		sLogOut "$(gettext "Unsupported device for folder creation")" "${1}" "${DUUID}" "${DLabel}" "${DName}"
		return 1
	}
	function SafeMake {
		[ ! -e "${1}" ] && TestAllowedDevice "${1}" && sRunProg mkdir -p "${1}"
	}

	function CreateVirtualBaseFolder {
		local FolderList
		local CMatch
		local CDir
		local UDir
		eval FolderList=("\${${1}[@]}")
		FindExistingPathPart "${2}" >/dev/null
		for CDir in "${FolderList[@]}"; do
			CMatch="$(ls "${CDir}" | tail -1 )"
			if  expr "${UDir}" "<=" "${CMatch}" >/dev/null ; then
				#echo "Match   : ${UDir}  ${CMatch} ${CDir}"
				sRunProg mkdir "${CDir}${UDir}"
				sRunProg ln -s "${CDir}${UDir}" "${3}"

				#RecreateLinks || return $?
	      return 0
			fi
		done
		return 2
	}

	EpisodesDestDirs=( 
					"/mnt/DETH00/media/Drives/Drive19/Episodes/" 
					"/mnt/DETH00/media/Drives/Drive22/Episodes/"   
					"/mnt/DETH00/media/Drives/Drive23/Episodes/"   
					"/mnt/DETH00/media/Drives/Drive21/Episodes/" 
					"/mnt/DETH00/media/Drives/Drive20/Episodes/" 
			)
	FilmsDestDirs=( 
					"/mnt/DETH00/media/Drives/Drive18/Films/" 
			)
	VirtualFolderIndex=(
					"/media/Episodes;EpisodesDestDirs"
					"/media/Films;FilmsDestDirs"
			)
	function CreateMissingFolder {
		local EPart
		local CVirtDesc
		if [ ! -e "${1}" ]; then
			EPart="$(realpath "$(FindExistingPathPart "${1}")")"
			for CVirtDesc in "${VirtualFolderIndex[@]}" ; do
				SplitCsvToArray CurVirtDesc "${CVirtDesc}"

				if [ "${EPart}" = "${CurVirtDesc[0]}" ]; then
					#sDebugOut "${EPart}" "${CurVirtDesc[@]}"
					UpdateVirtualFolder "${CurVirtDesc[0]}" || return $?
					CreateVirtualBaseFolder ${CurVirtDesc[1]} "${1}" "${EPart}"
				fi
			done
			SafeMake "${1}"
		else
			sErrorOut "$(gettext "File same name exists")" "exists : \"${1}\""
		fi
	  [ -d "${1}" ]
	}
 	CreateMissingFolderMem=0
  function CreateMissingFolder_Ask {
		[ -n "${1}" ] || return 0
		[ ! -d "${1}" ] || return 0
		if [ ! -e "${1}" ]; then
			PromptYesNoAll_Alt "${CreateMissingFolderMem}" "$(gettext "Create missing Folder ")" \
											"$(gettext "error: Folder doesn\'t exist")" \
											"$(gettext "error: Nxists :") \"${1}\""       \
											"$(gettext "error: Exists :") \"$(FindExistingPathPart "${1}")\"" || CreateMissingFolderMem=$?
			#[ ${CreateMissingFolderMem} -lt 2 ] && SimpleMkdir "${1}"
			[ ${CreateMissingFolderMem} -ge 2 ] || CreateMissingFolder "${1}" || return $?
		#else
		#	sErrorOut "$(gettext "File same name exists")" "$(gettext "exists :") \"${1}\""
		fi
		return $?
	}
	function Set_CreateStorageFolder_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			#echo "2 ${1}"
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdout "I       --CreateMissingFolder                                                    "
						ConsoleStdout "I             $(gettext "Specify Line Column")                                   "
						ConsoleStdout "I       --SafeMake                                                               "
						ConsoleStdout "I             $(gettext "Specify Line Column")                                   "
					fi
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN "--CreateMissingFolder --SafeMake"
					break
					;;
				--CreateMissingFolder)
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
					shift
					echo CreateMissingFolder "${1}"
					CreateMissingFolder "${1}"
					exit $?
					;;
				--SafeMake)
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
					shift
					echo ${1} "${1}"
					SafeMake "${1}"
					exit $?
					;;
				-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
					;;
				*)
					for COPT in ${SupportedEditors[@]}; do
						if [ "${1}" == "${COPT}" ]; then
							TextEditor=${1}
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

	if [ "${SBaseName2}" = "CreateStorageFolder.sh" ]; then 
		ScriptRevision=$(CleanRevision '${Revision}: 1.10 $')


		# 
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

		sLogOut "${0}" "${@}"
		#
		# Recreate Links
		#
		#RecreateLinks || sError_Exit 7 "$(gettext "RecreateLinks call failed")"


		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers  Set_CreateStorageFolder_Flags
		push_element SupportedCLIOptions 
		MainOptionArg "" "${@}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################




		sNormalExit $?
	fi
fi
