#!/bin/bash
#if [ "${DEBUG}" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/FixSymLinks.sh $
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
#I Description:  -- Fix Sym Links
#I
#+------------------------------------------------------------------------=
#I
#I  File Name            : SOURCES
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: FixSymLinks.sh 51 2012-01-17 12:33:18Z dethrophes $
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
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__FixSymLinks_sh__:-}" ]; then
	__FixSymLinks_sh__=1

	SourceCoreFiles_ "FindFiles.sh"
	#########################################################################
	# SHARED PROCEDURES
	#########################################################################
	SortFilesCfg="/mnt/DETH00/media/New/SortCfg.csv"

	function FixupFileName_old2 {
		ReturnString "${1}" | sed -e "s/[[:space:]]+/ /" | tr [:space:] . | sed -e "s/\.*$//"
	}
	function FixupFileName_old1 {
		ReturnString "${1}" | sed -e "s/[[:space:]]\+/ /g" | tr [:space:] . | sed -e "s/\.*$//"
	}
	function FixupFileName {
		ReturnString "${1}" | sed -e "s/[[:space:]]\+/./g" | sed -e "s/\.*$//"
	}
	function FixupFileName1_sub {
		if [ -e "${1}" ]; then
			FileName="${1}"
      return 0
		fi
		FixupFileName1_sub "$(dirname "${1}")" || return $?

		local BaseName="$(basename "${1}")"
		local CFunc
		for CFunc in echo FixupFileName FixupFileName_old1 FixupFileName_old2 ; do
			local TestName="${FileName}/$("${CFunc}" "${BaseName}" || true)"
			if [ -e "${TestName}" ]; then
				FileName="${TestName}"
				return 0
			fi
		done
		return 1
	}
	function FixupFileName1 {
		local FileName
		FixupFileName1_sub "${@}" || return $?
		ReturnString "${FileName}"
		return 0
	}

	function FunctionMapGlobal {
 		local FNAME="${1}"
		local FPath1="$(echo "${FNAME}" | sed -r "s/^\/(\w+)(\/.*)/\1/")"
		local FPath2="$(echo "${FNAME}" | sed -r "s/^\/\w+\/(\w+)//")"
		case "${FPath1}" in
			home)  [ -e "/mnt/${HOSTNAME}/home/${FPath2}" ] && FNAME="/mnt/${HOSTNAME}/home/${FPath2}" ;;
			media) [ -e "/mnt/${HOSTNAME}${FNAME}" ] && FNAME="/mnt/${HOSTNAME}${FNAME}" ;;
		esac
		ReturnString "${FNAME}"
	}
 	#LoadCfgFile SortFilesCfgLines "${SortFilesCfg}"
	declare -ga SortFilesCfgLines
	function FindInSortCfg {
 		local line

		if [ "${#SortFilesCfgLines[@]}" -eq 0 ]; then
			LoadCfgFile SortFilesCfgLines "${SortFilesCfg}" || return $?
		fi
 		for Line in "${SortFilesCfgLines[@]}"; do
			SplitCsvToArray SLine "$Line"
			local Dest="$(CleanFolderName "${SLine[1]}")"/
			local Mask="${SLine[0]}"
			local SrcFile="${1}"
			if [ -n "${Mask}" ]; then
				if [ -d "${Dest}" ]; then
					if echo "${SrcFile}" | grep -iP "${Mask}" >/dev/null ; then 
						ReturnString "${Dest}"
						return 0
					fi
				elif [ -e "${Dest}" ]; then
					sErrorOut "$(gettext "Skipping") \"${Mask}\"" "$(gettext "File not folder") \"${Dest}\""
				else
					sErrorOut "$(gettext "Skipping") \"${Mask}\"" "$(gettext "Folder dowsn\'t exist") \"${Dest}\""
				fi
			fi
		done
		return 1
	}
	function FindInFindFiles {
		#echo LstFilesRaw -F -m 1 "${1}" 1>&2
		IFS=$'\n' eval ' local -a Files=( $(LstFilesRaw -F -m 1 "${1}") )'
		if [ "${#Files[@]}" -eq 1 ]; then
			echo "${Files[0]}"
		elif [ "${#Files[@]}" -gt 1 ]; then
			push_element Files "$(gettext "None of above")"
			PromptSelectElement 0  "$(gettext "Select File")" "" "${Files[@]}"
			local -i RVal=$?
			if [ $((${#Files[@]}-1)) -gt $RVal ]; then
				echo "${Files[$RVal]}"
			fi
		fi
		return 
	}
	function FindInFindFiles_Folder {
		dirname "$(FindInFindFiles  "$(basename "${1}")" || true)" 
	}

	function TestFileType {
		[[ "${1}" =~ '\.(wav|mp3|avi|mkv|ts)$' ]] || return $?
	}
	function FixSymLinks {
		local RealName NewName 
		while [ $# -gt 0 ] ; do
			if [ -h "${1}" ]; then
				RealName="$(readlink "${1}")"
				if [ ! -e "${RealName}" ]; then
					NewName="$(FixupFileName1 "${RealName}" || true )"

					[ ! -e "${NewName}" -a ! -d "${RealName}" ] && NewName="$(FindInSortCfg  "${RealName}" || true)$(basename "${RealName}")"
					[ ! -e "${NewName}" ] && NewName="$(FindInFindFiles  "$(basename "${RealName}")" || true)"



					if [ ! -e "${NewName}" ]; then
						if TestFileType "${1}" || TestFileType "${RealName}" ; then 
							NewName="$(zenity --file-selection --filename="${RealName}" --title="$(basename "${1}") -> $(basename "${RealName}")" || true)"
						else
							NewName="$(zenity --file-selection --directory --filename="${RealName}" --title="$(basename "${1}") -> $(basename "${RealName}")" || true)"
						fi
					fi 
					if [ -e "${NewName}" ]; then
						NewName="$(FunctionMapGlobal "${NewName}")"
						sRunProg rm "${1}"
						sRunProg ln -s "${NewName}" "${1}"
					else
						sErrorOut "Can't Fix" \
						"CurFile  :\"${1}\"" \
						"RealName :\"${RealName}\"" \
						"NewName  :\"${NewName}\""
					fi
				else
					NewName="$(FunctionMapGlobal "${RealName}")"
					if [ "${RealName}" != "${NewName}" ]; then 
						ConsoleStdout LNK : [${RealName}]
						ConsoleStdout LNK4: [${NewName}]
						sRunProg rm "${1}"
						sRunProg ln -s "${NewName}" "${1}"
					fi
				fi	
			elif [ -d "${1}" ]; then
				FixSymLinks "${1}"/*
			fi
			shift
		done
	}

	if [ "${SBaseName2}" = "FixSymLinks.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 51 $')


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

		#########################################################################
		# Argument Processing
		#########################################################################
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
					--FindInFindFiles|--FixupFileName)
						${1:2} "${2}" || true
						exit 
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
		CommonOptionArg ArgFiles "${@}"
		MainOptionArg ArgFiles "${ArgFiles[@]}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		FixSymLinks "${ArgFiles[@]}"

		sNormalExit $?
	fi
fi
