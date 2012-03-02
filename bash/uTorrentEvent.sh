#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/uTorrentEvent.sh $
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
#I  ID                   : $Id: uTorrentEvent.sh 53 2012-02-17 13:29:00Z dethrophes $
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
SourceCoreFiles_ "move.sh" "uTorrentFuncs.sh" "JobQueue.sh" "FixSymLinks.sh"


if [ -z "${__uTorrentEvent_SH__:-}" ]; then
	__uTorrentEvent_SH__=1

	#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"
	declare -ga SortFilesCfgLines


	#########################################################################
	# Procedures
	#########################################################################
	function MoveMake {
		SetMoveFlags "${@}" || shift $? 
		#sDebugOut "${@}"
		local Dst="${@:$#:1}"
		if [ ! -h "${1}" ]; then
			[ -e "${Dst}" ] || CreateMissingFolder "${Dst}" || return $?
			[   -d "${Dst}" ] && MoveMain "${@}" || return $?
		fi
	}
	function ExecuteJob {
		#sDebugOut "${@}"
		#AddJobNice 20 "${@}" || "${@}" || return $?
		"${@}" || return $?
	}
	function SpecialMoveMakeR {
		SetMoveFlags "${1}" || shift $?
		SetMoveFlags --NOSYM --Recursive || true
		sLogOut "${@}"
		for CSource in "${@:1:$#-1}"; do
			local DstDir="${@:$#}"
			if [ -d "${CSource}" ]; then
				DstDir="${DstDir}/$(FixupFileName "$(basename "${CSource}")")"
				MoveMake "${CSource}/"* "${DstDir}/" && SimpleRmdir "${CSource}" && sRunProg ln -s "${DstDir}" "${CSource}" || return $?
			else
				MoveMake "${CSource}" "${@:$#}/" || return $?
			fi
		done
	}
	function CheckAlreadyExist {
		local SrcFile="${1:?Error Missing SrcFile}"
		if [ -e "${SrcFile}" ] && [ ! -h "${SrcFile}" ]; then
			local DstDir="$(FindInSortCfg "${SrcFile}" || true)"
			[ -n "${DstDir}" ] || DstDir="$(FindInFindFiles_Folder  "$(basename "${SrcFile}" '.!ut')" || true)" 

			if [ -n "${DstDir}" ]; then
				DstName="${DstDir}/$(basename "${SrcFile}" '.!ut')"
				if [ -e "${DstName}" ]; then
					ExecuteJob ReplaceTorrent ${THash} MoveMake --SSYM --NoRecursive "${SrcFile}" "${DstDir}"   || true
				fi
			fi
		fi
	}


	function WinePath {
		 #sLogOut "${@}" 
		if [ "${1:0:1}" = "/" ]; then
			echo "$(CleanFolderName "${1}")"
		else
			echo "$(CleanFolderName "$(winepath "${1}")")"
		fi
	}

	uTorrentEventRevision=$(CleanRevision '$Revision: 53 $')
	if [ "${SBaseName2}" = "uTorrentEvent.sh" ]; then 
		ScriptRevision="${uTorrentEventRevision}"

		BaseDir="/mnt/DETH00/media"

		function HandleMoveArg {
			#sLogOut "${CallType}" "${TState}" "${TStatus}" "${TGroup}" "$(StringifyUTorrentState "${TState}")" "${TFileName}" "${3}" # "${TName}" "${TTracker}" "${THash}"
			sLogOut "${0}" "${ArgFiles[@]}"
			[ ! -h "${SrcFile}" ] && [ -w "${SrcFile}" ] && sRunProg chmod -R ug+rw "${SrcFile}" || true  
			#[ ! -h "${SrcFile}" ] && SigFiles "${SrcFile}"
			if [ -n "${TGroup}" ] && [ ! -h "${SrcFile}" ] ; then
				case "${TGroup}" in
					Music)
						ExecuteJob MoveMake --Recursive --SSYM "${SrcFile}" "${BaseDir}/Music_/" || true
						;;
					Episodes)
						if [ "${TorrentSingleFile}" -eq 0 ]; then
							Dst="${BaseDir}/Episodes/$(basename "${TFolderName}")"
							[ -e "${Dst}" ] || CreateMissingFolder "${Dst}"
							ExecuteJob MoveMake --SSYM --NoRecursive "${SrcFile}" "${BaseDir}/Episodes/" || true
						fi
						;;
					Episodes/*)
						ExecuteJob MoveMake --SSYM --NoRecursive "${SrcFile}" "${BaseDir}/Episodes/${TGroup/#Episodes\//}" || true 
						;;
					Docu/*)
						ExecuteJob SpecialMoveMakeR "${SrcFile}" "${BaseDir}/Documentaries/${TGroup/#Docu\//}"  || true
						;;
					Films/*)
						Dst="${BaseDir}/Films/00.Collections/${TGroup/#Films\//}"
						if [ "${TorrentSingleFile}" -eq 0 ]; then
							Dst="${Dst}/$(basename "${TFolderName}")"
							[ -e "${Dst}" ] || CreateMissingFolder "${Dst}"
							ExecuteJob SpecialMoveMakeR "${SrcFile}" "${BaseDir}/Films/00.Collections/${TGroup/#Films\//}" || true
						else
							ExecuteJob MoveMake --SSYM --NoRecursive "${SrcFile}" "${Dst}/$(basename "${TFileName%.*}")" || true
						fi
						;;
					Films)
						Dst="${BaseDir}/Films"
						if [ "${TorrentSingleFile}" -eq 0 ]; then
							ExecuteJob SpecialMoveMakeR "${SrcFile}" "${BaseDir}/Films" || true
						else
							ExecuteJob MoveMake --SSYM --NoRecursive "${SrcFile}" "${Dst}/$(basename "${TFileName%.*}")" || true
						fi
						;;
					Manga/*)
						ExecuteJob MoveMake --Recursive --SSYM "${SrcFile}" "${BaseDir}/Manga/${TGroup/#Manga\//}" || true
						;;
					Manga)
						ExecuteJob MoveMake --Recursive --SSYM "${SrcFile}" "${BaseDir}/Manga/" || true 
						;;
				esac
			fi
			#sDebugOut "${SrcFile}"

			if [ "${TorrentSingleFile}" -eq 1 ] && [ ! -h "${SrcFile}" ]; then
				DstDir="$(FindInSortCfg "${SrcFile}" || true)"
				[ -n "${DstDir}" ] && [ -d "${DstDir}" ] && MoveMake --SSYM --NoRecursive "${SrcFile}" "${DstDir}" 
			fi
			if [ -h "${SrcFile}" -o "${TorrentSingleFile}" -eq 0 ]; then
				RemoveTorrent ${THash} || true
			fi
			## Workaround
			[ ! -e "${SrcFile}" ] || sRunProg mv "${SrcFile}" /media/New/New.Folder/
		}
		function RelinkToOld {
			local SrcFile="${SrcFile}"
			[ -e "${SrcFile}" ] || SrcFile="${SrcFile}.!ut"
			[ -h "${SrcFile}" ] && return 0
			if [ -e "${SrcFile}" ] && [ ! -h "${SrcFile}" ]; then
				local Dst="$(FixupFileName1 "${1}$(basename "${SrcFile}")")"
				[ -e "${Dst}" ] || Dst="$(FixupFileName1 "${1}$(basename "${TFolderName}")/$(basename "${TFileName}")")"
				[ -e "${Dst}" ] || Dst="$(FixupFileName1 "${1}$(basename "${TFolderName}")")"
				if [ -n "${Dst}" ] && [ -e "${Dst}" ] && [ -e "${SrcFile}" ] && [ -w "${TFolderName}" ]; then
						ExecuteJob ReplaceTorrent ${THash} MoveMake --SSYM --Recursive "${SrcFile}" "${Dst}"   || true
				fi
			fi
		}
		function ReplaceTorrent {
			local THash="${1}" && shift
			StopTorrent ${THash} || true
			"${@}" || return $?
			RecheckTorrent ${THash}
		}

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
		push_element ModulesArgHandlers SetJobQueueFlags
		#push_element SupportedCLIOptions
		MainOptionArg ArgFiles "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		SetMoveFlags -SSYM --NoRecursive --KeepDestSameSize --UseSourceBigger || true
		SetGenFuncsFlags --HumanReadable || true 
		[ ${#ArgFiles[@]} -ge 9 ] || sError_Exit 88 "$(gettext "Not Enough Args")"

		CallType="${ArgFiles[0]}"
		TFileName="${ArgFiles[1]}"
		TFolderName="$(WinePath "${ArgFiles[2]}")"
		TName="${ArgFiles[3]}"
		TState="${ArgFiles[4]}"
		TGroup="${ArgFiles[5]}"
		TTracker="${ArgFiles[6]}"
		TStatus="${ArgFiles[7]}"
		THash="${ArgFiles[8]}"
		TLState="${ArgFiles[9]}"

		TorrentSingleFile=0

		if [ "${TName}" = "$(basename "${TFolderName}")" ] ; then
			#echo 1 Folder
			SrcFile="${TFolderName}"
		elif [ ! -z "${TFileName}" ] ; then
			#echo 2 File
			TorrentSingleFile=1
			SrcFile="${TFolderName}/${TFileName}"
		else
			#echo 3 Folder
			SrcFile="${TFolderName}"
		fi
		if [ -z "${TGroup}" ]; then

			if TestStrPerlRegEx "${SrcFile}" '(Season|Series)' ; then
				TGroup="Episodes"
				SetTorrentLabel "${THash}" "${TGroup}"
			elif TestStrPerlRegEx "${SrcFile}" '(jaybob|axxo|dvdrip|bdrip)' ; then
				TGroup="Films"
				SetTorrentLabel "${THash}" "${TGroup}"
			fi
		fi

		InitJobQueue #&& push_element	CleanupFunctions CloseJobQueue


		case "${CallType}" in
			Finished)
				HandleMoveArg || true
  			;;
			CState)
				case "${TStatus}" in
				  '[F] Seeding'|'Seeding'|'Queued Seed'|'Finished')
						HandleMoveArg || true
				  	;;
					#'Moving...'|'Downloading'|'Stopped')
					#	;;
					'Queued')
						if [ -n "${TGroup}" ] && [ ! -h "${SrcFile}" ] ; then
							case "${TGroup}" in
								Music)
									RelinkToOld "${BaseDir}/Music_/" || true
									RelinkToOld "${BaseDir}/New/Music/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								Episodes)
									RelinkToOld "${BaseDir}/Episodes/" || true
									RelinkToOld "${BaseDir}/New/Series/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(Season.1)' "3" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Extras|Bonus)\b' "1" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								Episodes/*)
									RelinkToOld "${BaseDir}/Episodes/${TGroup/#Episodes\//}"  || true
									RelinkToOld "${BaseDir}/New/Series/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Season.1|S01|1x\d)\b' "3" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Extras|Bonus)\b' "1" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								Docu/*)
									RelinkToOld "${BaseDir}/Documentaries/${TGroup/#Docu\//}"  || true
									RelinkToOld "${BaseDir}/New/Docs/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Extras|Bonus)\b' "1" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								Films|Films/*)
									#RelinkToOld  "${BaseDir}/Films/00.Collections/${TGroup/#Films\//}/" || true
                  RelinkToOld "${BaseDir}/Films/" || true
									RelinkToOld "${BaseDir}/New/Films/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Extras|Bonus)\b' "1" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								Manga/*)
									RelinkToOld "${BaseDir}/Manga/${TGroup/#Manga\//}" || true
									RelinkToOld "${BaseDir}/New/Manga/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Extras|Bonus)\b' "1" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								Manga)
									RelinkToOld "${BaseDir}/Manga/"  || true
									RelinkToOld "${BaseDir}/New/Manga/"  || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '\b(Extras|Bonus)\b' "1" || true
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
								NoMask)
									nop
									#SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|txt|url|torrent|ico)$|sample)' "0" || true
									;;
								Software)
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|txt|url|torrent|ico)$|sample)' "0" || true
									;;
								*)
									ExecuteJob SetMaskedTorrentFilesPrio "${THash}" '(\.(nfo|xpi|txt|exe|url|torrent|ico)$|sample)' "0" || true
									;;
							esac
						fi
						sLogOut "${0}" "${ArgFiles[@]}"
						if [ "${TorrentSingleFile}" -eq 1 ]; then
							[ ! -e "${SrcFile}" ] && SrcFile="${SrcFile}.!ut"
							[ ! -h "${SrcFile}" ] && [ -w "${SrcFile}" ] && sRunProg chmod -R ug+rw "${SrcFile}" || true 
							CheckAlreadyExist "${SrcFile}" 
						fi

						;;
					'[F] Downloading'|'Downloading'|'Stopped'|*)
						sLogOut "${0}" "${ArgFiles[@]}"
						;;
				esac
				;;
		esac

		sNormalExit 0
	fi
fi
