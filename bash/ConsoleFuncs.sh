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
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : ConsoleFuncs.sh
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
		source "${ScriptDir}/GenFuncs.sh" || exit
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
if [ -z "${__ConsoleFuncs_sh__:-}" ]; then
	__ConsoleFuncs_sh__=1

	
	readonly NewLine=$'\n'
	readonly Tab=$'\t'
	readonly Space=" "
	readonly ESC=$'\e'				# 

	# C1 (8-Bit) Control Characters
	# The xterm program recognizes both 8-bit and 7-bit control characters. It generates 7-bit controls (by default) or 8-bit
	# if S8C1T is enabled. The following pairs of 7-bit and 8-bit control characters are equivalent:
	S8C1T=${S8C1T:-0}
	if [ "${S8C1T:-0}" != "1" ] ; then
		# 7 bit version 
		readonly IND=$'\eD'			# Index ( IND is 0x84)
		readonly NEL=$'\eE'			# Next Line ( NEL is 0x85)
		readonly HTS=$'\eH'			# Tab Set ( HTS is 0x88)
		readonly RI=$'\eM'				# Reverse Index ( RI is 0x8d)
		readonly SS2=$'\eN'			# Single Shift Select of G2 Character Set ( SS2 is 0x8e): affects next character only
		readonly SS3=$'\eO'			# Single Shift Select of G3 Character Set ( SS3 is 0x8f): affects next character only
		readonly DCS=$'\eP'			# Device Control String ( DCS is 0x90)
		readonly SPA=$'\eV'			# Start of Guarded Area ( SPA is 0x96)
		readonly EPA=$'\eW'			# End of Guarded Area ( EPA is 0x97)
		readonly SOS=$'\eX'			# Start of String ( SOS is 0x98)
		readonly DECID=$'\eZ'		# Return Terminal ID (DECID is 0x9a). Obsolete form of CSI c (DA).
		readonly CSI=$'\e['			# Control Sequence Introducer ( CSI is 0x9b)
		readonly ST=$'\e\\'			# String Terminator ( ST is 0x9c)
		readonly OSC=$'\e]'			# Operating System Command ( OSC is 0x9d)
		readonly PM=$'\e^'				# Privacy Message ( PM is 0x9e) take a single string of text, terminated by ST 
		readonly APC=$'\e_'			# Application Program Command ( APC is 0x9f)  take a single string of text, terminated by ST 
	else
		# 8 bit version 
		readonly IND=$'\x84'			# Index ( IND is 0x84)
		readonly NEL=$'\x85'			# Next Line ( NEL is 0x85)
		readonly HTS=$'\x88'			# Tab Set ( HTS is 0x88)
		readonly RI=$'\x8d'			# Reverse Index ( RI is 0x8d)
		readonly SS2=$'\x8e'			# Single Shift Select of G2 Character Set ( SS2 is 0x8e): affects next character only
		readonly SS3=$'\x8f'			# Single Shift Select of G3 Character Set ( SS3 is 0x8f): affects next character only
		readonly DCS=$'\x90'			# Device Control String ( DCS is 0x90)
		readonly SPA=$'\x96'			# Start of Guarded Area ( SPA is 0x96)
		readonly EPA=$'\x97'			# End of Guarded Area ( EPA is 0x97)
		readonly SOS=$'\x98'			# Start of String ( SOS is 0x98)
		readonly DECID=$'\x9a'		# Return Terminal ID (DECID is 0x9a). Obsolete form of CSI c (DA).
		readonly CSI=$'\x9b'			# Control Sequence Introducer ( CSI is 0x9b)
		readonly ST=$'\x9c'			# String Terminator ( ST is 0x9c)
		readonly OSC=$'\x9d'			# Operating System Command ( OSC is 0x9d)
		readonly PM=$'\x9e'			# Privacy Message ( PM is 0x9e) take a single string of text, terminated by ST 
		readonly APC=$'\x9f'			# Application Program Command ( APC is 0x9f)  take a single string of text, terminated by ST 
	fi

	SourceCoreFiles_ vt100Funcs.sh
	#SourceCoreFiles_ vt52Funcs.sh
	#SourceCoreFiles_ tek4014Funcs.sh

	if [[ ${TERM:-xterm} != xterm* ]] ; then 
		function tputwrapper {
			tput -T ${TERM:-xterm} -S <<EOF 
				${1}
EOF
		}
		function xterm_ColorAttrib {
			local VarName=${1:?Missing Variable Name}
			local CAttribs=
			while shift && [ $# -gt 0 ]; do 
				case "${1}" in
					Default)							CAttribs+="sgr0${NewLine}"		;;
					Bold)									CAttribs+="bold${NewLine}"		;;
					Dim)									CAttribs+="dim${NewLine}"		;;
					Underscore)						CAttribs+="smul${NewLine}"		;;
					Blink)								CAttribs+="blink${NewLine}"	;;
					Inverse)							CAttribs+="rev${NewLine}"		;;
					Conceal)							CAttribs+="invis${NewLine}"	;;
					FG_Black)							CAttribs+="setaf 0${NewLine}" ;;
					FG_Red)								CAttribs+="setaf 1${NewLine}" ;;
					FG_Green)							CAttribs+="setaf 2${NewLine}" ;;
					FG_Brown)							CAttribs+="setaf 3${NewLine}" ;;
					FG_Blue)							CAttribs+="setaf 4${NewLine}" ;;
					FG_Purple)						CAttribs+="setaf 5${NewLine}" ;;
					FG_Cyan)							CAttribs+="setaf 6${NewLine}" ;;
					FG_LightGray)					CAttribs+="setaf 7${NewLine}" ;;
					FG_Default)						CAttribs+="setaf 9${NewLine}" ;;
					BG_Black)							CAttribs+="setab 0${NewLine}" ;;
					BG_Red)								CAttribs+="setab 1${NewLine}" ;;
					BG_Green)							CAttribs+="setab 2${NewLine}" ;;
					BG_Brown)							CAttribs+="setab 3${NewLine}" ;;
					BG_Blue)							CAttribs+="setab 4${NewLine}" ;;
					BG_Purple)						CAttribs+="setab 5${NewLine}" ;;
					BG_Cyan)							CAttribs+="setab 6${NewLine}" ;;
					BG_LightGray)					CAttribs+="setab 7${NewLine}" ;;
					BG_Default)						CAttribs+="setab 9${NewLine}" ;;
					*)
						sError_Exit 4 "$(gettext "Invalid xterm Attribute ") ${1}"
						;;
				esac
			done
			eval ${VarName}'="$(tputwrapper "${CAttribs}")"'
		}
	else

		function xterm_ColorAttrib {
			local VarName=${1:?Missing Variable Name}
			local CAttribs=
			while shift && [ $# -gt 0 ]; do 
				case "${1}" in
					[0-9]|[0-9][0-9]|[0-9][0-9][0-9]) CAttribs+="${1};" ;; 
					Default)							CAttribs+="0;" ;;
					Bold)									CAttribs+="1;" ;;
					Dim)									CAttribs+="2;" ;;
					Underscore)						CAttribs+="4;" ;;
					Blink)								CAttribs+="5;" ;;
					Inverse)							CAttribs+="7;" ;;
					Conceal)							CAttribs+="8;" ;;
					FG_Black)							CAttribs+="30;" ;;
					FG_Red)								CAttribs+="31;" ;;
					FG_Green)							CAttribs+="32;" ;;
					FG_Brown)							CAttribs+="33;" ;;
					FG_Blue)							CAttribs+="34;" ;;
					FG_Purple)						CAttribs+="35;" ;;
					FG_Cyan)							CAttribs+="36;" ;;
					FG_LightGray)					CAttribs+="37;" ;;
					FG_Default)						CAttribs+="39;" ;;
					BG_Black)							CAttribs+="40;" ;;
					BG_Red)								CAttribs+="41;" ;;
					BG_Green)							CAttribs+="42;" ;;
					BG_Brown)							CAttribs+="43;" ;;
					BG_Blue)							CAttribs+="44;" ;;
					BG_Purple)						CAttribs+="45;" ;;
					BG_Cyan)							CAttribs+="46;" ;;
					BG_LightGray)					CAttribs+="47;" ;;
					BG_Default)						CAttribs+="49;" ;;
					*)
						sError_Exit 4 "$(gettext "Invalid xterm Attribute ") ${1}"
						;;
				esac
			done
			printf -v ${VarName} "${CSI}${CAttribs:0:-1}m"
		}
	fi
	{
		#
		# Other CAttribs
		#
		xterm_ColorAttrib	NO_COLOUR					Default
		#printf "%s=%q\n" NO_COLOUR ${NO_COLOUR}
		xterm_ColorAttrib	ATTRIB_Bold				Bold
		xterm_ColorAttrib	ATTRIB_Dim				Dim
		xterm_ColorAttrib	ATTRIB_Underscore	Underscore
		xterm_ColorAttrib	ATTRIB_Blink			Blink
		xterm_ColorAttrib	ATTRIB_Inverse		Inverse
		xterm_ColorAttrib	ATTRIB_Conceal		Conceal
		#
		# Foreground Colors
		#
		xterm_ColorAttrib	FG_Black				Dim 	FG_Black					
		xterm_ColorAttrib	FG_Red					Dim 	FG_Red			
		xterm_ColorAttrib	FG_Green				Dim 	FG_Green		
		xterm_ColorAttrib	FG_Brown				Dim 	FG_Brown		
		#printf "%s=%q\n" FG_Brown ${FG_Brown}
		xterm_ColorAttrib	FG_Blue					Dim 	FG_Blue			
		xterm_ColorAttrib	FG_Purple				Dim 	FG_Purple		
		xterm_ColorAttrib	FG_Cyan					Dim 	FG_Cyan			
		xterm_ColorAttrib	FG_LightGray		Dim 	FG_LightGray
		xterm_ColorAttrib	FG_Default			Dim 	FG_Default	
		#
		# Bold Foreground Colors
		#
		xterm_ColorAttrib	FG_DarkGray			Bold 	FG_Black		
		xterm_ColorAttrib	FG_LightRed			Bold 	FG_Red			
		xterm_ColorAttrib	FG_LightGreen		Bold 	FG_Green		
		xterm_ColorAttrib	FG_Yellow				Bold 	FG_Brown		
		xterm_ColorAttrib	FG_LightBlue		Bold 	FG_Blue			
		xterm_ColorAttrib	FG_LightPurple	Bold 	FG_Purple		
		xterm_ColorAttrib	FG_LightCyan		Bold 	FG_Cyan			
		xterm_ColorAttrib	FG_White				Bold 	FG_LightGray
		#                                
		# Backround Colors
		#
		xterm_ColorAttrib	BG_Black			BG_Black		 	
		xterm_ColorAttrib	BG_Red				BG_Red			 	
		xterm_ColorAttrib	BG_Green			BG_Green		 	
		xterm_ColorAttrib	BG_Brown			BG_Brown		 	
		xterm_ColorAttrib	BG_Blue				BG_Blue			 	
		xterm_ColorAttrib	BG_Purple			BG_Purple		 	
		xterm_ColorAttrib	BG_Cyan				BG_Cyan			 	
		xterm_ColorAttrib	BG_LightGray	BG_LightGray	
		xterm_ColorAttrib	BG_Default		Default BG_Default	 	
	}

	function ConsoleStdoutExpand {
		echo -e "${@}"
	}
	function ConsoleErroutExpand {
		echo -e "${@}" >&2
	}
	function ConsoleStdout {
		echo "${@}"
	}
	function ConsoleStdoutN {
		echo -n "${@}"
	}
	function ConsoleStdoutEN {
		echo -en "${@}"
	}
	function ConsoleErrout {
		echo "${@}" >&2
	}
	function ConsoleErroutExpand {
		echo -e "${@}" >&2
	}
  
	ConsoleFuncsRevision=$(CleanRevision '$Revision: 64 $')
	ConsoleFuncsDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "ConsoleFuncs.sh;${ConsoleFuncsRevision};${ConsoleFuncsDescription}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "ConsoleFuncs.sh" ]; then 
	ScriptRevision="${ConsoleFuncsRevision}"

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
	push_element ModulesArgHandlers SupportCallingFileFuncs
	#push_element SupportedCLIOptions
	MainOptionArg "" "${@}"

	#########################################################################
	# MAIN PROGRAM
	#########################################################################
	xterm_ColorAttrib TitleAttribs Bold FG_Black BG_Black
	echo "${TitleAttribs}###############################################"
	echo "${TitleAttribs}# ${SBaseName2} Test Module"
	echo "${TitleAttribs}###############################################"
	Text='gYw'   # The test text

	BGCols=( "BG_Black" "BG_Red" "BG_Green" "BG_Brown" "BG_Blue" "BG_Purple" "BG_Cyan" "BG_LightGray" "BG_Default")
	FGCols=( "FG_Black" "FG_DarkGray" "FG_Red" "FG_LightRed" "FG_Green" "FG_LightGreen" "FG_Brown" "FG_Yellow"  
						"FG_Blue" "FG_LightBlue" "FG_Purple" "FG_LightPurple" "FG_Cyan" "FG_LightCyan" "FG_White" "FG_LightGray"
						"NO_COLOUR" "ATTRIB_Underscore" "ATTRIB_Inverse" "ATTRIB_Conceal" "ATTRIB_Dim" "ATTRIB_Bold" "ATTRIB_Blink" "FG_Default")
	printf	"${NO_COLOUR}%-14.14s %-9.9s" "" "No BG"
	for BG in ${BGCols[@]}; do
		printf " %-9.9s" "${BG}"
	done
	echo;
	for FGs in ${FGCols[@]}; do 
		printf "${NO_COLOUR}%-14.14s ${!FGs}%-9.9s${NO_COLOUR}" "${FGs}" "${Text}"
		for BG in ${BGCols[@]}; do
			printf " ${!FGs}${!BG}%-9.9s${NO_COLOUR}" "${Text}"
		done
		echo;
	done
	echo;

	sNormalExit 0
fi
