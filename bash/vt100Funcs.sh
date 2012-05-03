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
#I              File Name            : vt100Funcs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : vt100Funcs.sh
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

if [ -z "${__vt100Funcs_sh__:-}" ]; then
	__vt100Funcs_sh__=1
	#########################################################################
	# Module Shared Procedures
	#########################################################################

	readonly MSI="${CSI}M"		# Mouse Sequence Introducer

	#	Controls beginning with ESC (other than those where ESC is part of a 7-bit equivalent to 8-bit C1 controls),
	#	ordered by the final character(s).	
	readonly vt100_S7CIT=$'\e F'		# 7-bit controls (S7C1T).
	readonly vt100_S8CIT=$'\e G'		# 8-bit controls (S8C1T).
	readonly vt100_SACL1=$'\e L'		# Set ANSI conformance level 1 (dpANS X3.134.1).
	readonly vt100_SACL2=$'\e M'		# Set ANSI conformance level 2 (dpANS X3.134.1).
	readonly vt100_SACL3=$'\e N'		# Set ANSI conformance level 3 (dpANS X3.134.1).
	readonly vt100_DECDHL_th=$'\e#3'	# DEC double-height line, top half (DECDHL)
	readonly vt100_DECDHL_bh=$'\e#4'	# DEC double-height line, bottom half (DECDHL)
	readonly vt100_DECSWL=$'\e#5'	# DEC single-width line (DECSWL)
	readonly vt100_DECDWL=$'\e#6'	# DEC double-width line (DECDWL)
	readonly vt100_DECALN=$'\e#8'	# DEC Screen Alignment Test (DECALN)
	readonly vt100_SDCS=$'\e%@'		#	Select default character set, ISO 8859-1 (ISO 2022)
	readonly vt100_SUTF8=$'\e%G'		# Select UTF-8 character set (ISO 2022)
	readonly vt100_DG0CS=$'\e(C'		# Designate G0 Character Set (ISO 2022)
	readonly vt100_DG1CS=$'\e)C'		# Designate G1 Character Set (ISO 2022)
	readonly vt100_DG2CS=$'\e*C'		# Designate G2 Character Set (ISO 2022)
	readonly vt100_DG3CS=$'\e+C'		# Designate G3 Character Set (ISO 2022)
																	# 		Final character C for designating character sets ( 0 , A and B apply to VT100 and
																	# 		up, the remainder to VT220 and up):
																	#			C = 0 ® DEC Special Character and Line Drawing Set
																	# 		C = A ® United Kingdom (UK)
																	# 		C = B ® United States (USASCII)
																	# 		C = 4 ® Dutch
																	# 		C = C or 5 ® Finnish
																	# 		C = R ® French
																	# 		C = Q ® French Canadian
																	# 		C = K ® German
																	# 		C = Y ® Italian
																	# 		C = E or 6 ® Norwegian/Danish
																	# 		C = Z ® Spanish
																	# 		C = H or 7 ® Swedish
																	# 		C = = ® Swiss
	readonly vt100_DECSC=$'\e7'	# Save Cursor (DECSC)
	readonly vt100_DECRC=$'\e8'	# Restore Cursor (DECRC)
	readonly vt100_DECPAM=$'\e='	# Application Keypad (DECPAM)
	readonly vt100_DECPNM=$'\e>'	# Normal Keypad (DECPNM)
	readonly vt100_CLLC=$'\eF'		# Cursor to lower left corner of screen (if enabled by the hpLowerleftBugCompat resource).
	readonly vt100_RIS=$'\ec'		# Full Reset (RIS)
	readonly vt100_MLOCK=$'\el'	# Memory Lock (per HP terminals). Locks memory above the cursor.
	readonly vt100_MULOCK=$'\em'	# Memory Unlock (per HP terminals)
	readonly vt100_LS2=$'\en'		# Invoke the G2 Character Set as GL (LS2).
	readonly vt100_LS3=$'\eo'		# Invoke the G3 Character Set as GL (LS3).
	readonly vt100_LS3R=$'\e|'		# Invoke the G3 Character Set as GR (LS3R).
	readonly vt100_LS2R=$'\e}'		# Invoke the G2 Character Set as GR (LS2R).
	readonly vt100_LS1R=$'\e˜'		# Invoke the G1 Character Set as GR (LS1R).

	# Application Program-Control functions
	# APC Pt ST xterm implements no APC functions; Pt is ignored. Pt need not be printable characters.
	function	vt100_APC {	echo -n "${APC}${1:?Missing Pt}${ST}";	}

	# Device-Control functions
	# DCS Ps ; Ps | Pt ST User-Defined Keys (DECUDK). The first parameter:
	#											Ps = 0 ® Clear all UDK definitions before starting (default)
	#											Ps = 1 ® Erase Below (default)
	# 										The second parameter:
	# 										Ps = 0 ® Lock the keys (default)
	# 										Ps = 1 ® Do not lock.
	# 										The third parameter is a ’;’-separated list of strings denoting the key-code separated by a
	# 										’/’ from the hex-encoded key value. The key codes correspond to the DEC function-key
	# 										codes (e.g., F6=17).
	function vt100_DECUDK {
	  IFS=';' eval 'echo -n "${DCS}${1:?Missing Ps};${2:?Missing Ps}|${*:3}${ST}"'
	}
	# DCS $ q Pt ST Request Status String (DECRQSS). The string following the "q" is one of the following:
	# 							“ q ® DECSCA
	# 							“ p ® DECSCL
	# 							r ® DECSTBM
	# 							m ® SGR
	# 							xterm responds with DCS 1 $ r Pt ST for valid requests, replacing the Pt with the
	# 							corresponding CSI string, or DCS 0 $ r Pt ST for invalid requests.
	function vt100_DECRQSS {
		local Arg
		case "${1:?Missing Pt}" in
			DECSCA)		Arg='“q' ;;
			DECSCL)		Arg='“p' ;;
			DECSTBM)	Arg='r' ;;
			SGR)			Arg='m' ;;
			*) return 1 ;;
		esac
	  echo -n "${DCS}\$q${Arg}${ST}"
	}


	function vt100_EncodeStrings_hexadecimal {
		while [ $# -gt 0 ]; do
			local -i idx
			for (( idx=0; $idx<${#1}; idx++ )) ; do 
				printf '%02x' "'${1:${idx}:1}"
			done
			shift 
			[ $# -gt 0 ] && echo -n ";"
		done
		return 0
	}
	function vt100_DecodeStrings_hexadecimal {
		_RETURN=( )
		local -i idx
		local -i Arg=0

		for (( idx=0; $idx<${#1}; idx++ )) ; do 
			case "${1:${idx}:2}" in 
				[0-9a-zA-Z][0-9a-zA-Z])
					_RETURN[${Arg}]+="$(echo -en "\\x${1:${idx}:2}")"
				 	idx+=1
					;;
				=*) _RETURN[${Arg}]+="=" ;;
				';'*) Arg+=1 ;;
				*) return 1 ;;
			esac
		done
		return 0
	}

	# DCS + q Pt ST Request Termcap/Terminfo String (xterm, experimental). The string following the "q" is
	# 							a list of names encoded in hexadecimal (2 digits per character) separated by ; which
	# 							correspond to termcap or terminfo key names.
	# 							xterm responds with DCS 1 + r Pt ST for valid requests, adding to Pt an = , and
	# 							the value of the corresponding string that xterm would send, or DCS 0 + r Pt ST
	# 							for invalid requests. The strings are encoded in hexadecimal (2 digits per character).	
	function vt100_ReqTermcapStr {
		echo -n "${DCS}+q$(vt100_EncodeStrings_hexadecimal "${@?Missing Pt}")${ST}"
		#ReceiveCmd2 "${ST}" #"${DCS}1+r" "${DCS}1+r"
		#echo "REPLY=$(CreateEscapedArgList3 "${REPLY}")"
	}
	function vt100_ReqTermcapStr_test {
		vt100_ReqTermcapStr "${@}"
		ReceiveCmd2 "${ST}" #"${DCS}1+r" "${DCS}1+r"
		echo "REPLY=$(CreateEscapedArgList3 "${REPLY}")"
	}

	# Functions using CSI , ordered by the final character(s)
	# CSI Ps @ Insert Ps (Blank)
	#  Character(s) (default = 1) (ICH)
	function	vt100_ICH { echo -n "${CSI}${1-}@"; }
	# CSI Ps A Cursor Up Ps Times (default = 1) (CUU)
	function	vt100_CUU { echo -n "${CSI}${1-}A"; }

	# CSI Ps B Cursor Down Ps Times (default = 1) (CUD)
	function	vt100_CUD { echo -n "${CSI}${1-}B"; }

	# CSI Ps C Cursor Forward Ps Times (default = 1) (CUF)
	function	vt100_CUF { echo -n "${CSI}${1-}C"; }

	# CSI Ps D Cursor Backward Ps Times (default = 1) (CUB)
	function	vt100_CUB { echo -n "${CSI}${1-}D"; }

	# CSI Ps E Cursor Next Line Ps Times (default = 1) (CNL)
	function	vt100_CNL { echo -n "${CSI}${1-}E"; }

	# CSI Ps F Cursor Preceding Line Ps Times (default = 1) (CPL)
	function	vt100_CPL { echo -n "${CSI}${1-}F"; }

	# CSI Ps G Cursor Character Absolute [column] (default = [row,1]) (CHA)
	function	vt100_CHA { echo -n "${CSI}${1-}G"; }

	# CSI Ps ; Ps H Cursor Position [row;column] (default = [1,1]) (CUP)
	function	vt100_CUP { echo -n "${CSI}${1:?Missing row};${2:?Missing column}H"; }

	# CSI Ps I Cursor Forward Tabulation Ps tab stops (default = 1) (CHT)
	function	vt100_CHT { echo -n "${CSI}${1-}I"; }

	# CSI Ps J Erase in Display (ED)
	# 		Ps = 0 ® Erase Below (default)
	# 		Ps = 1 ® Erase Above
	# 		Ps = 2 ® Erase All
	# 		Ps = 3 ® Erase Saved Lines (xterm)
	function	vt100_ED { echo -n "${CSI}${1-}J"; }

	#	CSI ? Ps J Erase in Display (DECSED)
	# 		Ps = 0 ® Selective Erase Below (default)
	# 		Ps = 1 ® Selective Erase Above
	# 		Ps = 2 ® Selective Erase All
	function	vt100_DECSED {	echo -n "${CSI}?${1-}J";	}

	# CSI Ps K Erase in Line (EL)
	# 		Ps = 0 ® Erase to Right (default)
	# 		Ps = 1 ® Erase to Left
	# 		Ps = 2 ® Erase All
	function	vt100_EL {	echo -n "${CSI}${1-}K";	}

	# CSI ? Ps K Erase in Line (DECSEL)
	# 		Ps = 0 ® Selective Erase to Right (default)
	# 		Ps = 1 ® Selective Erase to Left
	# 		Ps = 2 ® Selective Erase All
	function	vt100_DECSEL {	echo -n "${CSI}?${1-}K";	}

	# CSI Ps L Insert Ps Line(s) (default = 1) (IL)
	function	vt100_IL {	echo -n "${CSI}${1-}L";	}

	# CSI Ps M Delete Ps Line(s) (default = 1) (DL)
	function	vt100_DL {	echo -n "${CSI}${1-}M";	}

	# CSI Ps P Delete Ps Character(s) (default = 1) (DCH)
	function	vt100_DCH {	echo -n "${CSI}${1-}P";	}

	# CSI Ps S Scroll up Ps lines (default = 1) (SU)
	function	vt100_SU {	echo -n "${CSI}${1-}S";	}

	# CSI Ps T Scroll down Ps lines (default = 1) (SD)
	function	vt100_SD {	echo -n "${CSI}${1-}T";	}

	# CSI Ps ; Ps ; Ps ; Ps ; Ps T
	# 		Initiate highlight mouse tracking. Parameters are [func;startx;starty;firstrow;lastrow].
	# 		See the section Mouse Tracking.
	function	vt100_IHMT {	echo -n "${CSI}${1:?Missing func};${2:?Missing startx};${3:?Missing starty};${4:?Missing firstrow};${5:?Missing lastrow}T";	}
	# CSI Ps X Erase Ps Character(s) (default = 1) (ECH)
	function	vt100_ECH {	echo -n "${CSI}${1-}X";	}

	# CSI Ps Z Cursor Backward Tabulation Ps tab stops (default = 1) (CBT)
	function	vt100_CBT {	echo -n "${CSI}${1-}Z";	}

	# CSI Pm ` Character Position Absolute [column] (default = [row,1]) (HPA)
	function	vt100_HPA {	
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}\`'
	}

	# CSI Ps b Repeat the preceding graphic character Ps times (REP)
	function	vt100_REP {	echo -n "${CSI}${1:?Missing Ps}b";	}

	# CSI Ps c Send Device Attributes (Primary DA)
	# 		Ps = 0 or omitted ® request attributes from terminal. The response depends on the
	# 		decTerminalID resource setting.
	# 		® CSI ? 1 ; 2 c (‘‘VT100 with Advanced Video Option’’)
	# 		® CSI ? 1 ; 0 c (‘‘VT101 with No Options’’)
	# 		® CSI ? 6 c (‘‘VT102’’)
	# 		® CSI ? 6 0 ; 1 ; 2 ; 6 ; 8 ; 9 ; 1 5 ; c
	# 		(‘‘VT220’’)
	# 		The VT100-style response parameters do not mean anything by themselves. VT220
	# 		parameters do, telling the host what features the terminal supports:
	# 		® 1 132-columns
	# 		® 2 Printer
	# 		® 6 Selective erase
	# 		® 8 User-defined keys
	# 		® 9 National replacement character sets
	# 		® 1 5 Technical characters
	# 		® 2 2 ANSI color, e.g., VT525
	# 		® 2 9 ANSI text locator (i.e., DEC Locator mode)
	function	vt100_SDA_PDA {	echo -n "${CSI}${1-}c";	}

	# CSI > Ps c Send Device Attributes (Secondary DA)
	# 		Ps = 0 or omitted ® request the terminal’s identification code. The response depends
	# 		on the decTerminalID resource setting. It should apply only to VT220 and up, but xterm
	# 		extends this to VT100.
	# 		® CSI > Pp ; Pv ; Pc c
	# 		where Pp denotes the terminal type
	# 		® 0 (‘‘VT100’’)
	# 		® 1 (‘‘VT220’’)
	# 		and Pv is the firmware version (for xterm, this is the XFree86 patch number, starting with
	# 		95). In a DEC terminal, Pc indicates the ROM cartridge registration number and is always
	# 		zero.
	function	vt100_SDA_SDA {	echo -n "${CSI}>${1-}c";	}
	
	# CSI Pm d Line Position Absolute [row] (default = [1,column]) (VPA)
	function	vt100_VPA {	
		IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}d'	
	}
	
	# CSI Ps ; Ps f Horizontal and Vertical Position [row;column] (default = [1,1]) (HVP)
	function	vt100_HVP {	echo -n "${CSI}${1:?Missing Ps};${2:?Missing Ps}@";	}

	# CSI Ps g Tab Clear (TBC)
	# 		Ps = 0 ® Clear Current Column (default)
	# 		Ps = 3 ® Clear All
	function	vt100_VPA {	
		IFS=';' eval 'echo -n "${CSI}?${*-}\`'	
	}

	# CSI Pm h Set Mode (SM)
	# 		Ps = 2 ® Keyboard Action Mode (AM)
	# 		Ps = 4 ® Insert Mode (IRM)
	# 		Ps = 1 2 ® Send/receive (SRM)
	# 		Ps = 2 0 ® Automatic Newline (LNM)
	function	vt100_SM {	
		IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}\`'	
	}


	# CSI ? Pm h DEC Private Mode Set (DECSET)
	# 		Ps = 1 ® Application Cursor Keys (DECCKM)
	# 		Ps = 2 ® Designate USASCII for character sets G0-G3 (DECANM), and set VT100
	# 		mode.
	# 		Ps = 3 ® 132 Column Mode (DECCOLM)
	# 		Ps = 4 ® Smooth (Slow) Scroll (DECSCLM)
	# 		Ps = 5 ® Reverse Video (DECSCNM)
	# 		Ps = 6 ® Origin Mode (DECOM)
	# 		Ps = 7 ® Wraparound Mode (DECAWM)
	# 		Ps = 8 ® Auto-repeat Keys (DECARM)
	# 		Ps = 9 ® Send Mouse X & Y on button press. See the section Mouse Tracking.
	# 		Ps = 1 0 ® Show toolbar (rxvt)
	# 		Ps = 1 2 ® Start Blinking Cursor (att610)
	# 		Ps = 1 8 ® Print form feed (DECPFF)
	# 		Ps = 1 9 ® Set print extent to full screen (DECPEX)
	# 		Ps = 2 5 ® Show Cursor (DECTCEM)
	# 		Ps = 3 0 ® Show scrollbar (rxvt).
	# 		Ps = 3 5 ® Enable font-shifting functions (rxvt).
	# 		Ps = 3 8 ® Enter Tektronix Mode (DECTEK)
	# 		Ps = 4 0 ® Allow 80 ¬® 132 Mode
	# 		Ps = 4 1 ® more(1) fix (see curses resource)
	# 		Ps = 4 2 ® Enable Nation Replacement Character sets (DECNRCM)
	# 		Ps = 4 4 ® Turn On Margin Bell
	# 		Ps = 4 5 ® Reverse-wraparound Mode
	# 		Ps = 4 6 ® Start Logging (normally disabled by a compile-time option)
	# 		Ps = 4 7 ® Use Alternate Screen Buffer (unless disabled by the titeInhibit
	# 		resource)
	# 		Ps = 6 6 ® Application keypad (DECNKM)
	# 		Ps = 6 7 ® Backarrow key sends backspace (DECBKM)
	# 		Ps = 1 0 0 0 ® Send Mouse X & Y on button press and release. See the section
	# 		Mouse Tracking.
	# 		Ps = 1 0 0 1 ® Use Hilite Mouse Tracking.
	# 		Ps = 1 0 0 2 ® Use Cell Motion Mouse Tracking.
	# 		Ps = 1 0 0 3 ® Use All Motion Mouse Tracking.
	# 		Ps = 1 0 1 0 ® Scroll to bottom on tty output (rxvt).
	# 		Ps = 1 0 1 1 ® Scroll to bottom on key press (rxvt).
	# 		Ps = 1 0 3 5 ® Enable special modifiers for Alt and NumLock keys.
	# 		Ps = 1 0 3 6 ® Send ESC when Meta modifies a key (enables the metaSendsEscape
	# 		resource).
	# 		Ps = 1 0 3 7 ® Send DEL from the editing-keypad Delete key
	# 		Ps = 1 0 4 7 ® Use Alternate Screen Buffer (unless disabled by the titeInhibit
	# 		resource)
	# 		Ps = 1 0 4 8 ® Save cursor as in DECSC (unless disabled by the titeInhibit
	# 		resource)
	# 		Ps = 1 0 4 9 ® Save cursor as in DECSC and use Alternate Screen Buffer,
	# 		clearing it first (unless disabled by the titeInhibit resource). This combines the effects of
	# 		the 1 0 4 7 and 1 0 4 8 modes. Use this with terminfo-based applications
	# 		rather than the 4 7 mode.
	# 		Ps = 1 0 5 1 ® Set Sun function-key mode.
	# 		Ps = 1 0 5 2 ® Set HP function-key mode.
	# 		Ps = 1 0 5 3 ® Set SCO function-key mode.
	# 		Ps = 1 0 6 0 ® Set legacy keyboard emulation (X11R6).
	# 		Ps = 1 0 6 1 ® Set Sun/PC keyboard emulation of VT220 keyboard.
	# 		Ps = 2 0 0 4 ® Set bracketed paste mode.
	function	vt100_DECSET {	
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}h"'
	}
	mouse_type=(
				[0]=9     ## X10 mouse reporting, for compatibility with X10's xterm, reports on button press.
				[1]=1000  ## X11 mouse reporting, reports on button press and release.
				[2]=1001  ## highlight reporting, useful for reporting mouse highlights
				[3]=1002  ## button movement reporting, reports movement when a button is presse
				[4]=1003  ## all movement reporting, reports all movements.
				[5]=1004  ## FocusIn/FocusOut can be combined with any of the mouse events since it uses a different protocol. When set, it causes xterm to send CSI I when the terminal gains focus, and CSI O when it loses focus.
				[6]=1005  ## Extended mouse mode enables UTF-8 encoding for C x and C y under all tracking modes, expanding the maximum encodable position from 223 to 2015. For positions less than 95, the resulting output is identical under both modes. Under extended mouse mode, positions greater than 95 generate "extra" bytes which will confuse applications which do not treat their input as a UTF-8 stream. Likewise, C b will be UTF-8 encoded, to reduce confusion with wheel mouse events.
		)
	# CSI Pm i Media Copy (MC)
	# 		Ps = 0 ® Print screen (default)
	# 		Ps = 4 ® Turn off printer controller mode
	# 		Ps = 5 ® Turn on printer controller mode
	function	vt100_MC {	
	  IFS=';' eval 'echo -n "${CSI}?${*Missing Pm}i"'
	}
	# CSI ? Pm i Media Copy (MC, DEC-specific)
	# 		Ps = 1 ® Print line containing cursor
	# 		Ps = 4 ® Turn off autoprint mode
	# 		Ps = 5 ® Turn on autoprint mode
	# 		Ps = 1 0 ® Print composed display, ignores DECPEX
	# 		Ps = 1 1 ® Print all pages
	function	vt100_DECMC {	
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}i"'
	}
	# CSI Pm l Reset Mode (RM)
	# 		Ps = 2 ® Keyboard Action Mode (AM)
	# 		Ps = 4 ® Replace Mode (IRM)
	# 		Ps = 1 2 ® Send/receive (SRM)
	# 		Ps = 2 0 ® Normal Linefeed (LNM)
	function	vt100_RM {	
	  IFS=';' eval 'echo -n "${CSI}?${*Missing Pm}l"'
	}
	# CSI ? Pm l DEC Private Mode Reset (DECRST)
	# 		Ps = 1 ® Normal Cursor Keys (DECCKM)
	# 		Ps = 2 ® Designate VT52 mode (DECANM).
	# 		Ps = 3 ® 80 Column Mode (DECCOLM)
	# 		Ps = 4 ® Jump (Fast) Scroll (DECSCLM)
	# 		Ps = 5 ® Normal Video (DECSCNM)
	# 		Ps = 6 ® Normal Cursor Mode (DECOM)	# 		Ps = 6 ® Normal Cursor Mode (DECOM)
	# 		Ps = 7 ® No Wraparound Mode (DECAWM)
	# 		Ps = 8 ® No Auto-repeat Keys (DECARM)
	# 		Ps = 9 ® Don’t Send Mouse X & Y on button press
	# 		Ps = 1 0 ® Hide toolbar (rxvt)
	# 		Ps = 1 2 ® Stop Blinking Cursor (att610)
	# 		Ps = 1 8 ® Don’t print form feed (DECPFF)
	# 		Ps = 1 9 ® Limit print to scrolling region (DECPEX)
	# 		Ps = 2 5 ® Hide Cursor (DECTCEM)
	# 		Ps = 3 0 ® Don’t show scrollbar (rxvt).
	# 		Ps = 3 5 ® Disable font-shifting functions (rxvt).
	# 		Ps = 4 0 ® Disallow 80 ¬® 132 Mode
	# 		Ps = 4 1 ® No more(1) fix (see curses resource)
	# 		Ps = 4 2 ® Disable Nation Replacement Character sets (DECNRCM)
	# 		Ps = 4 4 ® Turn Off Margin Bell
	# 		Ps = 4 5 ® No Reverse-wraparound Mode
	# 		Ps = 4 6 ® Stop Logging (normally disabled by a compile-time option)
	# 		Ps = 4 7 ® Use Normal Screen Buffer
	# 		Ps = 6 6 ® Numeric keypad (DECNKM)
	# 		Ps = 6 7 ® Backarrow key sends delete (DECBKM)
	# 		Ps = 1 0 0 0 ® Don’t Send Mouse X & Y on button press and release. See
	# 		the section Mouse Tracking.
	# 		Ps = 1 0 0 1 ® Don’t Use Hilite Mouse Tracking
	# 		Ps = 1 0 0 2 ® Don’t Use Cell Motion Mouse Tracking
	# 		Ps = 1 0 0 3 ® Don’t Use All Motion Mouse Tracking
	# 		Ps = 1 0 1 0 ® Don’t scroll to bottom on tty output (rxvt).
	# 		Ps = 1 0 1 1 ® Don’t scroll to bottom on key press (rxvt).
	# 		Ps = 1 0 3 5 ® Disable special modifiers for Alt and NumLock keys.
	# 		Ps = 1 0 3 6 ® Don’t send ESC when Meta modifies a key (disables the
	# 		metaSendsEscape resource).
	# 		Ps = 1 0 3 7 ® Send VT220 Remove from the editing-keypad Delete key
	# 		Ps = 1 0 4 7 ® Use Normal Screen Buffer, clearing screen first if in the Alternate
	# 		Screen (unless disabled by the titeInhibit resource)
	# 		Ps = 1 0 4 8 ® Restore cursor as in DECRC (unless disabled by the titeInhibit
	# 		resource)
	# 		Ps = 1 0 4 9 ® Use Normal Screen Buffer and restore cursor as in DECRC
	# 		(unless disabled by the titeInhibit resource). This combines the effects of the
	# 		1 0 4 7 and 1 0 4 8 modes. Use this with terminfo-based applications
	# 		rather than the 4 7 mode.
	# 		Ps = 1 0 5 1 ® Reset Sun function-key mode.
	# 		Ps = 1 0 5 2 ® Reset HP function-key mode.
	# 		Ps = 1 0 5 3 ® Reset SCO function-key mode.
	# 		Ps = 1 0 6 0 ® Reset legacy keyboard emulation (X11R6).
	# 		Ps = 1 0 6 1 ® Reset Sun/PC keyboard emulation of VT220 keyboard.
	# 		Ps = 2 0 0 4 ® Reset bracketed paste mode.
	function	vt100_DECRST {	
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}l"'
	}

	# CSI Pm m Character Attributes (SGR)
	# 		Ps = 0 ® Normal (default)
	# 		Ps = 1 ® Bold
	# 		Ps = 4 ® Underlined
	# 		Ps = 5 ® Blink (appears as Bold)
	# 		Ps = 7 ® Inverse
	# 		Ps = 8 ® Invisible, i.e., hidden (VT300)
	# 		Ps = 2 2 ® Normal (neither bold nor faint)
	# 		Ps = 2 4 ® Not underlined
	# 		Ps = 2 5 ® Steady (not blinking)
	# 		Ps = 2 7 ® Positive (not inverse)
	# 		Ps = 2 8 ® Visible, i.e., not hidden (VT300)
	# 		Ps = 3 0 ® Set foreground color to Black
	# 		Ps = 3 1 ® Set foreground color to Red
	# 		Ps = 3 2 ® Set foreground color to Green
	# 		Ps = 3 3 ® Set foreground color to Yellow
	# 		Ps = 3 4 ® Set foreground color to Blue
	# 		Ps = 3 5 ® Set foreground color to Magenta
	# 		Ps = 3 6 ® Set foreground color to Cyan
	# 		Ps = 3 7 ® Set foreground color to White
	# 		Ps = 3 9 ® Set foreground color to default (original)
	# 		Ps = 4 0 ® Set background color to Black
	# 		Ps = 4 1 ® Set background color to Red
	# 		Ps = 4 2 ® Set background color to Green
	# 		Ps = 4 3 ® Set background color to Yellow
	# 		Ps = 4 4 ® Set background color to Blue
	# 		Ps = 4 5 ® Set background color to Magenta
	# 		Ps = 4 6 ® Set background color to Cyan
	# 		Ps = 4 7 ® Set background color to White
	# 		Ps = 4 9 ® Set background color to default (original).
	# 		If 16-color support is compiled, the following apply. Assume that xterm’s resources are
	# 		set so that the ISO color codes are the first 8 of a set of 16. Then the aixterm colors are
	# 		the bright versions of the ISO colors:
	# 		Ps = 9 0 ® Set foreground color to Black
	# 		Ps = 9 1 ® Set foreground color to Red
	# 		Ps = 9 2 ® Set foreground color to Green
	# 		Ps = 9 3 ® Set foreground color to Yellow
	# 		Ps = 9 4 ® Set foreground color to Blue
	# 		Ps = 9 5 ® Set foreground color to Magenta
	# 		Ps = 9 6 ® Set foreground color to Cyan
	# 		Ps = 9 7 ® Set foreground color to White
	# 		Ps = 1 0 0 ® Set background color to Black
	# 		Ps = 1 0 1 ® Set background color to Red
	# 		Ps = 1 0 2 ® Set background color to Green
	# 		Ps = 1 0 3 ® Set background color to Yellow
	# 		Ps = 1 0 4 ® Set background color to Blue
	# 		Ps = 1 0 5 ® Set background color to Magenta
	# 		Ps = 1 0 6 ® Set background color to Cyan
	# 		Ps = 1 0 7 ® Set background color to White
	# 		If xterm is compiled with the 16-color support disabled, it supports the following, from
	# 		rxvt:
	# 		Ps = 1 0 0 ® Set foreground and background color to default
	# 		If 88- or 256-color support is compiled, the following apply.
	# 		Ps = 3 8 ; 5 ; Ps ® Set foreground color to the second Ps
	# 		Ps = 4 8 ; 5 ; Ps ® Set background color to the second Ps
	function	vt100_SGR {
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}m"'
	}

	# CSI Ps n Device Status Report (DSR)
	# 		Ps = 5 ® Status Report CSI 0 n (‘‘OK’’)
	# 		Ps = 6 ® Report Cursor Position (CPR) [row;column] as
	#							CSI r ; c R
	function	vt100_DSR {	echo -n "${CSI}${1:?Missing Ps}n";	}

	#	CSI ? Ps n Device Status Report (DSR, DEC-specific)
	# 		Ps = 6 ® Report Cursor Position (CPR) [row;column] as CSI ? r ; c R
	#							(assumes page is zero).
	# 		Ps = 1 5 ® Report Printer status as CSI ? 1 0 n (ready) or
	#							CSI ? 1 1 n (not ready)
	# 		Ps = 2 5 ® Report UDK status as CSI ? 2 0 n (unlocked) or
	#							CSI ? 2 1 n (locked)
	# 		Ps = 2 6 ® Report Keyboard status as
	#							CSI ? 2 7 ; 1 ; 0 ; 0 n (North American)
	#							The last two parameters apply to VT400 & up, and denote keyboard ready and LK01
	#							respectively.
	# 		Ps = 5 3 ® Report Locator status as
	#							CSI ? 5 3 n Locator available, if compiled-in, or
	#							CSI ? 5 0 n No Locator, if not.
	function	vt100_DSR {	echo -n "${CSI}?${1:?Missing Ps}n";	}
	
	# CSI ! p Soft terminal reset (DECSTR)
	function	vt100_DECSTR {	echo -n "${CSI}!p";	}

	# CSI Ps ; Ps “ p Set conformance level (DECSCL) Valid values for the first parameter:
	# 		Ps = 6 1 ® VT100
	# 		Ps = 6 2 ® VT200
	# 		Ps = 6 3 ® VT300
	# 		Valid values for the second parameter:
	# 		Ps = 0 ® 8-bit controls
	# 		Ps = 1 ® 7-bit controls (always set for VT100)
	# 		Ps = 2 ® 8-bit controls
	function	vt100_DECSCL {	echo -n "${CSI}${1:?Missing Ps};${2:?Missing Ps}“p";	}

	# CSI Ps “ q Select character protection attribute (DECSCA). Valid values for the parameter:
	# 		Ps = 0 ® DECSED and DECSEL can erase (default)
	# 		Ps = 1 ® DECSED and DECSEL cannot erase
	# 		Ps = 2 ® DECSED and DECSEL can erase
	function	vt100_DECSCA {	echo -n "${CSI}${1:?Missing Ps}“p";	}

	# CSI Ps ; Ps r Set Scrolling Region [top;bottom] (default = full size of window) (DECSTBM)
	function	vt100_DECSTBM {	echo -n "${CSI}${1:?Missing Ps};${2:?Missing Ps}r";	}

	# CSI ? Pm r Restore DEC Private Mode Values. The value of Ps previously saved is restored. Ps values
	# 		are the same as for DECSET.
	function	vt100_ResDecPModeValues {	
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}r"'
	}
	# CSI Pt ; Pl ; Pb ; Pr ; Ps $ r
	# 		Change Attributes in Rectangular Area (DECCARA).
	# 		Pt ; Pl ; Pb ; Pr denotes the rectangle.
	# 		Ps denotes the SGR attributes to change: 0, 1, 4, 5, 7
	function	vt100_DECCARA {	echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb};${4:?Missing Pr};${5:?Missing Ps}\$r";	}
	# CSI s Save cursor (ANSI.SYS)
	function	vt100_SaveCursor {	echo -n "${CSI}s";	}
	# CSI ? Pm s Save DEC Private Mode Values. Ps values are the same as for DECSET.
	function	vt100_SaveDecPModeValues {	
	  IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}s"'
	}
	# CSI Ps ; Ps ; Ps t Window manipulation (from dtterm, as well as extensions). These controls may be disabled
	# 		using the allowWindowOps resource. Valid values for the first (and any additional
	# 		parameters) are:
	# 		Ps = 1 ® De-iconify window.
	# 		Ps = 2 ® Iconify window.
	# 		Ps = 3 ; x ; y ® Move window to [x, y].
	# 		Ps = 4 ; height ; width ® Resize the xterm window to height and width in pixels.
	# 		Ps = 5 ® Raise the xterm window to the front of the stacking order.
	# 		Ps = 6 ® Lower the xterm window to the bottom of the stacking order.
	# 		Ps = 7 ® Refresh the xterm window.
	# 		Ps = 8 ; height ; width ® Resize the text area to [height;width] in characters.
	# 		Ps = 9 ; 0 ® Restore maximized window.
	# 		Ps = 9 ; 1 ® Maximize window (i.e., resize to screen size).
	# 		Ps = 1 1 ® Report xterm window state. If the xterm window is open (non-iconified),
	# 		it returns CSI 1 t . If the xterm window is iconified, it returns CSI 2 t .
	# 		Ps = 1 3 ® Report xterm window position as CSI 3 ; x ; y t
	# 		Ps = 1 4 ® Report xterm window in pixels as CSI 4 ; height ; width t
	# 		Ps = 1 8 ® Report the size of the text area in characters as
	#	CSI 8 ; height ; width t
	# 		Ps = 1 9 ® Report the size of the screen in characters as
	#	CSI 9 ; height ; width t
	# 		Ps = 2 0 ® Report xterm window’s icon label as OSC L label ST
	# 		Ps = 2 1 ® Report xterm window’s title as OSC l title ST
	# 		Ps >= 2 4 ® Resize to Ps lines (DECSLPP)
	function	vt100_windowManipulate {	echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb}t";	}

	# CSI Pt ; Pl ; Pb ; Pr ; Ps $ t
	# 		Reverse Attributes in Rectangular Area (DECRARA).
	# 		Pt ; Pl ; Pb ; Pr denotes the rectangle.
	# 		Ps denotes the attributes to reverse. 1, 4, 5, 7
	function	vt100_DECRARA {	echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb};${4:?Missing Pr};${5:?Missing Ps}\$t";	}
	
	# CSI u Save cursor (ANSI.SYS)
	function	vt100_SaveCursor {	echo -n "${CSI}u";	}

	# CSI Pt ; Pl ; Pb ; Pr ; Ps ; Pt ; Pl ; Pp $ v
	# 		Copy Rectangular Area (DECCRA)
	# 		Pt ; Pl ; Pb ; Pr denotes the rectangle.
	# 		Pp denotes the source page.
	# 		Pt ; Pl denotes the target location.
	# 		Pp denotes the target page.
	function	vt100_DECCRA {	
			echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb};${4:?Missing Pr};${5:?Missing Ps};${6:?Missing Pt};${7:?Missing Pl};${8:?Missing Pp}\$y";	}

	# CSI Pt ; Pl ; Pb ; Pr ’ w
	# 		Enable Filter Rectangle (DECEFR)
	# 		Parameters are [top;left;bottom;right].
	# 		Defines the coordinates of a filter rectangle and activates it. Anytime the locator is
	# 		detected outside of the filter rectangle, an outside rectangle event is generated and the rectangle
	# 		is disabled. Filter rectangles are always treated as "one-shot" events. Any parameters
	# 		that are omitted default to the current locator position. If all parameters are omitted,
	# 		any locator motion will be reported. DECELR always cancels any prevous rectangle definition.
	function	vt100_DECEFR {	echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb};${4:?Missing Pr}’w";	}

	# CSI Ps x Request Terminal Parameters (DECREQTPARM)
	# 		if Ps is a "0" (default) or "1", and xterm is emulating VT100, the control sequence elicits
	# 		a response of the same form whose parameters describe the terminal:
	# 		Ps ® the given Ps incremented by 2.
	# 		1 ® no parity
	# 		1 ® eight bits
	# 		1 2 8 ® transmit 38.4k baud
	# 		1 2 8 ® receive 38.4k baud
	# 		1 ® clock multiplier
	# 		0 ® STP flags
	function	vt100_DECREQTPARM {	echo -n "${CSI}${1:?Missing Ps}x";	}

	# CSI Ps x Select Attribute Change Extent (DECSACE).
	# 		Ps = 0 ® from start to end position, wrapped
	# 		Ps = 1 ® from start to end position, wrapped
	# 		Ps = 2 ® rectangle (exact).
	function	vt100_DECSACE {	echo -n "${CSI}${1:?Missing Ps}x";	}

	# CSI Pc ; Pt ; Pl ; Pb ; Pr $ x
	# 		Fill Rectangular Area (DECFRA).
	# 		Pc is the character to use.
	# 		Pt ; Pl ; Pb ; Pr denotes the rectangle.
	function	vt100_DECSACE {	echo -n "${CSI}${1:?Missing Pc};${2:?Missing Pt};${3:?Missing Pl};${4:?Missing Pb};${5:?Missing Pr}\$x";	}

	# CSI Ps ; Pu ’ z Enable Locator Reporting (DECELR)
	# 		Valid values for the first parameter:
	# 		Ps = 0 ® Locator disabled (default)
	# 		Ps = 1 ® Locator enabled
	# 		Ps = 2 ® Locator enabled for one report, then disabled
	# 		The second parameter specifies the coordinate unit for locator reports.
	# 		Valid values for the second parameter:
	# 		Pu = 0 or omitted ® default to character cells
	# 		Pu = 1 ® device physical pixels
	# 		Pu = 2 ® character cells
	function	vt100_DECELR {	echo -n "${CSI}${1:?Missing Ps};${2:?Missing Pu}’z";	}

	# CSI Pt ; Pl ; Pb ; Pr $ z
	# 		Erase Rectangular Area (DECERA).
	# 		Pt ; Pl ; Pb ; Pr denotes the rectangle.
	function	vt100_DECERA {	echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb};${4:?Missing Pr}\$z";	}

	# CSI Pm ’ { Select Locator Events (DECSLE)
	# 		Valid values for the first (and any additional parameters) are:
	# 		Ps = 0 ® only respond to explicit host requests (DECRQLP)
	# 		(default) also cancels any filter rectangle
	# 		Ps = 1 ® report button down transitions
	# 		Ps = 2 ® do not report button down transitions
	# 		Ps = 3 ® report button up transitions
	# 		Ps = 4 ® do not report button up transitions
	function	vt100_DECSLE {	
		IFS=';' eval 'echo -n "${CSI}?${*?Missing Pm}\’'	
	}

	# CSI Pt ; Pl ; Pb ; Pr $ {
	# 		Selective Erase Rectangular Area (DECSERA).
	# 		Pt ; Pl ; Pb ; Pr denotes the rectangle.
	function	vt100_DECSERA {	echo -n "${CSI}${1:?Missing Pt};${2:?Missing Pl};${3:?Missing Pb};${4:?Missing Pr}\$";	}

	# CSI Ps ’ | Request Locator Position (DECRQLP)
	# 		Valid values for the parameter are:
	# 		Ps = 0 , 1 or omitted ® transmit a single DECLRP locator report
	# 		If Locator Reporting has been enabled by a DECELR, xterm will respond with a
	# 		DECLRP Locator Report. This report is also generated on button up and down events if
	# 		they have been enabled with a DECSLE, or when the locator is detected outside of a filter
	# 		rectangle, if filter rectangles have been enabled with a DECEFR.
	# 		® CSI Pe ; Pb ; Pr ; Pc ; Pp & w
	# 		Parameters are [event;button;row;column;page].
	# 		Valid values for the event:
	# 		Pe = 0 ® locator unavailable - no other parameters sent
	# 		Pe = 1 ® request - xterm received a DECRQLP
	# 		Pe = 2 ® left button down
	# 		Pe = 3 ® left button up
	# 		Pe = 4 ® middle button down
	# 		Pe = 5 ® middle button up
	# 		Pe = 6 ® right button down
	# 		Pe = 7 ® right button up
	# 		Pe = 8 ® M4 button down
	# 		Pe = 9 ® M4 button up
	# 		Pe = 1 0 ® locator outside filter rectangle
	# 		‘‘button’’ parameter is a bitmask indicating which buttons are pressed:
	# 		Pb = 0 ® no buttons down
	# 		Pb & 1 ® right button down
	# 		Pb & 2 ® middle button down
	# 		Pb & 4 ® left button down
	# 		Pb & 8 ® M4 button down
	# 		‘‘row’’ and ‘‘column’’ parameters are the coordinates of the locator position in the xterm
	# 		window, encoded as ASCII decimal.
	# 		The ‘‘page’’ parameter is not used by xterm, and will be omitted.
	function	vt100_DECRQLP {	echo -n "${CSI}${1:?Missing Ps}’|";	}

	#	Operating System Controls
	# OSC Ps ; Pt ST
	# OSC Ps ; Pt BEL Set Text Parameters. For colors and font, if Pt is a "?", the control sequence elicits a
	# 		response which consists of the control sequence which would set the corresponding
	# 		value. The dtterm control sequences allow you to determine the icon name and window
	# 		title.
	# 		Ps = 0 ® Change Icon Name and Window Title to Pt
	# 		Ps = 1 ® Change Icon Name to Pt
	# 		Ps = 2 ® Change Window Title to Pt
	# 		Ps = 3 ® Set X property on top-level window. Pt should be in the form "prop=value",
	# 		or just "prop" to delete the property
	# 		Ps = 4 ; c ; spec ® Change Color Number c to the color specified by spec, i.e., a
	# 		name or RGB specification as per XParseColor. Any number of c name pairs may be
	# 		given. The color numbers correspond to the ANSI colors 0-7, their bright versions 8-15,
	# 		and if supported, the remainder of the 88-color or 256-color table.
	# 		If a "?" is given rather than a name or RGB specification, xterm replies with a control
	# 		sequence of the same form which can be used to set the corresponding color. Because
	# 		more than one pair of color number and specification can be given in one control
	# 		sequence, xterm can make more than one reply.
	# 		The 8 colors which may be set using 1 0 through 1 7 are denoted dynamic colors,
	# 		since the corresponding control sequences were the first means for setting xterm’s
	# 		colors dynamically, i.e., after it was started. They are not the same as the ANSI colors.
	# 		One or more parameters is expected for Pt. Each successive parameter changes the next
	# 		color in the list. The value of Ps tells the starting point in the list. The colors are specified
	# 		by name or RGB specification as per XParseColor.
	# 		If a "?" is given rather than a name or RGB specification, xterm replies with a control
	# 		sequence of the same form which can be used to set the corresponding dynamic color.
	# 		Because more than one pair of color number and specification can be given in one control
	# 		sequence, xterm can make more than one reply.
	# 		Ps = 1 0 ® Change VT100 text foreground color to Pt
	# 		Ps = 1 1 ® Change VT100 text background color to Pt
	# 		Ps = 1 2 ® Change text cursor color to Pt
	# 		Ps = 1 3 ® Change mouse foreground color to Pt
	# 		Ps = 1 4 ® Change mouse background color to Pt
	# 		Ps = 1 5 ® Change Tektronix foreground color to Pt
	# 		Ps = 1 6 ® Change Tektronix background color to Pt
	# 		Ps = 1 7 ® Change highlight color to Pt
	# 		Ps = 1 8 ® Change Tektronix cursor color to Pt
	# 		Ps = 4 6 ® Change Log File to Pt (normally disabled by a compile-time option)
	# 		Ps = 5 0 ® Set Font to Pt If Pt begins with a "#", index in the font menu, relative (if
	# 		the next character is a plus or minus sign) or absolute. A number is expected but not
	# 		required after the sign (the default is the current entry for relative, zero for absolute
	# 		indexing).
	# 		Ps = 5 1 (reserved for Emacs shell)
	# 		Ps = 5 2 ® Manipulate Selection Data. These controls may be disabled using the
	# 		allowWindowOps resource. The parameter Pt is parsed as
	# 		Pc ; Pd
	# 		The first, Pc, may contain any character from the set c p s 0 1 2 3
	# 		4 5 6 7 . It is used to construct a list of selection parameters for clipboard,
	# 		primary, select, or cut buffers 0 through 8 respectively, in the order given. If the parameter
	# 		is empty, xterm uses s 0 , to specify the configurable primary/clipboard selection
	# 		and cut buffer 0.
	# 		The second parameter, Pd, gives the selection data. Normally this is a string encoded in
	# 		base64. The data becomes the new selection, which is then available for pasting by other
	# 		applications.
	# 		If the second parameter is a ? , xterm replies to the host with the selection data encoded
	# 		using the same protocol.
	function	vt100_OscSetTextParamaters1 {	echo -n "${OSC}${1:?Missing Ps};${2:?Missing Pt}${ST}";	}
	function	vt100_OscSetTextParamaters2 {	echo -n "${OSC}${1:?Missing Ps};${2:?Missing Pt}\b";	}
	#	Privacy Message
	#		PM Pt ST xterm implements no PM functions; Pt is ignored. Pt need not be printable characters.
	function	vt100_PM {	echo -n "${PM}${1:?Missing Pt}${ST}";	}


	

	#########################################################################
	# Procedures
	#########################################################################

	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_vt100Funcs_Flags {
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

	vt100FuncsRevision=$(CleanRevision '$Revision: 64 $')
	vt100FuncsDescription=''
	push_element	ScriptsLoaded "vt100Funcs.sh;${vt100FuncsRevision};${vt100FuncsDescription}"
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
	push_element ModulesArgHandlers SupportCallingFileFuncs "Set_vt100Funcs_Flags" "Set_vt100Funcs_exec_Flags"
	#push_element SupportedCLIOptions 
	function Set_vt100Funcs_exec_Flags {
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

