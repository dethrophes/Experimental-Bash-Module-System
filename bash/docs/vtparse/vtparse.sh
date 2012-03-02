#!/bin/bash 
#set -o errexit 
#set -o errtrace 
set -o nounset 
[ "${DEBUG:-0}" = "1" ] && set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/docs/vtparse/vtparse.sh $
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
#I  File Name            : vtparse.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: vtparse.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
#if [ -z "${__GenFuncs_sh__:-}" ]; then
  #[ -z "${ScriptDir:-}"  ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
  #if [ -f "${ScriptDir}/Genuncs.sh" ]; then
    #source "${ScriptDir}/GenFuncs.sh"
  #else
    #echo "# "
    #echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
    #echo "# "
    #exit 7
  #fi
#fi

if [ -z "${__vtparse_sh__:-}" ]; then
  __vtparse_sh__=1

  #SourceCoreFiles_ "vtparse_table.sh"
  source "vtparse_table.sh"
  #SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

  

  #########################################################################
  # Procedures
  #########################################################################
  function ord {
    printf -v "${1?Missing Dest Variable}" "${3:-%d}" "'${2?Missing Char}"
  }
  function ord_eascii {
    LC_CTYPE=C ord "${@}"
  }
  function substr {
      local idx
      typeset -gi _INDEX
      case "${1}" in
        *${2}*)
            idx="${1%"${2}"*}";
            _INDEX=${#idx}
        ;;
          *)
            _INDEX=0
        ;;
      esac
  }




  declare -gr  MAX_INTERMEDIATE_CHARS=2

  declare -gi  vtparser_state
  declare -g   vtparser_intermediate_chars
  declare -ga  vtparser_params
  declare -gi  vtparser_ignore_flagged
  declare -g   vtparser_cb
  declare -g   vtparser_read


  function vtparse_init {
    vtparser_state="${VTPARSE_STATE_GROUND}"
    vtparser_intermediate_chars=""
    vtparser_params=( )
    vtparser_ignore_flagged=0
    vtparser_cb=${1?Missing Callback Function}
    vtparser_read=${2?Missing Read Function}
  }
  function nop {
    echo -n ""
  }
  function do_action {
    # Some actions we handle internally (like parsing parameters), others
    # we hand to our client for processing 
    case "${1}" in
      ${VTPARSE_ACTION_ESC_EXECUTE}|${VTPARSE_ACTION_PRINT}|${VTPARSE_ACTION_EXECUTE}|${VTPARSE_ACTION_HOOK}|${VTPARSE_ACTION_PUT}|${VTPARSE_ACTION_OSC_START}|${VTPARSE_ACTION_OSC_PUT}|${VTPARSE_ACTION_OSC_END}|${VTPARSE_ACTION_UNHOOK}|${VTPARSE_ACTION_CSI_DISPATCH}|${VTPARSE_ACTION_ESC_DISPATCH}|${VTPARSE_STATE_SS2_ENTRY}|${VTPARSE_STATE_SS3_ENTRY})
        ${vtparser_cb} "${@}" || return $?
        ;;
      ${VTPARSE_ACTION_IGNORE})
        nop
        ;;
      ${VTPARSE_ACTION_COLLECT})
        if [ ${#vtparser_intermediate_chars} -ge ${MAX_INTERMEDIATE_CHARS} ]; then
            vtparser_ignore_flagged=1
        else
            vtparser_intermediate_chars+="${2}";
        fi
        ;;
      ${VTPARSE_ACTION_PARAM})
        # process the param character 
        if [ "${2}" = ";" ]; then
            vtparser_params[${#vtparser_params[@]}]="";
        else
            # the character is a digit
            if [ ${#vtparser_params[@]} -eq 0 ]; then
                vtparser_params[0]=""
            fi
            vtparser_params[${#vtparser_params[@]}-1]+="${2}"
        fi
        ;;
      ${VTPARSE_ACTION_CLEAR})
        vtparser_intermediate_chars=""
        vtparser_params=( )
        vtparser_ignore_flagged=0
        ;;
      *)
        echo "Unknown action ${1}"
        ;;

    esac
    return 0
  }
  function vtparse_conv_base {
    local _INDEX
    substr "${VTPARSE_BASE}" "${2:0:1}"
    eval ${1}'="${_INDEX}"'
  }
  function do_state_change {
    # A state change is an action and/or a new state to transition to.
    local -i action
    local -i new_state
    local -i RValue=0

    vtparse_conv_base action "${1:0:1}"
    vtparse_conv_base new_state "${1:1:1}"
    #printf "action=%s new_state=%s vtparser_state=%s change=%s\n" "${action}"  "${new_state}"  "${vtparser_state}"  "${1}"
    
    if [ "${new_state:=0}" != "0" ]; then
        # Perform up to three actions:
        #   1. the exit action of the old state
        #   2. the action associated with the transition
        #   3. the entry actionk of the new action
        local -i exit_action
        local -i entry_action
        vtparse_conv_base exit_action  "${VTPARSE_EXIT_ACTIONS:${vtparser_state}:1}"
        vtparse_conv_base entry_action "${VTPARSE_ENTRY_ACTIONS:${new_state}:1}"
        [ "${exit_action}" = "0" ]  ||  do_action "${exit_action}" $'\x00' 0
        [ "${action}" = "0" ]       ||  do_action "${action}" "${2}" "${3}" || RValue=$?
        [ "${entry_action}" = "0" ] ||  do_action "${entry_action}" $'\x00' 0
        vtparser_state=${new_state}
        return ${RValue}
    else
        [ "${action}" = "0" ]       ||  do_action "${action}" "${2}" "${3}" || return $?
    fi
  }

  function vtparse {
      local -i _INDEX
      local REPLY
      while ${vtparser_read} 1 ; do
          ord_eascii _INDEX "${REPLY:0:1}"

          # If a transition is defined from the "anywhere" state, always
          # use that.  Otherwise use the transition from the current state. 
          
          _INDEX=${_INDEX}*2  # 2 characters per entry
          local change="${VTPARSE_STATE_TABLE[${VTPARSE_STATE_ANYWHERE}]:${_INDEX}:2}"
          [ "${change:-00}" != "00" ] || change="${VTPARSE_STATE_TABLE[${vtparser_state}]:${_INDEX}:2}"
          _INDEX=${_INDEX}/2

          do_state_change "${change}" "${REPLY}" "${_INDEX}" || break
      done
  }
  function vtparse_read_stdin {
    read -srN${1:-1} -d '' "${@:2}"
  }
  declare -g vtparse_read_buffer
  function vtparse_read_buffer {
    REPLY="${vtparse_read_buffer:0:${1:-1}}"
    vtparse_read_buffer="${vtparse_read_buffer:${1}}"
    [ ${#REPLY} -eq ${1} ] || return $?
  }


  function vtparser_callback_debug {
    local CArg
    printf "Received action %s, char=0x%02x char=%q\n" "${VTPARSE_ACTION_NAMES[${1}]}" "'${2}" "${2}"
    printf "Intermediate chars: '%s'\n" "${vtparser_intermediate_chars}"
    printf "%d Parameters:\n"  ${#vtparser_params[@]}
    for CArg in "${vtparser_params[@]-}"; do
        printf "\t%d\n" "${CArg}"
    done
    printf "\n"
  }
  ###############################
  ##
  ##    READ KEY CRAP
  ##
  ##
  ###############################
  KeyModifiers=(
    [1]=""  [2]="S-"   [3]="A-"   [4]="AS-"   [5]="C-"   [6]="CS-"  [7]="CA-"    [8]="CAS-"
    [9]="M-" [10]="MS-" [11]="MA-" [12]="MAS-" [13]="MC-" [14]="MCS-" [15]="MCA-" [16]="MCAS-"
    )
  KeybFntKeys=(
    [1]="home" [2]="insert" [3]="delete"  [4]="end"   [5]="pageUp" [6]="pageDown"
    [11]="f1"  [12]="f2"    [13]="f3"     [14]="f4"   [15]="f5"
    [17]="f6"  [18]="f7"    [19]="f8"     [20]="f9"   [21]="f10"
    [23]="f11" [24]="f12"   [25]="f13"    [26]="f14"  [28]="f15"
    [29]="f16" [31]="f17"   [32]="f18"    [33]="f19"  [34]="f20"
    )
  SunKeybFntKeys=(
    [214]="home"  [2]="insert" [3]="delete" [4]="end"   [216]="pageUp" [222]="pageDown"
    [224]="f1"  [225]="f2"    [226]="f3"    [227]="f4"  [228]="f5"
    [229]="f6"  [230]="f7"    [231]="f8"    [232]="f9"  [233]="f10"
    [192]="f11" [193]="f12"   [218]="keypad-five" [220]="keypad-delete"
    )
  KeybFntKeysAlt=(
    # A          B              C               D             E                   F             H         
    [0x41]="up" [0x42]="down" [0x43]="right" [0x44]="left" [0x45]="keypad-five" [0x46]="end" [0x48]="home"     
    # I               O
    [0x49]="InFocus" [0x4f]="OutOfFocus"      
    # P           Q           R           S             Z          
    [0x50]="f1" [0x51]="f2" [0x52]="f3" [0x53]="f4"  [0x5a]="S-HT" 
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
    [0x1d]="C-}" [0x1e]="C-^" [0x1f]="C-_" [0x20]="C-SP"  [0x7F]="DEL" 
  )

  C1CtrlCharsEsc=(
    [0x40]="PAD"  [0x41]="HOP"  [0x42]="BPH" [0x43]="NBH" 
    [0x44]="IND"  [0x45]="NEL"  [0x46]="SSA" [0x47]="ESA" 
    [0x48]="HTS"  [0x49]="HTJ"  [0x4A]="VTS" [0x4B]="PLD" 
    [0x4C]="PLU"  [0x4D]="RI"   [0x4E]="SS2" [0x4F]="SS3" 
    [0x50]="DCS"  [0x51]="PU1"  [0x52]="PU2" [0x53]="STS" 
    [0x54]="CCH"  [0x55]="MW"   [0x56]="SPA" [0x57]="EPA" 
    [0x58]="SOS"  [0x59]="SGCI" [0x5A]="SCI" [0x5B]="CSI" 
    [0x5C]="ST"   [0x5D]="OSC"  [0x5E]="PM"  [0x5F]="APC" 
  )
  C1CtrlChars=(
    [0x80]="PAD"  [0x81]="HOP"  [0x82]="BPH" [0x83]="NBH" 
    [0x84]="IND"  [0x85]="NEL"  [0x86]="SSA" [0x87]="ESA" 
    [0x88]="HTS"  [0x89]="HTJ"  [0x8A]="VTS" [0x8B]="PLD" 
    [0x8C]="PLU"  [0x8D]="RI"   [0x8E]="SS2" [0x8F]="SS3" 
    [0x90]="DCS"  [0x91]="PU1"  [0x92]="PU2" [0x93]="STS" 
    [0x94]="CCH"  [0x95]="MW"   [0x96]="SPA" [0x97]="EPA" 
    [0x98]="SOS"  [0x99]="SGCI" [0x9A]="SCI" [0x9B]="CSI" 
    [0x9C]="ST"   [0x9D]="OSC"  [0x9E]="PM"  [0x9F]="APC" 
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
    [0x04]="S-"    [0x08]="A-"    [0x0c]="AS-" 
    [0x10]="C-"    [0x14]="CS-"   [0x1c]="CAS-"
  )
  
  function AdjustMousePos {
    local -i _INDEX
    ord_eascii _INDEX "${2}"
    eval ${1}'=$(( ${_INDEX}-32))'
  }
  function GetMouseButton {
    local MouseBtn
    AdjustMousePos MouseBtn "${2}"
    MouseBtn="${MouseMetaButtons[$(( ${MouseBtn} & 0x1C))]-}${MouseButtons[$(( ${MouseBtn} & 0xe3))]}"
    eval ${1}='"${MouseBtn}"'
  }

  function vtparser_callback_readkey {
    unset UInput[@]
    case "${1}" in 
      ${VTPARSE_ACTION_ESC_EXECUTE})
        case "${2}" in 
          [[:cntrl:]])
            UInput[0]="${C1CtrlCharsAlt[${3}]:-$(printf "%q" $'\e'"${2}")}"
            ;;
          *)
            UInput[0]="${C1CtrlChars[${3}]:-$(printf "%q" $'\e'"${2}")}"
            ;;
        esac
        ;;
      ${VTPARSE_ACTION_EXECUTE})
          UInput[0]="${C0CtrlChars[${3}]:-$(printf "%q" "${2}")}"
        ;;
      ${VTPARSE_ACTION_CSI_DISPATCH})
        case "${2}" in 
          z) # Sun Function Keys
            UInput[0]="${SunKeybFntKeys[${vtparser_params[0]}]:-}"
            if [ -n "${UInput[0]}" ]; then
              UInput[0]="${KeyModifiers[${vtparser_params[1]:-1}]}${UInput[0]}"
              UInput[1]="1" # Repeat Count
            else
              UInput[0]="CSI ${vtparser_params[*]} ${2}"
            fi
            ;;
          '~') # Function Keys
            UInput[0]="${KeybFntKeys[${vtparser_params[0]}]}"
            if [ -n "${UInput[0]}" ]; then
              UInput[0]="${KeyModifiers[${vtparser_params[1]:-1}]}${UInput[0]}"
              UInput[1]="1" # Repeat Count
            else
              UInput[0]="CSI ${vtparser_params[*]} ${2}"
            fi
            ;;
          A|B|C|D|E|F|H|I|O|Z|P|Q|R|S)
            UInput[0]="${KeybFntKeysAlt[${3}]:-}"
            if [ -n "${UInput[0]}" ]; then
              UInput[0]="${KeyModifiers[${vtparser_params[1]:-1}]}${UInput[0]}"
              UInput[1]="${vtparser_params[0]:-1}" # Repeat Count
            else
              UInput[0]="CSI ${vtparser_params[*]} ${2}"
            fi
            ;;
          t) 
            ${vtparser_read} 2
            UInput[0]="MouseTrack"
            AdjustMousePos UInput[1] "${REPLY:0:1}"
            AdjustMousePos UInput[2] "${REPLY:1:1}"
            ;;
          T) 
            ${vtparser_read} 6
            UInput[0]="MouseTrack"
            AdjustMousePos UInput[1] "${REPLY:0:1}"
            AdjustMousePos UInput[2] "${REPLY:1:1}"
            AdjustMousePos UInput[3] "${REPLY:2:1}"
            AdjustMousePos UInput[4] "${REPLY:3:1}"
            AdjustMousePos UInput[5] "${REPLY:4:1}"
            AdjustMousePos UInput[6] "${REPLY:5:1}"
            ;;
          M)  # Mouse 
            ${vtparser_read} 3
            GetMouseButton UInput[0] "${REPLY:0:1}"
            if [ -n "${UInput[0]}" ]; then  
              AdjustMousePos UInput[1] "${REPLY:1:1}"
              AdjustMousePos UInput[2] "${REPLY:2:1}"
            else
              UInput[0]=$(printf 'Mouse-\\x%02x %q'  "'${escapeSequence:0:1}" "${escapeSequence:1}")
            fi
            ;;

          *)
            UInput[0]="CSI ${vtparser_params[*]} ${2}"
            ;;
        esac
        ;;
      ${VTPARSE_ACTION_SS3_DISPATCH})
        case "${2}" in
          A|B|C|D|E|F|H|P|Q|R|S|~)
            UInput[0]+="${KeybFntKeysAlt[${3}]}"
            if [ -n "${UInput[0]}" ]; then
              UInput[0]="${KeyModifiers[${vtparser_params[1]:-1}]}${UInput[0]}"
              UInput[1]="${vtparser_params[0]:-1}" # Repeat Count
            else
              UInput[0]="SS3 ${vtparser_params[*]} ${2}"
            fi
            ;;
          *)
            UInput[0]="SS3 ${vtparser_params[*]} ${2}"
            ;;
        esac
        ;;
      ${VTPARSE_ACTION_ESC_DISPATCH})
        case "${2}" in 
          [][}^_A-Z]) UInput[0]="${C1CtrlChars[${3}]}" ;;
          [^[:cntrl:]]) UInput[0]="CA-${2}" ;;
          *) UInput[0]="${C1CtrlChars[${3}]:-$(printf "%q" $'\e'"${2}")}" ;;
        esac
        ;;
      ${VTPARSE_ACTION_PRINT})
        case "${2}" in 
          [^[:cntrl:]]) UInput[0]="${2}" ;;
          *) UInput[0]="${C0CtrlChars[${3}]:-$(printf "%q" $'\e'"${2}")}" ;;
        esac
        ;;
      *)
        vtparser_callback_debug "${@}" || return $?
        ;;
    esac
    return 1

  }
  function Set_vtparse_Flags {
    local -i PCnt=0
    while [ $# -gt 0 ] ; do
      case "${1}" in
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
  #push_element RequiredDebianPackages  <Package Name> ...
  #push_element RequiredRpmPackages     <Package Name> ...
  #push_element RequiredGentooPackages  <Package Name> ...
  #push_element RequiredSolarisPackages <Package Name> ...
  #push_element RequiredFreeBsdPackages <Package Name> ...
  #push_element RequiredSusePackages    <Package Name> ...

  #vtparseRevision=$(CleanRevision '$Revision: 53 $')
  #vtparseDescription=' -- vt100 Parser'
  #push_element ScriptsLoaded "vtparse.sh;${vtparseRevision};${vtparseDescription}"
  #if [ "${SBaseName2}" = "vtparse.sh" ]; then 
    #ScriptRevision="${vtparseRevision}"

    #########################################################################
    # Usage
    #########################################################################
   # function Usage {
      #ConsoleStdout "."
      #ConsoleStdout "+=============================================================================="
      #ConsoleStdout "I  ${SBaseName2} ................................................... ${ScriptRevision}"
      #ConsoleStdout "+=============================================================================="
      #ConsoleStdout "I " 
      #UsageCommon
      #ConsoleStdout "I                                                                                "
      #ConsoleStdout "I                                                                                "
      #sNormalExit 0
    #}

    #SetLogFileName "&1"
    #sLogOut "${0}" "${@}"


    ##########################################################################
    ## Argument Processing
    ##########################################################################
    #push_element ModulesArgHandlers "Set_vtparse_Flags" "Set_vtparse_exec_Flags"
    ##push_element SupportedCLIOptions 
    #function Set_vtparse_exec_Flags {
      #local -i PCnt=0
      #while [ $# -gt 0 ] ; do
        #case "${1}" in
          #--SupportedOptions)
            #[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
            #break
            #;;
          #-*)
              #sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
            #;;
          #*)
            #break
            #;;
        #esac
        #let PCnt+=1
        #shift
      #done
      #return ${PCnt}
    #}
    ##MainOptionArg ArgFiles "${@}"
  #  MainOptionArg "" "${@}"


    #########################################################################
    # MAIN PROGRAM
    #########################################################################

    echo "###############################################"
    #echo "# ${SBaseName2} $(gettext "Test Module")"
    echo "###############################################"
    #vtparse_init vtparser_callback_debug

    case "${1:-2}" in
      1)
        vtparse_init vtparser_callback_readkey vtparse_read_buffer
        while true; do
            IFS='' read -srd $'\n' vtparse_read_buffer || break
            printf "%q\n" "${vtparse_read_buffer}"
            time vtparse || break
            echo "${UInput[@]}"
        done
        ;;
      *)
        vtparse_init vtparser_callback_readkey vtparse_read_stdin
        while true; do
          vtparse 
          case "${UInput[0]}" in
            LF)
              echo "${UInput[@]}"
              break
              ;;
            *)
              echo "${UInput[@]}"
              ;;
          esac
        done
        ;;
    esac

   # sNormalExit 0
  #fi
fi

