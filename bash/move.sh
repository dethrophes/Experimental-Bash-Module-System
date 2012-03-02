#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/move.sh $
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
#I  ID                   : $Id: move.sh 53 2012-02-17 13:29:00Z dethrophes $
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
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
SourceCoreFiles_ "DiskFuncs.sh" "CreateStorageFolder.sh" "SigFuncs.sh" "FixSymLinks.sh"
if [ -z "${__move_sh__:-}" ]; then
	__move_sh__=1

	#+=======+=============================
	#| Value | Description
	#+=======+=============================
	#|   0   | Create No Links
	#+-------+-----------------------------
	#|   1   | Move ArgFiles and then create 
	#|       | a links in old positions 
	#+-------+-----------------------------
	#|   2   | Create links at Destination
	#+-------+-----------------------------
	declare -gi SymLnk=0
	declare -gi MoveRecursive=1
	declare -gi KeepDestSameSize=0
	declare -gi UseSourceBigger=0
	declare -gi CreateMissingFolder=0
	declare -gi AutoMergeFolders=0


	#########################################################################
	# PROCEDURES
	#########################################################################

	function SetMoveFlags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
					  pConsoleStdout "I    -h --SSYM                                                                   "
						ConsoleStdout "I             $(gettext "Display This message")                                  "
					fi
					break
					;;
				-SSYM|--SSYM)
					SymLnk=1
					;;
				-DSYM|--DSYM)
					SymLnk=2
					;;
				-MSSYM|--MSSYM)
					SymLnk=3
					;;
				--NOSYM)
					SymLnk=0
					;;
				--NoRecursive)
					MoveRecursive=0
					;;
				-R|--Recursive)
					MoveRecursive=1
					;;
				--UseSourceBigger)
					UseSourceBigger=1
					;;
				--KeepDestSameSize)
					KeepDestSameSize=1
					;;
				--CreateMissingFolder)
					CreateMissingFolder=1
					CreateMissingFolderMem=1
					;;
				--AutoMergeFolders)
					AutoMergeFolders=1
					;;
				--SupportedOptions)
					if [ ${PCnt} -eq 0 ]; then
						ConsoleStdoutN "--AutoMergeFolders --NoRecursive -R --Recursive --MSSYM --SSYM --DSYM --KeepDestSameSize --UseSourceBigger --CreateMissingFolder"
					fi
					break
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

	function Move_int {   
		#sLogOut "$@"
		local Dst="${@:$#:1}"
		local SrcName
		local -i SrcSize
		local DstName
		local -i DstSize
		local -i SameDeviceMove
		local ELevel=0
			
		for SrcName in "${@:1:(($#-1))}"; do
			DstName="${Dst}/$(basename "${SrcName}" .!ut )"
			if [ ! -w "${Dst}" ]; then
				scErrorOut "$(gettext "Destination Folder not modifiable ")\"${Dst}\""
				return 9                         Discovery
			fi 
			#echo "CheckSameDevice \"${SrcName}" \"${DstName}" $(CheckSameDevice "${SrcName}" "${DstName}")"

			SameDeviceMove=$(CheckSameDevice "${SrcName}" "${DstName}")

			if [ -d "${SrcName}" ]; then
				if [ $MoveRecursive -eq 0 ]; then 
					sLogOut "$(gettext "Directory"): \"${SrcName}\""
				else
					if [ ${SameDeviceMove} -eq 0 ] && [ ${SymLnk} -eq 3 ] && [ ! -e "${DstName}" ]; then
						sRunProg mv  "${SrcName}" "${DstName}"
						GrabELevel ELevel $?
					else
						CreateMissingFolder "${DstName}" || { GrabELevel ELevel $? ; continue ; } 
						Move_int "${SrcName}/"* "${DstName}" 
						GrabELevel ELevel $?
						[ ${SymLnk} -ne 2 ] && [ ${SymLnk} -ne 1 ] && SimpleRmdir "${SrcName}"
					fi
				fi
			elif [ -f "${SrcName}" ]; then
 				if [[ ${SrcName} =~ ${SumFileMask} ]]; then shift ; continue ; fi
				#sLogOut "$(gettext "File"): \"${SrcName}\"
				DstFreeSpace=$(GetFreeDiskSpace "${Dst}")
				SrcSize=$(GetFileSize "${SrcName}")

				if [ -e "${DstName}" ]; then
					if [ -h "${SrcName}" ]; then
						scErrorOut "$(gettext "Link"): \"${SrcName}\""
						continue
					fi
					if [ "$(realpath "${DstName}")" == "$(realpath "${SrcName}")" ]; then
						sErrorOut "$(gettext "Destination and source same file ")"   \
											"$(gettext "Source      "): \"${SrcName}\""       \
											"$(gettext "Destination "): \"${DstName}\""
            GrabELevel ELevel 8
						continue
					fi
					sErrorOut "\"${DstName}\" $(gettext "already Exists")"
					DstSize=$(GetFileSize "${DstName}")
					if [ ${SrcSize} -gt ${DstSize} ]; then
						if [ ${UseSourceBigger} -eq 0 ]; then 
							PromptYN_Alt "$(gettext "Replace destination file? ")" \
												"$(gettext "Error: Filesize mismatch ")($(PrintSize ${SrcSize}) != $(PrintSize ${DstSize}))"    \
												"$(gettext "Error: Source File Larger than destination file")"  || { GrabELevel ELevel $? ; continue ; } 
						fi

						sLogOut "$(gettext "Removing partial duplicate destination file ")\"${DstName}\""
						SimpleDelFile "${DstName}"
						DstFreeSpace=$(GetFreeDiskSpace "${Dst}")
					elif [ ${SrcSize} -lt ${DstSize} ]; then
						sErrorOut "$(gettext "Filesize mismatch ")($(PrintSize ${SrcSize}) != $(PrintSize ${DstSize}))" \
																							 "$(gettext "Source File Smaller than destination file")"
            GrabELevel ELevel 8
						continue
					else
						if [ ${KeepDestSameSize} -eq 0 ]; then 
							PromptYN_Alt "$(gettext "Keep existing file and remove source? ")" \
									"$(gettext "\"${DstName}\" already Exists")" || { GrabELevel ELevel $? ; continue ; } 
						fi 

						SimpleDelFile "${SrcName}"
						SrcSize=0
						sLogOut "$(gettext "Removing Duplicate Source File \"${SrcName}\"")"
					fi
				fi

				if [ ${SameDeviceMove} -ne 0 -a ${SrcSize} -gt ${DstFreeSpace} ] ; then
					sErrorOut "$(gettext "Can't move ")\"$(basename "${SrcName}")\"" \
										"$(gettext "Not enough space on device ")\"$(GetMountPoint "${Dst}")\""  \
										"SrcSize     =$(PrintSize ${SrcSize})"             \
										"DstFreeSpace=$(PrintSize ${DstFreeSpace})"

          GrabELevel ELevel 9
					continue
				fi

				if [ ${SymLnk} -ne 2 -a ! -e "${DstName}" ] ; then
					if [ ${SameDeviceMove} -ne 0 ]; then
						sRunProg cp "${SrcName}" "${DstName}" ||{ GrabELevel ELevel $? ; continue ; } 
						if [ ! -e "${DstName}" ]; then
							sErrorOut "$(gettext "Copy Failed (7)")" 
              GrabELevel ELevel 7
							continue
						fi

						DstSize=$(GetFileSize "${DstName}") || { GrabELevel ELevel $? ; continue ; } 

						if [ ${SrcSize} -ne ${DstSize} ]; then
							sErrorOut "$(gettext "Filesize mismatch ")($(PrintSize ${SrcSize}) != $(PrintSize ${DstSize}))"
              GrabELevel ELevel 6
							continue
						fi
						CloneSig "${SrcName}" "${DstName}"

						SimpleDelFile "${SrcName}" || { GrabELevel ELevel $? ; continue ; } 
						RemoveSig "${SrcName}" 
					else
						CloneSig "${SrcName}" "${DstName}" && RemoveSig "${SrcName}" 
						sRunProg mv "${SrcName}" "${DstName}" || { GrabELevel ELevel $? ; continue ; } 
					fi
				fi

				if [ ${SymLnk} -eq 1 ]; then
					sRunProg ln --symbolic "${DstName}" "${SrcName}"
				elif [ ${SymLnk} -eq 2 ]; then
					sRunProg ln --symbolic "${SrcName}" "${DstName}" 
				fi

			elif [ -e "${SrcName}" ]; then
				sLogOut "$(GetFileTextType "${SrcName}"): \"${SrcName}\""
        GrabELevel ELevel 4
				continue
			else
				sErrorOut "$(gettext "SrcFile Doesn't exist ")\"${SrcName}\""
			fi
			GrabELevel ELevel $?
		done
		return ${ELevel}
	}
	function MoveMain {   
		local Dst="${@:$#:1}"
		local Src
		local -i SrcSize
		local -i DstSpace
		local -i SameDeviceMove
		#CreateMissingFolder_Ask "${Dst}" || return 8
		if [ ! -d "${Dst}" ]; then
			sErrorOut "$(gettext "Destination folder doesn't exist")"  "\"${Dst}\""
			return 7
		fi
		if [ ! -w "${Dst}" ]; then
		  sErrorOut "$(gettext "Destination Folder not modifiable ")\"${Dst}\""
			return 9
		fi 
		for Src in "${@:1:(($#-1))}"; do
			Dst="$(CleanFolderName "${@:$#:1}")"
			DstFldr="${Dst}/$(basename "${Src}")"
      if [[ -f "${Src}" ]]; then
        [[ -d "${Dst}" ]] || CreateMissingFolder_Ask "${Dst}" || continue
      else
        [[ -d "${DstFldr}" ]] || CreateMissingFolder_Ask "${DstFldr}" || continue
      fi
			Src="$(CleanFolderNameSub "${Src}")"
			#echo "CheckSameDevice \"${Src}" \"${DstFldr}" $(CheckSameDevice "${Src}" "${DstFldr}")"
			SameDeviceMove="$(CheckSameDevice "${Src}" "${DstFldr}")"
			if [ ${SameDeviceMove} -ne 0 ]; then
				SrcSize=$(GetSizeRecursive "${Src}")
				DstSpace=$(GetFreeDiskSpace "${DstFldr}")
				if [ ${DstSpace} -lt ${SrcSize} ]; then
					sErrorOut "$(gettext "Not Enough Free Disk Space on") \"$(GetMountPoint ${DstFldr})\"" \
										"$(gettext "Available") : $(PrintSize ${DstSpace})"   \
										"$(gettext "Required")  : $(PrintSize ${SrcSize})"
					continue
				fi
			fi
			if Move_int "${Src}" "${Dst}" && [ ${SymLnk} -eq 3 -a -e "${Dst}" -a ! -e "${Src}" ] ; then
				sRunProg ln --symbolic "${Dst}/$(basename "${Src}")" "${Src}"
			fi
		done
	}
	declare -gr moveRevision=$(CleanRevision '$Revision: 53 $')
	declare -gr moveDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "move.sh;${moveRevision};${moveDescription}"
	if [ "${SBaseName2}" = "move.sh" ]; then 
		declare -gr ScriptRevision="${moveRevision}"


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


		#SetLogFileName "&1"
		sLogOut "${0}" "${@}"


		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers SetMoveFlags
		#push_element SupportedCLIOptions 
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
					-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
					*)
						push_element "${ArrayName}" "$(FunctionMapGlobal "${1}")"
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

		#
		# Recreate Links
		#
		#RecreateLinks || sError_Exit 7 "$(gettext "RecreateLinks call failed")"

		HumanReadable=1

		[ ${#ArgFiles[@]} -ge 2 ]	&& MoveMain "${ArgFiles[@]}"

		sNormalExit $?
	fi
fi





