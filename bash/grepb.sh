#!/bin/bash +x
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
#I  File Name            : grepb.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__grepb_sh__}" ]; then
	__grepb_sh__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"

	TmpFile2="$(mktemp)"
	#CreateTempFile	TmpFile2


	#########################################################################
	# PROCEDURES
	#########################################################################
	function GrepB {
	  sRunProg grep_rev46.pl -xo "$TmpFile2" "$@" || return $?
	  sRunProg gvim -q "$TmpFile2" -c ":cope" 2>/dev/null &
	}

	function GrepB_N {
	  if [ -n $nubios ]; then
	    GrepB -r . "$@"
	  else
	    GrepB -r "$nubios" "$@"
	  fi 
	  return $?
	}

	if [ "${SBaseName2}" = "grepb.sh" ]; then 
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


		#LogOut "$FUNCNAME" "$LINENO" "$0" "$@"


		#########################################################################
		# Argument Processing
		#########################################################################
		#push_element ModulesArgHandlers  
		#push_element SupportedCLIOptions 
		MainOptionArg "ArgFiles" "${@}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		if [ -n "${ArgFiles[0]}" ]; then 
		  if [ `echo "${ArgFiles[0]}" | tr [:lower:] [:upper:]` = "-R" ]; then GrepB "${ArgFiles[@]}"; sNormalExit $?; fi
		  if [ -z "${ArgFiles[1]}" ]; then 
		    GrepB_N  -s "${ArgFiles[0]}"
		  else
		    GrepB_N  "${ArgFiles[@]}"
		  fi
		fi

		sNormalExit 0
	fi
fi



