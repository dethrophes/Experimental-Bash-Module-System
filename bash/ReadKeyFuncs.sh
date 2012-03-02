#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               JK Script Tools
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/ReadKeyFuncs.sh $
#+=========================================================================
#I   Copyright: Copyright (c) 2002-2012, dethrophes@web.de
#I      Author: John Kearney,                  dethrophes@web.de
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
#I  File Name            : ReadKeyFuncs.sh
#I  File Location        : scripts/bash
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: ReadKeyFuncs.sh 53 2012-02-17 13:29:00Z dethrophes $
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
#SourceCoreFiles_ "DiskFuncs.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__ReadKeyFuncs_sh__:-}" ]; then
	__ReadKeyFuncs_sh__=1
	#########################################################################
	# Module Shared Procedures
	#########################################################################
	KeyModifiers=(
		[1]=""	 [2]="S-"		[3]="A-"	 [4]="AS-"		[5]="C-"		[6]="CS-"	[7]="CA-"		[8]="CAS-"
		[9]="M-" [10]="MS-" [11]="MA-" [12]="MAS-" [13]="MC-" [14]="MCS-" [15]="MCA-" [16]="MCAS-"
		)
	KeybFntKeys=(
		[1]="home" [2]="insert" [3]="delete"	[4]="end"		[5]="pageUp" [6]="pageDown"
		[11]="f1"  [12]="f2"		[13]="f3"			[14]="f4"		[15]="f5"
		[17]="f6"  [18]="f7"		[19]="f8"			[20]="f9"		[21]="f10"
		[23]="f11" [24]="f12"		[25]="f13"		[26]="f14"	[28]="f15"
		[29]="f16" [31]="f17"		[32]="f18"		[33]="f19"	[34]="f20"
		)
	SunKeybFntKeys=(
		[214]="home"  [2]="insert" [3]="delete"	[4]="end"		[216]="pageUp" [222]="pageDown"
		[224]="f1"  [225]="f2"		[226]="f3"		[227]="f4"	[228]="f5"
		[229]="f6"  [230]="f7"		[231]="f8"		[232]="f9"	[233]="f10"
		[192]="f11" [193]="f12"		[218]="keypad-five" [220]="keypad-delete"
		)
	KeybFntKeysAlt=(
		# A          B							C								D							E										F							H					
		[0x41]="up" [0x42]="down" [0x43]="right" [0x44]="left" [0x45]="keypad-five" [0x46]="end" [0x48]="home"     
		# I								O										P						Q						R						S         		Z          
		[0x49]="InFocus" [0x4f]="OutOfFocus" [0x50]="f1" [0x51]="f2" [0x52]="f3" [0x53]="f4"  [0x5a]="S-HT"      
		)
	C0CtrlChars=(
		[0x00]="Null" [0x01]="SOH" [0x02]="STX" [0x03]="ETX" [0x04]="EOT" [0x05]="ENQ" [0x06]="ACK" 
		[0x07]="BEL"  [0x08]="BS"  [0x09]="HT"  [0x0A]="LF"  [0x0B]="VT"  [0x0C]="FF"  [0x0D]="CR"  
		[0x0E]="SO"   [0x0F]="SI"  [0x10]="DLE" [0x11]="DC1" [0x12]="DC2" [0x13]="DC3" [0x14]="DC4" 
		[0x15]="NAK"  [0x16]="SYN" [0x17]="ETB" [0x18]="CAN" [0x19]="EM"  [0x1A]="SUB" [0x1B]="ESC" 
		[0x1C]="FS"   [0x1D]="GS"  [0x1E]="RS"  [0x1F]="US"  [0x20]="SP"  [0x7F]="DEL" 
	)
	C0CtrlCharsAlt=(
		[0x01]="C-A" [0x02]="C-B" [0x03]="C-C" [0x04]="C-D" [0x05]="C-E" [0x06]="C-F" [0x07]="C-G" 
		[0x08]="C-H" [0x09]="C-I" [0x0a]="C-J" [0x0b]="C-K" [0x0c]="C-L" [0x0d]="C-M" [0x0e]="C-N"  
		[0x0f]="C-O" [0x10]="C-P" [0x11]="C-Q" [0x12]="C-R" [0x13]="C-S" [0x14]="C-T" [0x15]="C-U" 
		[0x16]="C-V" [0x17]="C-W" [0x18]="C-X" [0x19]="C-Y" [0x1a]="C-Z" [0x1b]="C-[" [0x1c]="C-]" 
		[0x1d]="C-}" [0x1e]="C-^" [0x1f]="C-_" [0x20]="C-SP" 
	)
	C1CtrlCharsEsc=(
		[0x40]="PAD"  [0x41]="HOP"	[0x42]="BPH" [0x43]="NBH"	
		[0x44]="IND"	[0x45]="NEL"	[0x46]="SSA" [0x47]="ESA"	
		[0x48]="HTS"	[0x49]="HTJ"	[0x4A]="VTS" [0x4B]="PLD"	
		[0x4C]="PLU"	[0x4D]="RI"		[0x4E]="SS2" [0x4F]="SS3"	
		[0x50]="DCS"	[0x51]="PU1"	[0x52]="PU2" [0x53]="STS"	
		[0x54]="CCH"	[0x55]="MW"		[0x56]="SPA" [0x57]="EPA"	
		[0x58]="SOS"	[0x59]="SGCI"	[0x5A]="SCI" [0x5B]="CSI"	
		[0x5C]="ST" 	[0x5D]="OSC"	[0x5E]="PM"  [0x5F]="APC"	
	)
	C1CtrlChars=(
		[0x80]="PAD"  [0x81]="HOP"	[0x82]="BPH" [0x83]="NBH"	
		[0x84]="IND"	[0x85]="NEL"	[0x86]="SSA" [0x87]="ESA"	
		[0x88]="HTS"	[0x89]="HTJ"	[0x8A]="VTS" [0x8B]="PLD"	
		[0x8C]="PLU"	[0x8D]="RI"		[0x8E]="SS2" [0x8F]="SS3"	
		[0x90]="DCS"	[0x91]="PU1"	[0x92]="PU2" [0x93]="STS"	
		[0x94]="CCH"	[0x95]="MW"		[0x96]="SPA" [0x97]="EPA"	
		[0x98]="SOS"	[0x99]="SGCI"	[0x9A]="SCI" [0x9B]="CSI"	
		[0x9C]="ST" 	[0x9D]="OSC"	[0x9E]="PM"  [0x9F]="APC"	
	)    
	C1CtrlCharsAlt=(
		[0x01]="CA-A" [0x02]="CA-B" [0x03]="CA-C" [0x04]="CA-D"  [0x05]="CA-E" [0x06]="CA-F" [0x07]="CA-G" 
		[0x08]="CA-H" [0x09]="CA-I" [0x0a]="CA-J" [0x0b]="CA-K"  [0x0c]="CA-L" [0x0d]="CA-M" [0x0e]="CA-N"  
		[0x0f]="CA-O" [0x10]="CA-P" [0x11]="CA-Q" [0x12]="CA-R"  [0x13]="CA-S" [0x14]="CA-T" [0x15]="CA-U" 
		[0x16]="CA-V" [0x17]="CA-W" [0x18]="CA-X" [0x19]="CA-Y"  [0x1a]="CA-Z" [0x1b]="CA-[" [0x1c]="CA-]" 
		[0x1d]="CA-}" [0x1e]="CA-^" [0x1f]="CA-_" [0x20]="CA-SP" [0x7F]="A-DEL" 
	)
	MouseButtons=(
		[0x00]="MB1-P" [0x01]="MB2-P" [0x02]="MB3-P" [0x03]="MB-R"
		[0x20]="MB1-M" [0x21]="MB2-M" [0x22]="MB3-M" [0x23]="MB-M"
		[0x40]="MB4-P" [0x41]="MB5-P" 
	)
	MouseMetaButtons=(
		[0x04]="S-"		 [0x08]="A-"		[0x0c]="AS-" 
		[0x10]="C-"		 [0x14]="CS-"		[0x1c]="CAS-"
	)
	function GetMouseButton {
		local MouseBtn
		AdjustMousePos MouseBtn "${2}"
		MouseBtn="${MouseMetaButtons[$(( ${MouseBtn} & 0x1C))]-}${MouseButtons[$(( ${MouseBtn} & 0xe3))]}"
		eval ${1}='"${MouseBtn}"'
	}
	declare -g mouse_on="$( vt100_DECSET "${mouse_type[1]}" )"
	declare -g mouse_off="$(vt100_DECRST "${mouse_type[1]}" )"

	DECLRP_Pevent=( 
			[0]="LocatorUnavailable" 
			[1]="request" 
			[2]="MB1-P" 
			[3]="MB1-R" 
			[4]="MB2-P" 
			[5]="MB2-R" 
			[6]="MB3-P" 
			[7]="MB3-R" 
			[8]="MB4-P" 
			[9]="MB4-R" 
			[10]="LocatorOutsideFilterRectangle" 
		)

	#########################################################################
	# Procedures
	#########################################################################

	function ReadKey {
		unset UInput[@]
		local escapeSequence 
		local REPLY 

		echo -n "${mouse_on}"
		if IFS='' read  -srN1 ${1:-} escapeSequence; then
			case "${escapeSequence}" in
				[^[:cntrl:]]) 
					UInput[0]="${escapeSequence}" 
					;;
				$'\e')
					while IFS='' read -srN1 -t0.0001 ; do
						escapeSequence+="${REPLY}"
					done
					case "${escapeSequence}" in
							$'\e'[^[:cntrl:]]) echo -n "A-${escapeSequence:1}" ;;
							${CSI}t) 
								UInput[0]="MouseTrack"
								AdjustMousePos UInput[1] "${escapeSequence:3:1}"
								AdjustMousePos UInput[2] "${escapeSequence:4:1}"
								;;
							${CSI}T) 
								UInput[0]="MouseTrack"
								AdjustMousePos UInput[1] "${escapeSequence:3:1}"
								AdjustMousePos UInput[2] "${escapeSequence:4:1}"
								AdjustMousePos UInput[3] "${escapeSequence:5:1}"
								AdjustMousePos UInput[4] "${escapeSequence:6:1}"
								AdjustMousePos UInput[5] "${escapeSequence:7:1}"
								AdjustMousePos UInput[6] "${escapeSequence:8:1}"
								;;
							${MSI}*)  
								GetMouseButton UInput[0] "${escapeSequence:3:1}"
								if [ -n "${UInput[0]}" ]; then  
									AdjustMousePos UInput[1] "${escapeSequence:4:1}"
									AdjustMousePos UInput[2] "${escapeSequence:5:1}"
								else
									UInput[0]=$(printf 'Mouse-\\x%02x %q'  "'${escapeSequence:3:1}" "${escapeSequence:4}")
								fi
								;;
							${CSI}[0-9]*t)
								local dtterm_Params=( ${escapeSequence//[!0-9]/ } )
								case "${dtterm_Params[0]}" in
									1) UInput[0]="WindowOpen" ;;
									2) UInput[0]="WindowIconified" ;;
									3) UInput[0]="WindowPos"   
									   UInput[1]="${dtterm_Params[1]}"   
									   UInput[2]="${dtterm_Params[2]}" ;;
									4) UInput[0]="WindowSizePixels"
									   UInput[1]="${dtterm_Params[1]}"   
									   UInput[2]="${dtterm_Params[2]}" ;;
									8) UInput[0]="TextAreaSizeChars"
									   UInput[1]="${dtterm_Params[1]}"   
									   UInput[2]="${dtterm_Params[2]}" ;;
									9) UInput[0]="WindowSizeChars"
									   UInput[1]="${dtterm_Params[1]}"   
									   UInput[2]="${dtterm_Params[2]}" ;;
									*) UInput[0]="dtterm ${dtterm_Params[*]} t" ;;
								esac
								;;
							${CSI}[0-9]*'&w')
								local dtterm_Params=( ${escapeSequence//[!0-9]/ } )
								UInput=( "${DECLRP_Pevent[${dtterm_Params[0]}]}" "${dtterm_Params[@]:1}" )
								;;
							${CSI}[0-9]*[ABCDEFHIOZPQRSz~])
								local CSI_Params=( ${escapeSequence//[!0-9]/ } )
								local CSI_Func="${escapeSequence:${#escapeSequence}-1}"
								#sDebugOut "CSI ${CSI_Params[*]-} ${CSI_Func}"
								case "${CSI_Func}" in
									z) # Sun Function Keys
										UInput[0]="${SunKeybFntKeys[${CSI_Params[0]}]-}"
										if [ -n "${UInput[0]}" ]; then
											UInput[0]="${KeyModifiers[${CSI_Params[1]:-1}]}${UInput[0]}"
											UInput[1]="1" # Repeat Count
										else
											UInput[0]="CSI ${CSI_Params[*]} ${CSI_Func}"
										fi
										;;
									'~') # Function Keys
										UInput[0]="${KeybFntKeys[${CSI_Params[0]}]-}"
										if [ -n "${UInput[0]}" ]; then
											UInput[0]="${KeyModifiers[${CSI_Params[1]:-1}]}${UInput[0]}"
											UInput[1]="1" # Repeat Count
										else
											UInput[0]="CSI ${CSI_Params[*]} ${CSI_Func}"
										fi
										;;
									A|B|C|D|E|F|H|I|O|Z|P|Q|R|S)
										ord CSI_Func "${CSI_Func}"
										UInput[0]="${KeybFntKeysAlt[${CSI_Func}]}"
										if [ -n "${UInput[0]}" ]; then
											UInput[0]="${KeyModifiers[${CSI_Params[1]:-1}]}${UInput[0]}"
											UInput[1]="${CSI_Params[0]:-1}" # Repeat Count
										else
											UInput[0]="CSI ${CSI_Params[*]} ${CSI_Func}"
										fi
										;;
									*)
										UInput[0]="CSI ${CSI_Params[*]} ${CSI_Func}"
										;;
								esac
								;;
							${SS3}*[ABCDEFHPQRSIO~])
								local SS3_Params=( ${escapeSequence//[!0-9]/ } )
								local SS3_Func="${escapeSequence:${#escapeSequence}-1}"
								#sDebugOut "SS3 ${SS3_Params[*]-} ${SS3_Func}"
								case "${SS3_Func}" in
									A|B|C|D|E|F|H|P|Q|R|S|~)
										ord SS3_Func "${SS3_Func}"
										UInput[0]="${KeybFntKeysAlt[${SS3_Func}]-}"
										if [ -n "${UInput[0]}" ]; then
											UInput[0]="${KeyModifiers[${SS3_Params[1]:-1}]}${UInput[0]}"
											UInput[1]="${SS3_Params[0]:-1}" # Repeat Count
										else
											UInput[0]="SS3 ${SS3_Params[*]} ${SS3_Func}"
										fi
										;;
									*)
										UInput[0]="SS3 ${SS3_Params[*]} ${SS3_Func}"
										;;
								esac
								;;
							$'\e'[[:cntrl:]])
								ord UInput[0] "${escapeSequence:1:1}"
								UInput[0]="${C1CtrlCharsAlt[${UInput[0]}]:-$(printf "%q" "${escapeSequence}")}"
								;;
							$'\e') UInput[0]="ESC" ;;
							*)
								UInput[0]="$(printf "%q" "${escapeSequence}")"
								;;
 					esac
					;;
				*)
          ord UInput[0] "${escapeSequence}"
          UInput[0]="${C0CtrlChars[${UInput[0]}]:-$(printf '%q' "'${escapeSequence}")}"
					;;
			esac
		fi
		echo -n "${mouse_off}"
	}
	function HandleKey {
		local -a UInput
		local mouse_on="$( vt100_DECSET "${mouse_type[2]}" )"
		echo -n "${mouse_on}"
		vt100_IHMT 2 3 3 20 20

		while true; do
			if ReadKey ; then
				case "${UInput[0]:-}" in
					CR|NULL|LF|q) 
						echo "\"${UInput[*]}\""
						break
						;;
					*)
						echo "\"${UInput[*]}\""
						;;
				esac
			fi
		done
	}

	


	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_ReadKeyFuncs_Flags {
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

	ReadKeyFuncsRevision=$(CleanRevision '$Revision: 53 $')
	ReadKeyFuncsDescription=''
	push_element	ScriptsLoaded "ReadKeyFuncs.sh;${ReadKeyFuncsRevision};${ReadKeyFuncsDescription}"
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
	push_element ModulesArgHandlers SupportCallingFileFuncs "Set_ReadKeyFuncs_Flags" "Set_ReadKeyFuncs_exec_Flags"
	#push_element SupportedCLIOptions 
	function Set_ReadKeyFuncs_exec_Flags {
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

