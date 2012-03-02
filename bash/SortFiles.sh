#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/SortFiles.sh $
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
#I  File Name            : template.sh
#I  File Location        : bash
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: SortFiles.sh 53 2012-02-17 13:29:00Z dethrophes $
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
 SourceCoreFiles_ "move.sh" "JobQueue.sh"

if [ -z "${__SortFiles_sh__:-}" ]; then
	__SortFiles_sh__=1



	#########################################################################
	# PROCEDURES
	#########################################################################
	SrcPath="/mnt/DETH00/media/New/"
	SortFilesCfg="${SrcPath}/SortCfg.csv"


	#push_element RequiredDebianPackages moreutils


	declare -gr SortFilesRevision=$(CleanRevision '$Revision: 53 $')
	declare -gr SortFilesDescription="$(gettext "Please Enter a program description here") "
	if [ "${SBaseName2}" = "SortFiles.sh" ]; then 
		ScriptRevision="${SortFilesRevision}"


		function HandleCsvLine {
			#echo "${FUNCNAME}" "${LINENO}" "${@}"
			Dest="$(CleanFolderName "${1}")"/
			Mask="${2}"

			if [ -d "${Dest}" ]; then
				local -a ArgFilesM
				IFS="$NewLine" ArgFilesM=($(echo "${FileLisst}"	| grep -iP "${Mask}" || true)) 
				if [ ${#ArgFilesM[@]} -gt 0 ]; then
					for SrcFile in "${ArgFilesM[@]}"; do
						echo "$(gettext "Move") \"${SrcFile}\" \"${Dest}\"" 
						Move_int "${SrcFile}" "${Dest}" <&3 # && return $?
					done
					#IFS="$NewLine" ArgFiles=($(PrintArray "${ArgFiles[@]}"	| grep -ivP "${Mask}" || true)) 
				fi
			elif [ -e "${Dest}" ]; then
				sErrorOut "$(gettext "Skipping ")\"${Mask}\""
				sErrorOut "$(gettext "file not folder ")\"${Dest}\""
			else
				sErrorOut "$(gettext "Skipping ")\"${Mask}\""
				sErrorOut "$(gettext "Folder doesn't exist ")\"${Dest}\""
			fi
		  return $?
		}

		function StripIgnoreFiles {
			if [ ${ProcessUT} -eq 0 ]; then
				grep -vP '\.(!ut|torrent)$' | FilterLinks None 
			else
				grep -vP '\.(torrent)$' | FilterLinks None 
			fi
		}

		function ListFiles {
			while [ $# -gt 0 ] ; do
				if [ -d "${1}" ]; then
					#-regextype posix-extended
					find -P "${1}/"* -regextype posix-extended -type f -and -not -iregex '.*\.(torrent|url|ini|!ut|swp|txt|rtf|ico|html|msi|cab|inf|exe|reg|rar)$'
				elif [ -f "${1}" ] && ! [ -h "${1}" ]; then
					echo "${1}"
				fi
				shift
			done
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

		ProcessUT=0

		sLogOut "${0}" "${@}"

		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers SetJobQueueFlags
		push_element SupportedCLIOptions --CreateMissingFolder --ProcessUT
		function MainOptionArg {
			local ArrayName="${1}"
			local -i ElCnt
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				ElCnt=$#
				for LCargHandler in "${ModulesArgHandlers[@]}"; do
					"${LCargHandler}" "${@}" || { shift $? ; break ; }
				done
				[ ${ElCnt} -ne $# ] && continue
				case "${1}" in
					--SupportedOptions|--Usage)
						ConsoleStdout
						exit 0
						;;
					--CreateMissingFolder|--CreateMissingFolder_Ask|--quote)
						sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
						CreateMissingFolderMem=${BatchMode}
						${1:2} "${@:2}"
						exit $?
						;;
					--ProcessUT)
						ProcessUT=1
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
		MainOptionArg ArgFiles "${@}"

		CreateMissingFolderMem=${BatchMode}

		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		NewFldr=""

		SetMoveFlags -SSYM --NoRecursive --KeepDestSameSize --UseSourceBigger || true
		SetGenFuncsFlags --HumanReadable || true 

		LoadCfgFile SortFilesCfgLines "${SortFilesCfg}"
		#
		# Create Missing Folders
		#
		if [ "${BatchMode}" -ne 2 ]; then
			for Line in "${SortFilesCfgLines[@]}"; do
				SplitCsvToArray SLine "$Line"
				if ! [ -d "${SLine[1]}" ]; then
					CreateMissingFolder_Ask "$(CleanFolderName "${SLine[1]}")" <&3 || true
				fi
			done
		fi

		#
		# Create List of Files
		#
		[ ${#ArgFiles[@]} -gt 0 ] || ArgFiles=("${SrcPath}") 

		IFS="$NewLine" ArgFiles=($(ListFiles "${ArgFiles[@]}"	| StripIgnoreFiles)) 

		#
		# Process Files
		#
		if [ ${#ArgFiles[@]} -gt 0 ]; then
			FileLisst="$(PrintArray "${ArgFiles[@]}")"
			time for Line in "${SortFilesCfgLines[@]}"; do
				#[ ${#ArgFiles[@]} -eq 0 ] && break
				SplitCsvToArray SLine "$Line"
				[ -n "${SLine[0]}" ] || continue

				HandleCsvLine  "${SLine[1]}" "${SLine[0]}" 
			done
		fi

		sNormalExit 0
	fi
fi
