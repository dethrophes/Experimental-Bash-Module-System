#!/bin/bash
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
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
#I  File Name            : CreateRawVMDK.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__CreateRawVMDK_SH__}" ]; then
	__CreateRawVMDK_SH__=1

	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	SourceCoreFiles_ "ScriptWrappers.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################

	

	if [ "${SBaseName2}" = "CreateRawVMDK.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 64 $')

		function InstallDependencies {
			InstallPackages "${@}"  
		}

		#########################################################################
		# PROCEDURES
		#########################################################################

		HandleMissingArg ()
		{
			if [ "$2" ] 
			then
				eval $1='"$2"'
			else
				echo $3
				exit 1
			fi
		}

		HandleError ()
		{
			if [ $1 -gt 0 ] 
			then
				exit $1
			fi
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

		lvGroupName=DETH00
		HandleMissingArg "Name" "${ArgFiles[0]}" "Missing Disk Name Arg 1"
		HandleMissingArg "Size" "${ArgFiles[1]}" "Missing Disk Size Arg 2"


		RawDevName="/dev/mapper/$lvGroupName-$Name"
		RawFileName="${HOME}/.VirtualBox/HardDisks/$Name.vmdk"

		if [ ! -f "$RawFileName"  ]; then
			if ! [ -e  "$RawDevName" ];	then
				RunProgRoot "$FUNCNAME" "$LINENO" lvcreate -n "$Name" -L "$Size" /dev/$lvGroupName
				HandleError $?
			fi

			sRunProg VBoxManage internalcommands createrawvmdk -rawdisk "$RawDevName" -filename "$RawFileName"
			HandleError $?
		fi
		sNormalExit $?
	fi
fi
