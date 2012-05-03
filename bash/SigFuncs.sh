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
#I              File Name            : SigFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : SigFuncs.sh
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

if [ -z "${__SigFuncs_sh__:-}" ]; then
	__SigFuncs_sh__=1

	#########################################################################
	# Procedures
	#########################################################################
	declare -gra SupportedSigCmds=(
		  'sha256;sha256sum;sigs.sha256;.*\.sha256;s/^\w+\s+//;sha256deep'
		  'sha224;sha224sum;sigs.sha224;.*\.sha224;s/^\w+\s+//;'
		  'sha384;sha384sum;sigs.sha384;.*\.sha384;s/^\w+\s+//;'
		  'sha512;sha512sum;sigs.sha512;.*\.sha512;s/^\w+\s+//;'
		  'sha1;sha1sum;sigs.sha1;.*\.sha1;s/^\w+\s+//;sha1deep'
		  'sha;shasum;sigs.sha;.*\.sha;s/^\w+\s+//;'
		  'md5;md5sum;sigs.md5;.*\.md5;s/^\w+\s+//;md5deep'
		  'crc32;cksfv;sigs.sfv;.*\.sfv;s/\s+\w+$//;'
		  'ck;cksum;sigs.ck;.*\.ck;s/^\w+\s+//;'
		  'tiger;;sigs.tiger;.*\.tiger;s/^\w+\s+//;tigerdeep'
		  'whirlpool;;sigs.whirlpool;.*\.whirlpool;s/^\w+\s+//;whirlpooldeep'
	)

	SignatureFiles="$(PrintArray "${SupportedSigCmds[@]}" | cut -d ";" -f 4 | tr "\n" "|")"
	readonly SignatureFiles="(${SignatureFiles%|})"
	readonly IgnoreFolders='(\.Trash-1000|\.svn|\.cvs|\.git|CVS|lost\+found|\.doc)'
	readonly IgnoreFiles1='(.+\.!ut|file\.lst|Thumbs\.db|.+\.torrent)'
	readonly IgnoreFiles=".*/(${SignatureFiles}|${IgnoreFiles1}|${IgnoreFolders}/.*)"
	readonly IgnoreFiles2="${SignatureFiles}|${IgnoreFiles1}|${IgnoreFolders}"
	#echo "IgnoreFiles=\"${IgnoreFiles}\""

  function SetSigType {
		local CSum
		local -a CSumDesc

		for CSum in "${SupportedSigCmds[@]}"; do 
			SplitCsvToArray CSumDesc "${CSum}"
			if [ "${CSumDesc[0]}" = "${1}" ]; then
				SumType="${CSumDesc[0]}"
				SumCmd="${CSumDesc[1]}"
				SumFile="${CSumDesc[2]}"
				SumPipe="${CSumDesc[5]}"
				SumFileMask="${CSumDesc[3]}"
				SumFileStripSums="${CSumDesc[4]}"
				break
			fi
		done
	}
	SetSigType  sha256
	function hash_cp {
		dd if="${1}" 2>/dev/null | tee "${2}" | ${SumPipe}
	}
	function hash_cp_chk {
		[ -v SumPipe ] || sError_Exit 5 "$(gettext "No command defined to hash pipe for") \"${SumType}\" "
		local bName="$(basename "${1}")"
		local Hash="$(hash_cp "${1}" "${2}/${bName}")"
		if [ "${?}" -gt 0 ]; then
			return 3
		fi
		local SrcSig="$(GetSig "${1}")"
		local	CpSig="${Hash}  ${bName}"
		if [ -n "${SrcSig}" ]; then
			if [ "${SrcSig}" != "${CpSig}" ]; then
				sErrorOut "$(gettext "Hash mismatch during copy process")"\
					"$(gettext "Source File      :") \"${1}\""\
					"$(gettext "Source Hash      :") \"${SrcSig}\""\
					"$(gettext "Destination File :") \"${2}\"" \
					"$(gettext "Copy Hash        :") \"${CpSig}\"" 
				return 3
			fi
		fi
		echo "${CpSig}"
		return 0
	}
	function hash_cp_dst {
		hash_cp_chk "${@}" >>"${2}/$(basename "${1}")"
		return 0
	}
	function paranoid_hash_cp {
		local DstFile="${2}/$(basename "${1}")"
		local	CpSig="$(hash_cp_chk "${@}")"
		[ -n "${CpSig}" ] || return 4
		SigFiles "${DstFile}" || return $?
		local DstSig="$(GetSig "${DstFile}")"
		[ -n "${DstSig}" ] ||	return 6

		if [ "${SrcSig}" != "${CpSig}" ]; then
			sErrorOut "$(gettext "Hash mismatch during copy process")"\
				"$(gettext "Source File      :") \"${1}\""\
				"$(gettext "Source Hash      :") \"${CpSig}\""\
				"$(gettext "Destination File :") \"${2}\"" \
				"$(gettext "Destination Hash :") \"${DstSig}\""\
				"$(gettext "Copy Hash        :") \"${CpSig}\"" 
			return 6
		fi
		return 0
	}
  function escapeGrepPatern {
		if [ $# -gt 0 ]; then
			echo "${1}" | escapeGrepPatern
		else
			sed 's/\([][]\)/\\\1/g'
		fi
	}
  function SigFiles_sub {
		while [ $# -gt 0 ]; do
			if [ -z "${1}" -o "${1}" = "*" -o -h "${1}" ]; then shift ; continue ; fi
			DiagnoseReadAccess ${FUNCNAME} "${1}"
			if [ -f "${1}" ]; then
 				if [[ ${1} =~ ${IgnoreFiles2} ]]; then shift ; continue ; fi
				#echo "${1}"
				#RemoveSig "${1}"
				if [ -f "${SumFile}" ] && TestSigPresent "${1}"	; then shift ; continue ; fi
				echo "${1}"
				DiagnoseWriteAccess ${FUNCNAME} "${SumFile}"
				"${SumCmd}" "${1}" >>"${SumFile}"
			elif [ -d "${1}" ]; then
				if cd "${1}" ; then 
					SigFiles_sub *  
					cd ..
				else
					sErrorOut "$(pwd)/${1}"
				fi
			fi
			shift
		done
	}
  function CloneSig {
		if [ "${1}" != "${2}" ] && ! TestSigPresent "${2}" ; then
			TestSigPresent "${1}" || SigFiles "${1}"
			GetSig "${1}" >>"$(GetSigFile "${2}")"
		fi
 	}
 function SigFiles {
		[ -v SumCmd ] || sError_Exit 5 "$(gettext "No command defined to hash file for") \"${SumCmd}\" "
		local DirName
		while [ $# -gt 0 ]; do
			DirName="$(dirname "${1}")"
			if [ -z "${DirName}" ] ||	pushd "${DirName}" >/dev/null  ; then
				SigFiles_sub "$(basename "${1}")"  
				[ -n "${DirName}" ] &&	popd >/dev/null
			fi
			shift
		done
	}
	function GetSigFile {
		ReturnString "$(dirname "${1}")/${SumFile}"
	}
	function TestSigPresent {
		grep -F "$(basename "${1}")" "$(GetSigFile "${1}")" &>/dev/null
	}
	function GetSig {
		grep -F "$(basename "${1}")" "$(GetSigFile "${1}")" 2>/dev/null
	}
	function GetSigs {
		while [ $# -gt 0 ]; do
			GetSig "${1}"
			shift
		done
	}
	function RemoveSig {
		local LSumFile
		while [ $# -gt 0 ]; do
			LSumFile="$(GetSigFile "${1}")"
			if [ -w "${LSumFile}" ]; then
				local TContent="$(grep -Fv "$(basename "${1}")" "${LSumFile}")"
				if [ ${#TContent} -gt 10 ]; then
					echo "${TContent}" > "${LSumFile}"
				else
					SimpleDelFile "${LSumFile}"
				fi
			fi
			shift
		done
	}
	function ListSignedFiles {
		local -a CFiles
		local DirName
		while [ $# -gt 0 ]; do
			DirName="$(dirname "${1}")"
			IFS=$'\n' CFiles=($(cat "${1}" | sed -r "${SumFileStripSums}" ))
			PrintArray "${CFiles[@]/#/${DirName}/}"
			shift
		done
	}
	function FilterIgnoreFiles {
		local CLine
		while read CLine; do 
			[[ ${CLine} =~ ${IgnoreFiles} ]] && ReturnString "${CLine}"
		done
	}
	function FindSigFilesRecursive {
		while [ $# -gt 0 ]; do
			if ! TestFolder "${1}" ; then shift ; continue ; fi
			find "${1}" -type f -regextype posix-extended -regex "${SumFileMask}"
			shift
		done
	}
	function ListOrphanedSignatures_sub {
		local CFile
		local -a CFiles
		IFS=$'\n' CFiles=($(ListSignedFiles "${@}"))
		for CFile in "${CFiles[@]}"; do
			[ ! -f "${CFile}" ] && ReturnString "${CFile}"
		done
	}
	function ListOrphanedSignaturesRecursive {
		local -a CFiles
		IFS=$'\n' CFiles=($(FindSigFilesRecursive "${@}"))
		ListOrphanedSignatures_sub "${CFiles[@]}"
	}
	function RemoveOrphanedSignaturesRecursive {
		local -a CFiles
		IFS=$'\n' CFiles=($(ListOrphanedSignaturesRecursive "${@}"))
		RemoveSig "${CFiles[@]}"
	}

 	function ListIgnoreFilesSigsRecursive {
		local -a CFiles
		IFS=$'\n' CFiles=($(FindSigFilesRecursive "${@}"))
		ListSignedFiles "${CFiles[@]}" | FilterIgnoreFiles
	}
 	function RemoveIgnoreFilesSigsRecursive {
		local -a CFiles
		IFS=$'\n' CFiles=($(ListIgnoreFilesSigsRecursive "${@}"))
		RemoveSig "${CFiles[@]}"
	}



	readonly TSigFile="§(mktemp)"
	RegisterTempFile "${TSigFile}"
	function CheckSig_sub {
		local CFile
		local ELevel=0
		while [ $# -gt 0 ]; do
			if [ -z "${1}" -o "${1}" = "*" -o -h "${1}" ]; then shift ; continue ; fi
			DiagnoseReadAccess ${FUNCNAME} "${1}"

			if [ -f "${1}" ]; then
 				if [[ ${1} =~ ${IgnoreFiles2} ]]; then shift ; continue ; fi
				if ! GetSig "${1}" >"${TSigFile}"; then
					sWarningOut "$(gettext "No Signature present for File")" "$(pwd)/${1}"
				elif ! "${SumCmd}" -c "${TSigFile}"; then
					GrabELevel ELevel $?
					sErrorOut "$(gettext "Signature mismatch File")" "$(pwd)/${1}"
				fi

			elif [ -d "${1}" ]; then

				if ! cd "${1}" ; then sErrorOut "$(pwd)/${1}"; shift ; continue ; fi
				
				#if ! "${SumCmd}" -c "${SumFile}"; then 
				#	GrabELevel ELevel $?
				#	sErrorOut "$(gettext "Signature mismatch File")" "$(pwd)/${1}"
				#fi
        #
				#for CFile in *; do
				#	if [ -d "${CFile}" ]; then
				#		CheckSig_sub "${CFile}" 
				#		GrabELevel ELevel $?
				#  fi
				#done
				CheckSig_sub * 

				cd ..
			fi
			shift
		done
		return ${ELevel}
	}

	function CheckSig {
		local DirName
		while [ $# -gt 0 ]; do
			DirName="$(dirname "${1}")"
			[ -n "${DirName}" ] &&	pushd "${DirName}" >/dev/null
			CheckSig_sub "$(basename "${1}")"  
			[ -n "${DirName}" ] &&	popd >/dev/null
			shift
		done
	}
 
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	readonly SigFuncsRevision=$(CleanRevision '$Revision: 64 $')
	readonly SigFuncsDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "SigFuncs.sh;${SigFuncsRevision};${SigFuncsDescription}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "SigFuncs.sh" ]; then 
	readonly ScriptRevision="${SigFuncsRevision}"

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
	push_element ModulesArgHandlers  Set_SigFuncs_Flags 
	push_element SupportedCLIOptions $(ListFunctionsAsArgs "${0}")
	function Set_SigFuncs_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			#echo "2 ${1}"
			case "${1}" in
				--*)
					FuncName="${1:2}"
					if [ "$(type -t "${FuncName}")" = "function" ]; then
						shift
						let PCnt+=1
						"${FuncName}" "${@}"
						exit 
					else
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
					fi
					;;
				*)
					sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
					;;
			esac
			let PCnt+=1
			shift
		done
		return ${PCnt}
	}
	CommonOptionArg ArgFiles "${@}"
	MainOptionArg "" "${ArgFiles[@]}"

	#########################################################################
	# MAIN PROGRAM
	#########################################################################


	sNormalExit 0
fi

