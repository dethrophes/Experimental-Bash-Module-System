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
#I  File Name            : CreateM3U.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
ScriptDir="$(cd "$(dirname "$0")"; pwd)"
source "$ScriptDir/GenFuncs.sh"
source "$ScriptDir/DiskFuncs.sh"

function InstallDependencies {
	InstallPackages "${@}"  
}

#########################################################################
# Usage
#########################################################################
function Usage {
	echo .
	echo +==============================================================================
	echo I  $(basename $0) ................................................... \$Rev: 64 $
	echo +==============================================================================
	echo I  
	echo I  $(gettext "Description"):
	echo I    $(gettext "Please Enter a program description here")
	echo I  
	echo I  $(gettext "Usage"):
	echo I    
	echo I  
	sNormalExit 0
}


LogOut "$FUNCNAME" "$LINENO" "$0" "$@"

#########################################################################
# Argument Processing
#########################################################################
while [ $# -gt 0 ] ; do
	case "$1" in
		'-h'|'/h'|'/?'|'-?'|'--help')
			Usage
			;;
		--SupportedOptions)
			echo '-h --help -y -n --gui --console --LogFile --InstallDependencies'
			exit 0
			;;
		-n|-N)
			BatchMode=2
			;;
		-y|-Y)
			BatchMode=1
			;;
		--console)
			ConsoleInterface=1
			;;
		--gui)
			ConsoleInterface=0
			;;
		'--InstallDependencies')
			InstallDependencies
			;;
		'--LogFile')
			TestEnoughArgs "$FUNCNAME" "$LINENO" $# 1 "--LogFile Requires Arg "
			shift
			SetLogFileName "$1"
			;;
		-*)
			sError_Exit 4 "$(gettext "Unsupported option") \"$1\""
			;;
		*)
			ArgFiles[$ArgFileCnt]="$1"
			((ArgFileCnt ++ ))
			;;
	esac
	shift
done

#########################################################################
# MAIN PROGRAM
#########################################################################

sNormalExit 0




