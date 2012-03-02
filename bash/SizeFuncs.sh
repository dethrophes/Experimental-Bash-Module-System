#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/SizeFuncs.sh $
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
#I  File Name            : SizeFuncs.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: SizeFuncs.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>

[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__SizeFuncs_sh__:-}" ]; then
	__SizeFuncs_sh__=1

	HumanReadableMap=(
		"B;1"
		"KiB;1024"
		"MiB;(1024*1024)"
		"GiB;(1024*1024*1024)"
		"TiB;(1024*1024*1024*1024)"
		"PiB;(1024*1024*1024*1024*1024)"
		"ZiB;(1024*1024*1024*1024*1024*1024)"
	)
	HumanReadableMap2=(
		"B;1"
		"KB;1000"
		"MB;(1000*1000)"
		"GB;(1000*1000*1000)"
		"TB;(1000*1000*1000*1000)"
		"PB;(1000*1000*1000*1000*1000)"
		"ZB;(1000*1000*1000*1000*1000*1000)"
	)
	function MakeInteger {   
		ReturnString $(echo "${1}" | sed -r 's/\..*$//' | sed -r 's/^\s*~//')
	}
	function MakeSizeHumanReadable {   
		local Val
		local CurDesc
		for Val in "${HumanReadableMap[@]}"; do
			SplitCsvToArray CurDesc "${Val}"
			let ULimit=${CurDesc[1]}*1024
			if [ ${1} -lt ${ULimit} ]; then
				#echo AdjValue=\$\(calc ${1}/${CurDesc[1]}\)
				AdjValue=$(calc ${1}/${CurDesc[1]})
				MinValue=$(MakeInteger "$(calc ${AdjValue}*100%100)")
				AdjValue="$(MakeInteger "${AdjValue}")"
				printf "%3d.%02d%s\n"  "${AdjValue}" "${MinValue}" "${CurDesc[0]}"
				return 0
			fi
		done
	}
	function PrintSize {
		if [ ${HumanReadable} -eq 0 ]; then
			ReturnString "${1}"
		else
			MakeSizeHumanReadable "${1}"
		fi
	}
	function GetSizeRecursive {   
		local SrcName
		local -i SizeTotal=0
		local -i ELevel=0
		for SrcName in "${@}"; do
			if [ -h "${SrcName}" ]; then
				#sLogOut "$(gettext "Link"): \"${SrcName}\""
				continue
			elif [ -p "${SrcName}" ]; then
				#sLogOut "$(gettext "Pipe"): \"${SrcName}\""
				continue
			elif [ -b "${SrcName}" ]; then
				#sLogOut "$(gettext "Block Device"): \"${SrcName}\""
				continue
			elif [ -c "${SrcName}" ]; then
				#sLogOut "$(gettext "Character Device"): \"${SrcName}\""
				continue
			elif [ -d "${SrcName}" ]; then
				#sLogOut "$(gettext "Folder"): \"${SrcName}\""
				let SizeTotal+=$(GetSizeRecursive "${SrcName}/"*)
				GrabELevel ELevel $?
			elif [ -f "${SrcName}" ]; then
				#sLogOut "$(gettext "File"): \"${SrcName}\""
				let SizeTotal+=$(GetFileSize "${SrcName}")
			else
				sErrorOut "$(gettext "SrcFile Doesn't exist") \"${SrcName}\""
			fi
			#printf "%12d : %s\n" ${SizeTotal} "${SrcName}" >&2
		done

		GrabELevel ELevel $?
		ReturnString ${SizeTotal}
		return "${ELevel}"
	}



	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages	moreutils
	#push_element RequiredRpmPackages			moreutils
	#push_element RequiredGentooPackages	moreutils

	SizeFuncsRevision=$(CleanRevision '$Revision: 53 $')
	push_element	ScriptsLoaded "SizeFuncs.sh;${SizeFuncsRevision}"
	if [ "${SBaseName2}" = "SizeFuncs.sh" ]; then 
		ScriptRevision="${SizeFuncsRevision}"

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
		sLogOut "${0}" "${@}"


		#########################################################################
		# Argument Processing
		#########################################################################
		#push_element ModulesArgHandlers 
		#push_element SupportedCLIOptions 

		MainOptionArg "" "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"

		sNormalExit 0
	fi
fi

