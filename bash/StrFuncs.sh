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
#I              File Name            : StrFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : StrFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
  [ -n "${ScriptDir:-}" ] || ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
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

if [ -z "${__StrFuncs_sh__:-}" ]; then
  __StrFuncs_sh__=1
  #########################################################################
  # Module Shared Procedures
  #########################################################################


  

  #########################################################################
  # Procedures
  #########################################################################
  function utf8_decode {
    printf -v _Value "%d" "'${1}"
    if [ -n "${1}"] ; then
      local val
      printf -v val "%q" "${1}"
      val="${val/#\$\'}"
      val="${val/%\'}"
    
      local -i bytes=0
      for val in ${val//\\/ }; do
        #echo "bytes=${bytes} _Value=${_Value} val=${val}"
        local -i val="0${val}" # load as octal
        if [ "${bytes}" = "0" ]; then
          # Only valid for the first byte
          if   [[ ${val} -lt 0x80 ]]; then
            bytes=0
            _Value=${val}
          elif [[ ${val} -le 0xbf ]]; then
            return 1
          elif [[ ${val} -le 0xdf ]]; then
            bytes=1
            _Value=$(( (${val}&0x1f)<<(6*${bytes}) ))
          elif [[ ${val} -le 0xef ]]; then
            bytes=2
            _Value=$(( (${val}&0xf)<<(6*${bytes}) ))
          elif [[ ${val} -le 0xf7 ]]; then
            bytes=3
            _Value=$(( (${val}&0x7)<<(6*${bytes}) ))
          elif [[ ${val} -le 0xfb ]]; then
            bytes=4
            _Value=$(( (${val}&0x3)<<(6*${bytes}) ))
          elif [[ ${val} -le 0xfd ]]; then
            bytes=5
            _Value=$(( (${val}&0x1)<<(6*${bytes}) ))
          elif [[ ${val} -le 0xff ]]; then
            bytes=6
            _Value=0
          fi
        elif [[ ${val} -ge 0x80 || ${val} -le 0xdf  ]]; then
          # Only valid after the first byte
          bytes+=-1
          _Value=$(( ${_Value} | ((${val}&0x3f)<<(6*${bytes})) ))
        else
          return 2
        fi
        [ ${bytes} -gt 0 ] || break
      done
    else
      return 3
    fi
    #printf "${2:-%d\n}" "${_Value}"
    return 0
  }
  function strstr {
    local idx
    _INDEX=
    [ ${#1} -eq 0 ] && return -1
    [ ${#2} -eq 0 ] && return -2
    idx="${1%%"${2}"*}"
    [ ${#idx} -eq ${#1} ] && return -3
    _INDEX=${#idx}
    return 0
  }
  function rstrstr {
    local idx
    _INDEX=
    [ ${#1} -eq 0 ] && return -1
    [ ${#2} -eq 0 ] && return -2
    idx="${1%"${2}"*}"
    [ ${#idx} -eq ${#1} ] && return -3
    _INDEX=${#idx}
    return 0
  }
  ###############################################################
  #
  # Note about Ext Ascii and UTF-8 encoding
  # 
  # for values 0x00   - 0x7f        Identical
  # for values 0x80   - 0xff        conflict between UTF-8 & ExtAscii
  # for values 0x100  - 0xffff      Only UTF-8 UTF-16 UTF-32
  # for values 0x100  - 0x7FFFFFFF  Only UTF-8 UTF-32
  #
  # value       EAscii   UTF-8                          UTF-16  UTF-32
  # 0x20        "\x20"   "\x20"                         \u0020  \U00000020
  # 0x20        "\x7f"   "\x7f"                         \u007f  \U0000007f
  # 0x80        "\x80"   "\xc2\x80"                     \u0080  \U00000080
  # 0xff        "\xff"   "\xc3\xbf"                     \u00ff  \U000000ff
  # 0x100       N/A      "\xc4\x80"                     \u0100  \U00000100
  # 0x1000      N/A      "\xc8\x80"                     \u1000  \U00001000
  # 0xffff      N/A      "\xef\xbf\xbf"                 \uffff  \U0000ffff
  # 0x10000     N/A      "\xf0\x90\x80\x80"             N/A     \U00010000
  # 0xfffff     N/A      "\xf3\xbf\xbf\xbf"             N/A     \U000fffff
  # 0x10000000  N/A      "\xfc\x90\x80\x80\x80\x80"     N/A     \U10000000
  # 0x7fffffff  N/A      "\xfd\xbf\xbf\xbf\xbf\xbf"     N/A     \U7fffffff
  # 0x80000000  N/A      N/A                            N/A     N/A
  # 0xffffffff  N/A      N/A                            N/A     N/A
  
  ###########################################################################
  ## ord family
  ###########################################################################
  # ord        <Return Variable Name> <Char to convert> [Optional Format String]
  # ord_hex    <Return Variable Name> <Char to convert>
  # ord_oct    <Return Variable Name> <Char to convert>
  # ord_utf8   <Return Variable Name> <Char to convert> [Optional Format String]
  # ord_eascii <Return Variable Name> <Char to convert> [Optional Format String]
  # ord_echo                          <Char to convert> [Optional Format String]
  # ord_hex_echo                      <Char to convert>
  # ord_oct_echo                      <Char to convert>
  # ord_utf8_echo                     <Char to convert> [Optional Format String]
  # ord_eascii_echo                   <Char to convert> [Optional Format String]
  #
  # Description:
  # converts character using native encoding to its decimal value and stores
  # it in the Variable specified
  #  
  # ord        
  # ord_hex         output in hex
  # ord_hex         output in octal
  # ord_utf8        forces UTF8 decoding
  # ord_eascii      forces eascii decoding
  # ord_echo        prints to stdout
  function ord {
    printf -v "${1:?Missing Dest Variable}" "${3:-%d}" "'${2:?Missing Char}"
  }
  function ord_oct {
    ord "${@:1:2}" "0%c"
  }
  function ord_hex {
    ord "${@:1:2}" "0x%x"
  }
  function ord_utf8 {
    LC_CTYPE=C.UTF-8 ord "${@}"
  }
  function ord_eascii {
    LC_CTYPE=C ord "${@}"
  }
  function ord_echo {
    printf "${2:-%d}" "'${1:?Missing Char}"
  }
  function ord_oct_echo {
    ord_echo "${1}" "0%o"
  }
  function ord_hex_echo {
    ord_echo "${1}" "0x%x"
  }
  function ord_utf8_echo {
    LC_CTYPE=C.UTF-8 ord_echo "${@}"
  }
  function ord_eascii_echo {
    LC_CTYPE=C ord_echo "${@}"
  }

  ###########################################################################
  ## chr family
  ###########################################################################
  # chr_utf8   <Return Variale Name> <Integer to convert>
  # chr_eascii <Return Variale Name> <Integer to convert>
  # chr        <Return Variale Name> <Integer to convert>
  # chr_oct    <Return Variale Name> <Octal number to convert>
  # chr_hex    <Return Variale Name> <Hex number to convert>
  # chr_utf8_echo                    <Integer to convert>
  # chr_eascii_echo                  <Integer to convert>
  # chr_echo                         <Integer to convert>
  # chr_oct_echo                     <Octal number to convert>
  # chr_hex_echo                     <Hex number to convert>
  #
  # Description:
  # converts decimal value to character representation an stores
  # it in the Variable specified
  #  
  # chr             Tries to guess output format
  # chr_utf8        forces UTF8 encoding
  # chr_eascii      forces eascii encoding
  # chr_echo        prints to stdout
  # 
  function chr_utf8_m {
    local val
    #
    # bash only supports \u \U since 4.2
    #
    # here is an example how to encode 
    # manually
    #
    if [[ ${2:?Missing Ordinal Value} -le 0x7f ]]; then
      printf -v val "\\%03o" "${2}"
    elif [[ ${2} -le 0x7ff        ]]; then
      printf -v val "\\%03o\%03o" \
        $((  (${2}>> 6)      |0xc0 )) \
        $(( ( ${2}     &0x3f)|0x80 ))
    elif [[ ${2} -le 0xffff       ]]; then
      printf -v val "\\%03o\%03o\%03o" \
        $(( ( ${2}>>12)      |0xe0 )) \
        $(( ((${2}>> 6)&0x3f)|0x80 )) \
        $(( ( ${2}     &0x3f)|0x80 ))
    elif [[ ${2} -le 0x1fffff     ]]; then
      printf -v val "\\%03o\%03o\%03o\%03o"  \
        $(( ( ${2}>>18)      |0xf0 )) \
        $(( ((${2}>>12)&0x3f)|0x80 )) \
        $(( ((${2}>> 6)&0x3f)|0x80 )) \
        $(( ( ${2}     &0x3f)|0x80 ))
    elif [[ ${2} -le 0x3ffffff    ]]; then
      printf -v val "\\%03o\%03o\%03o\%03o\%03o"  \
        $(( ( ${2}>>24)      |0xf8 )) \
        $(( ((${2}>>18)&0x3f)|0x80 )) \
        $(( ((${2}>>12)&0x3f)|0x80 )) \
        $(( ((${2}>> 6)&0x3f)|0x80 )) \
        $(( ( ${2}     &0x3f)|0x80 ))
    elif [[ ${2} -le 0x7fffffff ]]; then
      printf -v val "\\%03o\%03o\%03o\%03o\%03o\%03o"  \
        $(( ( ${2}>>30)      |0xfc )) \
        $(( ((${2}>>24)&0x3f)|0x80 )) \
        $(( ((${2}>>18)&0x3f)|0x80 )) \
        $(( ((${2}>>12)&0x3f)|0x80 )) \
        $(( ((${2}>> 6)&0x3f)|0x80 )) \
        $(( ( ${2}     &0x3f)|0x80 ))
    else
      printf -v ${1:?Missing Dest Variable} ""
      return 1
    fi
    printf -v ${1:?Missing Dest Variable} ${val}
  }

  function chr_utf8 {
    local val
    [[ ${2:?Missing Ordinal Value} -lt 0x80000000 ]] || return 1

    if [[ ${2} -lt 0x100 && ${2} -ge 0x80 ]]; then
      # some kinda weird bash? behavior
      # treats \Uff as \xff so encode manually
      printf -v val "\\%03o\%03o" \
        $((  (${2}>> 6)      |0xc0 )) \
        $(( ( ${2}     &0x3f)|0x80 ))
    else
      printf -v val '\\U%08x' "${2}"
    fi
    printf -v ${1:?Missing Dest Variable} ${val}
  }
  function chr_eascii {
    local val
    # Make sure value less than 0x100
    # otherwise we end up with 
    # \xVVNNNNN 
    # where \xVV = char && NNNNN is a number string
    # so chr "0x44321" => "D321"
    [[ ${2:?Missing Ordinal Value} -lt 0x100 ]] || return 1
    printf -v val '\\x%02x' "${2}"
    printf -v ${1:?Missing Dest Variable} ${val}
  }
  function test_utf8_mode {
    local TTYPE="${LC_ALL:-${LC_CTYPE:-${LANG:-C}}}"
    TTYPE="${TTYPE%%@*}"
    [[ ${TTYPE##*.} = UTF-8 ]]
    #locale |  grep "LC_CTYPE=.*UTF-8"  >/dev/null
  }
  function chr {
    if test_utf8_mode; then
      chr_utf8 "${@}"
    else
      chr_eascii "${@}"
    fi
  }
  function chr_dec {
    # strip leading 0s otherwise 
    # interpreted as Octal
    chr "${1:-}" "${2#${2%%[!0]*}}"
  }
  function chr_oct {
    chr "${1:-}" "0${2:?Missing Ordinal Value}"
  }
  function chr_hex {
    chr "${1:-}" "0x${2:?Missing Ordinal Value}"
  }
  function chr_utf8_echo {
    local val
    [[ ${1:?Missing Ordinal Value} -lt 0x80000000 ]] || return 1

    if [[ ${1} -lt 0x100 && ${1} -ge 0x80 ]]; then
      # some kinda weird bash? behavior
      # treats \Uff as \xff so encode manually
      printf -v val '\\%03o\\%03o' $(( (${1}>>6)|0xc0 )) $(( (${1}&0x3f)|0x80 ))
    else
      printf -v val '\\U%08x' "${1}"
    fi
    printf "${val}"
  }
  function chr_eascii_echo {
    local val
    # Make sure value less than 0x100
    # otherwise we end up with 
    # \xVVNNNNN 
    # where \xVV = char && NNNNN is a number string
    # so chr "0x44321" => "D321"
    [[ ${1:?Missing Ordinal Value} -lt 0x100 ]] || return 1
    printf -v val '\\x%x' "${1}"
    printf "${val}"
  }
  function chr_echo {
    if test_utf8_mode; then
      chr_utf8_echo "${@}"
    else
      chr_eascii_echo "${@}"
    fi
  }
  function chr_dec_echo {
    # strip leading 0s otherwise 
    # interpreted as Octal
    chr_echo  "${1#${1%%[!0]*}}"
  }
  function chr_oct_echo {
    chr_echo "0${1:?Missing Ordinal Value}"
  }
  function chr_hex_echo {
    chr_echo "0x${1:?Missing Ordinal Value}"
  }

  function GetLinesInString {
    local IFS=$'\v'
    local -a LinesInText=(.${2//$'\n'/$'\v'}.)
    printf -v "${1:?Missing Destination Variable}" "%s" ${#LinesInText[@]}
  }
  function GetLinesInString_1 {
		# takes half the time of GetLinesInString
		# but it ignores empty lines
    local IFS=$'\n'
    local -a LinesInText=(.${2}.)
    printf -v "${1:?Missing Destination Variable}" "%s" ${#LinesInText[@]}
  }
  function GetLinesInString_2 {
    local LinesCnt="${2//[!$'\n']}."
    printf -v "${1:?Missing Destination Variable}" "%s" ${#LinesCnt}
  }
  function GetLinesInString_3 {
 		printf -v "${1:?Missing Destination Variable}" "%s" $(echo "${2}" | wc --lines)
  }
  function GetLinesInString_echo {
    local IFS=$'\v'
    local -a LinesInText=(.${1//$'\n'/$'\v'}.)
    echo -n ${#LinesInText[@]}
  }
  function GetLongestLineInString_1 {
    local LLine=0
    while IFS= read CLine ; do
      [[ ${LLine} -ge ${#CLine} ]] || LLine=${#CLine}
    done <<< "${2?Missing Source String}"
    set_variable "${1:?Missing Destination Variable Name}" "${LLine}" || return $?
  }
  function GetLongestLineInString_1_echo {
    local LLine=0
    while IFS= read -r CLine ; do
      [[ ${LLine} -ge ${#CLine} ]] || LLine=${#CLine}
    done <<< "${1?Missing Source String}"
    echo -n "${LLine}"
  }
  function GetLongestLineInString_2_echo {
    echo "${1}" | awk '{ if (length($0) > max) {max = length($0)} } END { print max }'     || true
  }
  function GetLongestLineInString_echo {
    echo "${1}" | wc --max-line-length      || true
  }
  function GetLongestLineInArray_echo {
    PrintArray "${@}" | wc --max-line-length    || true
  }

  #########################################################################
  # Module Argument Handling
  #########################################################################
  function Set_StrFuncs_Flags {
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
  #push_element RequiredDebianPackages  <Package Name> ...
  #push_element RequiredRpmPackages     <Package Name> ...
  #push_element RequiredGentooPackages  <Package Name> ...
  #push_element RequiredSolarisPackages <Package Name> ...
  #push_element RequiredFreeBsdPackages <Package Name> ...
  #push_element RequiredSusePackages    <Package Name> ...

  StrFuncsRevision=$(CleanRevision '$Revision: 64 $')
  StrFuncsDescription=''
  push_element  ScriptsLoaded "StrFuncs.sh;${StrFuncsRevision};${StrFuncsDescription}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "StrFuncs.sh" ]; then 
  ScriptRevision="${StrFuncsRevision}"

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
  push_element ModulesArgHandlers SupportCallingFileFuncs "Set_StrFuncs_Flags" "Set_StrFuncs_exec_Flags"
  #push_element SupportedCLIOptions 
  function Set_StrFuncs_exec_Flags {
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
  SourceCoreFiles_ "TesterFuncs.sh"

  echo "###############################################"
  echo "# ${SBaseName2} $(gettext "Test Module")"
  echo "###############################################"
  Textq="


  testtegsdgds
	dsdfsdfn  d dfbs fhg sdfg
	sfg sdfg



    sdfgsfdg sd
    s dfgsfdg
    sd sdfgdsfg
    df gs
  


  testtegsdgds
	dsdfsdfn  d dfbs fhg sdfg
	sfg sdfg



    sdfgsfdg sd
    s dfgsfdg
    sd sdfgdsfg
    df gs
  
		

  testtegsdgds
	dsdfsdfn  d dfbs fhg sdfg
	sfg sdfg



    sdfgsfdg sd
    s dfgsfdg
    sd sdfgdsfg
    df gs
  
		


  testtegsdgds
	dsdfsdfn  d dfbs fhg sdfg
	sfg sdfg



    sdfgsfdg sd
    s dfgsfdg
    sd sdfgdsfg
    df gs
  
		

		
		"
  declare -i ECnt=0

  test_FuncType_echo   GetLinesInString_echo    "$(EncodeArgs 0 1         "${Textq}" 58)"  || ECnt+=${?}
  test_FuncType_RETURN GetLinesInString         "$(EncodeArgs 0 2 _RETURN "${Textq}" 58)"  || ECnt+=${?}
  #test_FuncType_RETURN GetLinesInString_1       "$(EncodeArgs 0 2 _RETURN "${Textq}" 38)"  || ECnt+=${?}
  test_FuncType_RETURN GetLinesInString_2       "$(EncodeArgs 0 2 _RETURN "${Textq}" 58)"  || ECnt+=${?}
  test_FuncType_RETURN GetLinesInString_3       "$(EncodeArgs 0 2 _RETURN "${Textq}" 58)"  || ECnt+=${?}
  test_FuncType_RETURN GetLongestLineInString_1 "$(EncodeArgs 0 2 _RETURN "${Textq}" 26)" || ECnt+=${?}
  test_FuncType_echo   GetLongestLineInString_1_echo  "$(EncodeArgs 0 1   "${Textq}" 26)" || ECnt+=${?}
  test_FuncType_echo   GetLongestLineInString_2_echo  "$(EncodeArgs 0 1   "${Textq}" 26)" || ECnt+=${?}
  test_FuncType_echo   GetLongestLineInString_echo    "$(EncodeArgs 0 1   "${Textq}" 33)" || ECnt+=${?}
  test_FuncType_echo   GetLongestLineInArray_echo     "$(EncodeArgs 0 1   "${Textq}" 33)" || ECnt+=${?}
  time_test_func GetLinesInString _RETURN "${Textq}"
  time_test_func GetLinesInString_1 _RETURN "${Textq}"
  time_test_func GetLinesInString_2 _RETURN "${Textq}"
  time_test_func GetLinesInString_3 _RETURN "${Textq}"
  time_test_func GetLinesInString_echo "${Textq}"
  #time_test_func GetLongestLineInString_1 _RETURN "${Textq}"
  #time_test_func GetLongestLineInString_1_echo "${Textq}"
  #time_test_func GetLongestLineInString_echo "${Textq}"

  test_FuncType_echo      chr_echo  "$(EncodeArgs 0 1 "$(ord_echo  "A")"  "A" )" \
                                    "$(EncodeArgs 0 1 "$(ord_echo  "ö")"  "ö" )"  || ECnt+=${?}
  test_FuncType_echo      ord_echo  "$(EncodeArgs 0 1 "$(chr_echo "65")"  "65" )"   || ECnt+=${?}
  test_FuncType_RETURN      chr "$(EncodeArgs 0 2 _RETURN "$(ord_echo  "A")"  "A" )"  || ECnt+=${?}
  test_FuncType_RETURN      ord "$(EncodeArgs 0 2 _RETURN "$(chr_echo "65")"  "65" )"   || ECnt+=${?}
  test_FuncType_RETURN      chr "$(EncodeArgs 0 2 _RETURN "$(ord_echo  "ö")"  "ö" )"  || ECnt+=${?}

  test_FuncType_echo      chr_echo "$(EncodeArgs 0 1 "65"     A )" \
                                   "$(EncodeArgs 0 1 "065"    5 )"  || ECnt+=${?}
  test_FuncType_echo      chr_dec_echo "$(EncodeArgs 0 1 "065"    A )"  || ECnt+=${?}
  test_FuncType_echo      chr_oct_echo "$(EncodeArgs 0 1 "65"     5 )"  || ECnt+=${?}
  test_FuncType_echo      chr_hex_echo "$(EncodeArgs 0 1 "65"     e )"  || ECnt+=${?}
  test_FuncType_RETURN      chr "$(EncodeArgs 0 2 _RETURN "65"     A )" \
                                "$(EncodeArgs 0 2 _RETURN "065"    5 )"   || ECnt+=${?}
  test_FuncType_RETURN      chr_dec "$(EncodeArgs 0 2 _RETURN "065"    A )"   || ECnt+=${?}
  test_FuncType_RETURN      chr_oct "$(EncodeArgs 0 2 _RETURN "65"     5 )"   || ECnt+=${?}
  test_FuncType_RETURN      chr_hex "$(EncodeArgs 0 2 _RETURN "65"     e )"   || ECnt+=${?}

  test_FuncType_RETURN      chr_eascii "$(EncodeArgs 0 2 _RETURN 0xff   $'\xff'     )"  || ECnt+=${?}
  test_FuncType_RETURN      chr_utf8  "$(EncodeArgs 0 2 _RETURN 0x7f   $'\u7f'      )" \
                                      "$(EncodeArgs 0 2 _RETURN 0xff   $'\303\277'  )" \
                                      "$(EncodeArgs 0 2 _RETURN 0x100  $'\u100'     )" \
                                      "$(EncodeArgs 0 2 _RETURN 0x1000 $'\u1000'    )" \
                                      "$(EncodeArgs 0 2 _RETURN 0xffff $'\uffff'    )"  \
                        || ECnt+=${?}

  test_FuncType_RETURN      ord_utf8    "$(EncodeArgs 0 2 _RETURN "A"           65    )" \
                                        "$(EncodeArgs 0 2 _RETURN "ä"          228    )" \
                                        "$(EncodeArgs 0 2 _RETURN $'\303\277'  255    )" \
                                        "$(EncodeArgs 0 2 _RETURN $'\u100'     256    )"  \
                        || ECnt+=${?}

  test_FuncType_RETURN      chr_utf8_m  "$(EncodeArgs 0 2 _RETURN 0x7f     $'\u7f'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0xff     $'\303\277' )"  \
                                        "$(EncodeArgs 0 2 _RETURN 0x100    $'\u100'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x7ff    $'\u7ff'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x800    $'\u800'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0xFFFF   $'\uffff'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x10000  $'\U10000'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x1FFFFF     $'\U1FFFFF'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x200000     $'\U200000'    )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x3FFFFFF    $'\U3FFFFFF'   )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x4000000    $'\U4000000'   )" \
                                        "$(EncodeArgs 0 2 _RETURN 0x7FFFFFFF   $'\U7FFFFFFF'  )" \
                        || ECnt+=${?}
  if [[ ${ECnt} -gt 0 ]]; then
    sError_Exit 5 "${ECnt} $(gettext "Tests failed")"
  else
    sDebugOut "$(gettext "All tests passed")"
    sNormalExit 0
  fi
fi

