#!/bin/bash
#if [ "${DEBUG}" != "1" ]; then stty -echo; fi
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
#I              File Name            : SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : HandleMo.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__HandleMo_sh__}" ]; then
	__HandleMo_sh__=1

	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	SourceCoreFiles_ "ScriptWrappers.sh"

	LocaleDir=${ScriptDir}/locale
	PoDir=${ScriptDir}/po

	#########################################################################
	# PROCEDURES
	#########################################################################
	function ConvToUTF-8 {
		iconv -f ISO-8859 -t UTF-8 "${1}"  

		#iconv -f ISO-8859 -t UTF-8 <"${1}" >"${TmpFile}" 
		#mv "${TmpFile}" "${1}"
	}
	function UpdateLanguageFiles {
		local UpdateFile="${1}"
		local ModName="${2}"
		local DestLang="${3}"
		local DestPoFile="${PoDir}/${ModName}-${DestLang}.po"
		local DestMoFile="${LocaleDir}/${DestLang}/LC_MESSAGES/${ModName}.mo"
		if [ -f "${DestPoFile}" ]; then
			sRunProg msgmerge -o "${TmpFile}" "${DestPoFile}" "${UpdateFile}"
			SimpleDelFile "${DestPoFile}"
			sRunProg mv "${TmpFile}" "${DestPoFile}"
		else
			sRunProg msginit --locale=${DestLang} --input="${UpdateFile}" --output-file="${DestPoFile}" 
			sRunProg sed -is 's/charset=ASCII/charset=UTF-8/' "${DestPoFile}"
			sRunProg sed -is 's/PACKAGE VERSION/v1.0.0.1/' "${DestPoFile}"
			SimpleDelFile "${DestPoFile}s"
		fi
		if [ -f "${DestPoFile}" ]; then
			DestLang=$(echo ${DestLang} | tr _ - )
			sRunProg "${ScriptDir}/../python/autoTranslatePo.py" "${DestPoFile}" en ${DestLang}
		fi
	}
	function CreateMoFile {
		local ModName="${1}"
		local DestLang="${2}"
		local SrcPoFile="${PoDir}/${ModName}-${DestLang}.po"
		local DestMoFile="${LocaleDir}/${DestLang}/LC_MESSAGES/${ModName}.mo"
		SimpleMkdir "${LocaleDir}/${DestLang}/LC_MESSAGES"
		if [ -f "${SrcPoFile}" ]; then
			sRunProg msgfmt -o "${DestMoFile}"  "${SrcPoFile}"
		fi
	}
	
	if [ "${SBaseName2}" = "HandleMo.sh" ]; then 
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


		sLogOut "${0}" "$@"
		#########################################################################
		# Argument Processing
		#########################################################################
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
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
		MainOptionArg ArgFiles  "${ArgFiles[@]}"
		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		#export TEXTDOMAINDIR=${ScriptDir}/locale
		#export TEXTDOMAIN=testScript
		DestLanguages=( "en" "de" "fr" "es" "zh" "ja" "cs" "pl" "nl" "fi" "it" "ru" "sl" "uk" "zh_CN" "pt" "ga" "cy" "iw")

		case "${ArgFiles[0]}"  in
			CreatePO)
				UpdateFile="${ScriptDir}/po/${TEXTDOMAIN}.pot"
				sRunProg xgettext -o "${UpdateFile}" "${ScriptDir}/"*.sh
				sRunProg sed -is 's/charset=ASCII/charset=UTF-8/' "${UpdateFile}"
				SimpleDelFile "${UpdateFile}s"

				#ConvToUTF-8 "${UpdateFile}"
				for CLang in "${DestLanguages[@]}"; do
					UpdateLanguageFiles "${UpdateFile}" "${TEXTDOMAIN}" "$CLang"
				done

				;;
			CreateMO)
				for CLang in "${DestLanguages[@]}"; do
					CreateMoFile "${TEXTDOMAIN}" "$CLang"
				done
				;;
			Test)
				echo "$(gettext "Test string one")" 
				echo "$(gettext "Hello World")" 
				echo "$(gettext "Requires Arg")"
				echo "$(gettext "Unsupported option")" 
				;;
			*)
					sError_Exit 4 "$(gettext "Unsupported command") \"${1}\" "
				;;
		esac

		sNormalExit 0
	fi
fi
