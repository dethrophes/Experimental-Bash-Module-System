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
#I              File Name            : tek4014Funcs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : tek4014Funcs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh" || exit
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
#SourceCoreFiles_ "DiskFuncs.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__tek4014Funcs_sh__:-}" ]; then
	__tek4014Funcs_sh__=1
	#########################################################################
	# Module Shared Procedures
	#########################################################################
	#	Tektronix 4014 Mode
	#	Most of these sequences are standard Tektronix 4014 control sequences. Graph mode supports the 12-bit addressing
	#	of the Tektronix 4014. The major features missing are the write-through and defocused modes. This document does
	#	not describe the commands used in the various Tektronix plotting modes but does describe the commands to switch
	#	modes.
	#readonly tek4014_Bell=$'\b'								# Bell (Ctrl-G)
	#readonly tek4014_Backspace=$'\b'						# Backspace (Ctrl-H)
	#readonly tek4014_HT=$'\t'									# Horizontal Tab (Ctrl-I)
	#readonly tek4014_LF=$'\n'									# Line Feed or New Line (Ctrl-J)
	#readonly tek4014_Cursorup=$'\ck'						# Cursor up (Ctrl-K)
	#readonly tek4014_FF=$'\cL'									# Form Feed or New Page (Ctrl-L)
	#readonly tek4014_CR=$'\cM'									# Carriage Return (Ctrl-M)
	#readonly tek4014_SwitchtoVT100=$'\e\cC' 		# Switch to VT100 Mode (ESC Ctrl-C)
	#readonly tek4014_ReturnTS=$'\e\cE'					# Return Terminal Status (ESC Ctrl-E)
	#readonly tek4014_PAGE=$'\e\cL'							# PAGE (Clear Screen) (ESC Ctrl-L)
	#readonly tek4014_Begin4015APLmode=$'\e\cN'	# Begin 4015 APL mode (ignored by xterm) (ESC Ctrl-N)
	#readonly tek4014_End4015APLmode=$'\e\cO'		# End 4015 APL mode (ignored by xterm) (ESC Ctrl-O)
	#readonly tek4014_COPY=$'\e\cW'							# COPY (Save Tektronix Codes to file COPYyyyy-mm-dd.hh:mm:ss) (ESC Ctrl-W)
	#readonly tek4014_BypassCondition=$'\e\cX'	# Bypass Condition (ESC Ctrl-X)
	#readonly tek4014_GINmode=$'\e\cz'					# GIN mode (ESC Ctrl-Z)
	#readonly tek4014_SPPM=$'\e\c\'							# Special Point Plot Mode (ESC Ctrl-\)
	#readonly tek4014_SLCS=$'\e8'								# Select Large Character Set
	#readonly tek4014_SS2=$'\e9'								# Select #2 Character Set
	#readonly tek4014_SS3=$'\e:'								# Select #3 Character Set
	#readonly tek4014_SSSCS=$'\e;'							# Select Small Character Set

	##	OSC Ps ; Pt BEL Set Text Parameters of VT window
	## 		Ps = 0 ® Change Icon Name and Window Title to Pt
	## 		Ps = 1 ® Change Icon Name to Pt
	## 		Ps = 2 ® Change Window Title to Pt
	## 		Ps = 4 6 ® Change Log File to Pt (normally disabled by a compile-time option)
	#function	tek4014_SetTextParameters {	echo -n "${OSC}${1:?Missing Ps};${2:?Missing Pt}"$'\b';	}
	#readonly tek4014_NormalZAxisandNormal_Vectors=$'\e`'				# Normal Z Axis and Normal (solid) Vectors
	#readonly tek4014_NormalZAxisandDottedLineVectors=$'\ea'		# Normal Z Axis and Dotted Line Vectors
	#readonly tek4014_NormalZAxisandDot_DashedVectors=$'\eb'		# Normal Z Axis and Dot-Dashed Vectors
	#readonly tek4014_NormalZAxisandShort_DashedVectors=$'\ec'	# Normal Z Axis and Short-Dashed Vectors
	#readonly tek4014_NormalZAxisandLongDashed_Vectors=$'\ed'		# Normal Z Axis and Long-Dashed Vectors
	#readonly tek4014_DefocusedZAxisandNormalVectors=$'\eh'			# Defocused Z Axis and Normal (solid) Vectors
	#readonly tek4014_DefocusedZAxisandDottedLineVectors=$'\ei'	# Defocused Z Axis and Dotted Line Vectors
	#readonly tek4014_DefocusedZAxisandDotDashedVectors=$'\ej'	# Defocused Z Axis and Dot-Dashed Vectors
	#readonly tek4014_DefocusedZAxisandShortDashedVectors=$'\ek'	# Defocused Z Axis and Short-Dashed Vectors
	#readonly tek4014_DefocusedZAxisandLongDashedVectors=$'\el'	# Defocused Z Axis and Long-Dashed Vectors
	#readonly tek4014_WriteThruModeandNormalVectors=$'\ep'			# Write-Thru Mode and Normal (solid) Vectors
	#readonly tek4014_WriteThruModeandDottedLineVectors=$'\eq'	# Write-Thru Mode and Dotted Line Vectors
	#readonly tek4014_WriteThruModeandDotDashedVectors=$'\er'		# Write-Thru Mode and Dot-Dashed Vectors
	#readonly tek4014_WriteThruModeandShortDashedVectors=$'\es'	# Write-Thru Mode and Short-Dashed Vectors
	#readonly tek4014_WriteThruModeandLongDashedVectors=$'\et'	# Write-Thru Mode and Long-Dashed Vectors
	#readonly tek4014_PointPlotMode=$'\c\'											# Point Plot Mode (Ctrl-\)
	#readonly tek4014_GraphMode=$'\c]'													# Graph Mode (Ctrl-])
	#readonly tek4014_IncrementalPlotMode=$'\c^'								# Incremental Plot Mode (Ctrl-ˆ)
 # readonly tek4014_AlphaMode=$'\c_'													# Alpha Mode (Ctrl-_)


	

	#########################################################################
	# Procedures
	#########################################################################

	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_tek4014Funcs_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdoutN ""
						#ConsoleStdout "I    -h --help                                                                   "
						#ConsoleStdout "I             $(gettext "Display This message")                                  "
					fi
					break
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
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

	#########################################################################
	# Required Packages
	#########################################################################
	#push_element RequiredDebianPackages	<Package Name> ...
	#push_element RequiredRpmPackages			<Package Name> ...
	#push_element RequiredGentooPackages	<Package Name> ...
	#push_element RequiredSolarisPackages	<Package Name> ...
	#push_element RequiredFreeBsdPackages	<Package Name> ...
	#push_element RequiredSusePackages		<Package Name> ...

	tek4014FuncsRevision=$(CleanRevision '$Revision: 64 $')
	tek4014FuncsDescription=''
	push_element	ScriptsLoaded "tek4014Funcs.sh;${tek4014FuncsRevision};${tek4014FuncsDescription}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "template.sh" ]; then 
	ScriptRevision="${templateRevision}"

	#########################################################################
	# Procedures
	#########################################################################

	#########################################################################
	# Usage
	#########################################################################
	function Usage {
		ConsoleStdout "."
		ConsoleStdout "+=============================================================================="
		ConsoleStdout "I  ${SBaseName2} ................................................... ${ScriptRevision}"
		ConsoleStdout "+=============================================================================="
		ConsoleStdout "I " 
		ConsoleStdout "I  $(gettext "Description"):                                                     "
		ConsoleStdout "I    $(gettext "Please Enter a program description here")                        "
		ConsoleStdout "I                                                                                "
		ConsoleStdout "I  $(gettext "Usage"):                                                           "
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
	push_element ModulesArgHandlers SupportCallingFileFuncs "Set_tek4014Funcs_Flags" "Set_tek4014Funcs_exec_Flags"
	#push_element SupportedCLIOptions 
	function Set_tek4014Funcs_exec_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdoutN ""
						#ConsoleStdout "I    -h --help                                                                   "
						#ConsoleStdout "I             $(gettext "Display This message")                                  "
					fi
					break
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
					break
					;;
				-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
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
	#MainOptionArg ArgFiles "${@}"
	MainOptionArg "" "${@}"


	#########################################################################
	# MAIN PROGRAM
	#########################################################################

	echo "###############################################"
	echo "# ${SBaseName2} $(gettext "Test Module")"
	echo "###############################################"

	sNormalExit 0
fi

