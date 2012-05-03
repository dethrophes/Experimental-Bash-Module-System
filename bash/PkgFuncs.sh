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
#I              File Name            : PkgFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : PkgFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__PkgFuncs_sh__:-}" ]; then
	__PkgFuncs_sh__=1


	function InstallPackages {
		if have apt-get ; then 
			if [ ${#RequiredDebianPackages[@]} -gt 0 ]; then
				sRunProgRoot apt-get install "${RequiredDebianPackages[@]}" "${@}"
			fi
		elif have yum ; then 
			if [ ${#RequiredRpmPackages[@]} -gt 0 ]; then
				sRunProgRoot yum install "${RequiredRpmPackages[@]}" "${@}"
			fi
		elif have emerge ; then 
			if [ ${#RequiredGentooPackages[@]} -gt 0 ]; then
				sRunProgRoot emerge "${RequiredGentooPackages[@]}" "${@}"
			fi
		elif have pkgadd ; then 
			if [ ${#RequiredSolarisPackages[@]} -gt 0 ]; then
				sRunProgRoot pkgadd -d "${RequiredSolarisPackages[@]}" "${@}"
			fi
		elif have pkg_add ; then 
			if [ ${#RequiredFreeBsdPackages[@]} -gt 0 ]; then
				sRunProgRoot pkg_add -r "${RequiredFreeBsdPackages[@]}" "${@}"
			fi
		elif have smart ; then 
			if [ ${#RequiredSusePackages[@]} -gt 0 ]; then
				sRunProgRoot smart "${RequiredSusePackages[@]}" "${@}"
			fi
		elif have zypper ; then 
			if [ ${#RequiredSusePackages[@]} -gt 0 ]; then
				sRunProgRoot zypper "${RequiredSusePackages[@]}" "${@}"
			fi
		elif have yast ; then 
			if [ ${#RequiredSusePackages[@]} -gt 0 ]; then
				sRunProgRoot yast "${RequiredSusePackages[@]}" "${@}"
			fi
		fi
	}

	function AskInstall {
		which "${1}" >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			if PromptYN_Alt "$(gettext "Should I install it?") "\
					"${1} $(gettext "Not installed") " ; then
				InstallDependencies "${1}" ||
					sError_Exit 5 "$(gettext "Error Installing") \"${1}\""
			else
				sError_Exit 5 "\"${1}\" $(gettext "Not installed")" 
			fi
		fi
	}

	function InstallDependencies {
		InstallPackages "${@}" 
	}

	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages	moreutils
	#push_element RequiredRpmPackages			moreutils
	#push_element RequiredGentooPackages	moreutils
	#push_element RequiredSolarisPackages	moreutils
	#push_element RequiredFreeBsdPackages	moreutils
	#push_element RequiredSusePackages   	moreutils

	PkgFuncsRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "PkgFuncs.sh;${PkgFuncsRevision}"
	if [ "${SBaseName2}" = "PkgFuncs.sh" ]; then 
		ScriptRevision="${PkgFuncsRevision}"


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

