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
#I  File Name            : UserFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__USERFUNCS_SH__}" ]; then
	__USERFUNCS_SH__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"


	#########################################################################
	# PROCEDURES
	#########################################################################

	function GetUserDesc {
		getent passwd "$1" && return 0
		cat /etc/passwd | grep "$1"
	}
	function GetUserNames {
		echo $(GetUserDesc "$1" | awk 'BEGIN { FS = ":" } ; { print $1 }')
	}
	function GetUserDescC {
		getent passwd "$1" && return 0
		cat /etc/passwd | grep "$1" | head -1 
	}

	function GetUserName {
		GetUserDescC "$1" | cut -f 1 -d ":"
	}
	function GetUserUID {
		GetUserDescC "$1" | cut -f 3 -d ":"
	}
	function GetUserGID {
		GetUserDescC "$1" | cut -f 4 -d ":"
	}
	function GetRealUserName {
		GetUserDescC "$1" | cut -f 5 -d ":" | cut -f 1 -d ","
	}
	function GetUserGroups {
		GetUserDescC "$1" | cut -f 5 -d ":" | cut -f 2 -d ","
	}
	function GetUserEmail {
		GetUserDescC "$1" | cut -f 5 -d ":" | cut -f 4 -d ","
	}
	function GetUserHomeDir {
		GetUserDescC "$1" | cut -f 6 -d ":"
	}
	function GetUserShell {
		GetUserDescC "$1" | cut -f 7 -d ":"
	}

	if [ "${SBaseName2}" = "UserFuncs.sh" ]; then 
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

		SetLogFileName "&1"

		sLogOut "${0}" "$@"

		#########################################################################
		# Argument Processing
		#########################################################################
		MainOptionArg "" "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"
		TestFuncs=( "GetUserDesc" "GetUserNames" "GetUserName" "GetUserUID" "GetUserGID" "GetRealUserName" "GetUserGroups" "GetUserEmail" "GetUserHomeDir" "GetUserShell")
		TestData=( "1000" "John Kearney" "dethrophes" "jkearney" "1019" "ehansen")
		for CId in "${TestData[@]}"; do 
			for CFunc in "${TestFuncs[@]}"; do 
				echo -e "$CFunc\t\"$CId\"\t= $(eval $CFunc \"$CId\")"
			done
		done
		sNormalExit $?
	fi

fi
