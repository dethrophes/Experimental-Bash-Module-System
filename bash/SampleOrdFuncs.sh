#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               JK Script Tools
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/SampleOrdFuncs.sh $
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
#I  File Name            : StrFuncs.sh
#I  File Location        : scripts/bash
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: SampleOrdFuncs.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>
  ###############################################################
  #
  #       Note about Ext Ascii and UTF-8 encoding
  #
  # for values 0x00   - 0x7f        Identical
  # for values 0x80   - 0xff        conflict between UTF-8 & ExtAscii
  # for values 0x100  - 0xffff      Only UTF-8 UTF-16 UTF-32
  # for values 0x100  - 0x7FFFFFFF  Only UTF-8 UTF-32
  #
  # value         EAscii   UTF-8                          UTF-16  UTF-32
  # 0x20          "\x20"  "\x20"                          \u0020  \U00000020
  # 0x20          "\x7f"  "\x7f"                          \u007f  \U0000007f
  # 0x80          "\x80"  "\xc2\x80"                      \u0080  \U00000080
  # 0xff          "\xff"  "\xc3\xbf"                      \u00ff  \U000000ff
  # 0x100         N/A     "\xc4\x80"                      \u0100  \U00000100
  # 0x1000        N/A     "\xc8\x80"                      \u1000  \U00001000
  # 0xffff        N/A     "\xef\xbf\xbf"                  \uffff  \U0000ffff
  # 0x10000       N/A     "\xf0\x90\x80\x80"              N/A     \U00010000
  # 0xfffff       N/A     "\xf3\xbf\xbf\xbf"              N/A     \U000fffff
  # 0x10000000    N/A     "\xfc\x90\x80\x80\x80\x80"      N/A     \U10000000
  # 0x7fffffff    N/A     "\xfd\xbf\xbf\xbf\xbf\xbf"      N/A     \U7fffffff
  # 0x80000000    N/A     N/A                             N/A     N/A
  # 0xffffffff    N/A     N/A                             N/A     N/A

  ###########################################################################
  ## ord family
  ###########################################################################
  # ord        <Return Variable Name> <Char to convert> [Optional Format String]
  # ord_hex    <Return Variable Name> <Char to convert>
  # ord_oct    <Return Variable Name> <Char to convert>
  # ord_utf8   <Return Variable Name> <Char to convert> [Optional Format String]
  # ord_eascii <Return Variable Name> <Char to convert> [Optional Format String]
  # ord_echo                      <Char to convert> [Optional Format String]
  # ord_hex_echo                  <Char to convert>
  # ord_oct_echo                  <Char to convert>
  # ord_utf8_echo                 <Char to convert> [Optional Format String]
  # ord_eascii_echo               <Char to convert> [Optional Format String]
  #
  # Description:
  # converts character using native encoding to its decimal value and stores
  # it in the Variable specified
  #
  #       ord
  #       ord_hex         output in hex
  #       ord_hex         output in octal
  #       ord_utf8        forces UTF8 decoding
  #       ord_eascii      forces eascii decoding
  #       ord_echo        prints to stdout
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
  # chr_utf8_echo                  <Integer to convert>
  # chr_eascii_echo                <Integer to convert>
  # chr_echo                       <Integer to convert>
  # chr_oct_echo                   <Octal number to convert>
  # chr_hex_echo                   <Hex number to convert>
  #
  # Description:
  # converts decimal value to character representation an stores
  # it in the Variable specified
  #
  #       chr                     Tries to guess output format
  #       chr_utf8                forces UTF8 encoding
  #       chr_eascii              forces eascii encoding
  #       chr_echo                prints to stdout
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
      printf -v "${1:?Missing Dest Variable}" ""
      return 1
    fi
    printf -v "${1:?Missing Dest Variable}" "${val}"
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
    printf -v "${1:?Missing Dest Variable}" "${val}"
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
    printf -v "${1:?Missing Dest Variable}" "${val}"
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
    if shopt extglob &>/dev/null ;then 
			chr "${1:-}" "${2/#+(0)}"
    else
      shopt -s extglob
			chr "${1:-}" "${2/#+(0)}"
      shopt -u extglob
    fi
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
    if shopt extglob &>/dev/null ;then 
      chr_echo "${1/#+(0)}"
    else
			shopt -s extglob
			chr_echo "${1/#+(0)}"
			shopt -u extglob
    fi
  }
  function chr_oct_echo {
    chr_echo "0${1:?Missing Ordinal Value}"
  }
  function chr_hex_echo {
    chr_echo "0x${1:?Missing Ordinal Value}"
  }

  #
  # Simple Validation code
  #
  function test_echo_func {
          local Outcome _result
          _result="$( "${1}" "${2}" )"
          [ "${_result}" = "${3}" ] && Outcome="Pass" || Outcome="Fail"
          printf "  # %-20s %-6s => "           "${1}" "${2}" "${_result}" "${3}" 
          printf "[ "%16q" = "%-16q"%-5s ] "  "${_result}" "${3}" "(${3//[[:cntrl:]]/_})" 
          printf "%s\n"                       "${Outcome}"
  }   
  function test_value_func {
          local Outcome _result
          "${1}" _result "${2}"
          [ "${_result}" = "${3}" ] && Outcome="Pass" || Outcome="Fail"
          printf "  # %-20s %-6s => "           "${1}" "${2}" "${_result}" "${3}" 
          printf "[ "%16q" = "%-16q"%-5s ] "  "${_result}" "${3}" "(${3//[[:cntrl:]]/_})" 
          printf "%s\n"                       "${Outcome}"
  }   
  test_echo_func  chr_echo "$(ord_echo  "A")"  "A"
  test_echo_func  ord_echo "$(chr_echo "65")"  "65"
  test_echo_func  chr_echo "$(ord_echo  "ö")"  "ö"
  test_value_func chr      "$(ord_echo  "A")"  "A"
  test_value_func ord      "$(chr_echo "65")"  "65"
  test_value_func chr      "$(ord_echo  "ö")"  "ö"
  # chr_echo             65     => [                A = A               (A)   ] Pass
  # ord_echo             A      => [               65 = 65              (65)  ] Pass
  # chr_echo             246    => [      $'\303\266' = $'\303\266'     (ö)  ] Pass
  # chr                  65     => [                A = A               (A)   ] Pass
  # ord                  A      => [               65 = 65              (65)  ] Pass
  # chr                  246    => [      $'\303\266' = $'\303\266'     (ö)  ] Pass
  #

  test_echo_func  chr_echo     "65"     A
  test_echo_func  chr_echo     "065"    5
  test_echo_func  chr_dec_echo "065"    A
  test_echo_func  chr_oct_echo "65"     5
  test_echo_func  chr_hex_echo "65"     e
  test_value_func chr          "65"     A
  test_value_func chr          "065"    5
  test_value_func chr_dec      "065"    A
  test_value_func chr_oct      "65"     5
  test_value_func chr_hex      "65"     e
  # chr_echo             65     => [                A = A               (A)   ] Pass
  # chr_echo             065    => [                5 = 5               (5)   ] Pass
  # chr_dec_echo         065    => [                A = A               (A)   ] Pass
  # chr_oct_echo         65     => [                5 = 5               (5)   ] Pass
  # chr_hex_echo         65     => [                e = e               (e)   ] Pass
  # chr                  65     => [                A = A               (A)   ] Pass
  # chr                  065    => [                5 = 5               (5)   ] Pass
  # chr_dec              065    => [                A = A               (A)   ] Pass
  # chr_oct              65     => [                5 = 5               (5)   ] Pass
  # chr_hex              65     => [                e = e               (e)   ] Pass

  #test_value_func chr          0xff   $'\xff'    
  test_value_func chr_eascii   0xff   $'\xff'    
  test_value_func chr_utf8     0xff   $'\uff'      # Note this fails because bash encodes it incorrectly
  test_value_func chr_utf8     0xff   $'\303\277'    
  test_value_func chr_utf8     0x100  $'\u100'    
  test_value_func chr_utf8     0x1000 $'\u1000'   
  test_value_func chr_utf8     0xffff $'\uffff'   
  # chr_eascii           0xff   => [          $'\377' = $'\377'         (�)   ] Pass
  # chr_utf8             0xff   => [      $'\303\277' = $'\377'         (�)   ] Fail
  # chr_utf8             0xff   => [      $'\303\277' = $'\303\277'     (ÿ)  ] Pass
  # chr_utf8             0x100  => [      $'\304\200' = $'\304\200'     (Ā)  ] Pass
  # chr_utf8             0x1000 => [  $'\341\200\200' = $'\341\200\200' (က) ] Pass
  # chr_utf8             0xffff => [  $'\357\277\277' = $'\357\277\277' (���) ] Pass
  test_value_func ord_utf8     "A"           65   
  test_value_func ord_utf8     "ä"          228   
  test_value_func ord_utf8     $'\303\277'  255   
  test_value_func ord_utf8     $'\u100'     256   
  # ord_utf8             A      =>   # 65                   65     => [               65 = 65              (65)  ] Pass
  # ord_utf8             ä     =>   # 228                  228    => [              228 = 228             (228) ] Pass
  # ord_utf8             ÿ     =>   # 255                  255    => [              255 = 255             (255) ] Pass
  # ord_utf8             Ā     =>   # 256                  256    => [              256 = 256             (256) ] Pass



  test_value_func chr_utf8_m   0x7f     $'\u7f'   
  test_value_func chr_utf8_m   0xff     $'\uff'   
  test_value_func chr_utf8_m   0x100    $'\u100'   
  test_value_func chr_utf8_m   0x7ff    $'\u7ff'   
  test_value_func chr_utf8_m   0x800    $'\u800'   
  test_value_func chr_utf8_m   0xFFFF   $'\uffff'   
  test_value_func chr_utf8_m   0x10000  $'\U10000'   
  test_value_func chr_utf8_m   0x1FFFFF     $'\U1FFFFF'   
  test_value_func chr_utf8_m   0x200000     $'\U200000'   
  test_value_func chr_utf8_m   0x3FFFFFF    $'\U3FFFFFF'   
  test_value_func chr_utf8_m   0x4000000    $'\U4000000'   
  test_value_func chr_utf8_m   0x7FFFFFFF   $'\U7FFFFFFF'   
  # chr_utf8_m           0x7f   =>   #                           => [          $'\177' = $'\177'         (_)   ] Pass
  # chr_utf8_m           0xff   =>   # ÿ                   �      => [      $'\303\277' = $'\377'         (�)   ] Fail
  # chr_utf8_m           0x100  =>   # Ā                   Ā     => [      $'\304\200' = $'\304\200'     (Ā)  ] Pass
  # chr_utf8_m           0x7ff  =>   # ߿                   ߿     => [      $'\337\277' = $'\337\277'     (߿)  ] Pass
  # chr_utf8_m           0x800  =>   # ࠀ                  ࠀ    => [  $'\340\240\200' = $'\340\240\200' (ࠀ) ] Pass
  # chr_utf8_m           0xFFFF =>   # ���                  ���    => [  $'\357\277\277' = $'\357\277\277' (���) ] Pass
  # chr_utf8_m           0x10000 =>   # 𐀀                 𐀀   => [ $'\360\220\200\200' = $'\360\220\200\200'(𐀀) ] Pass
  # chr_utf8_m           0x1FFFFF =>   # ����                 ����   => [ $'\367\277\277\277' = $'\367\277\277\277'(����) ] Pass
  # chr_utf8_m           0x200000 =>   # �����                �����  => [ $'\370\210\200\200\200' = $'\370\210\200\200\200'(�����) ] Pass
  # chr_utf8_m           0x3FFFFFF =>   # �����                �����  => [ $'\373\277\277\277\277' = $'\373\277\277\277\277'(�����) ] Pass
  # chr_utf8_m           0x4000000 =>   # ������               ������ => [ $'\374\204\200\200\200\200' = $'\374\204\200\200\200\200'(������) ] Pass
  # chr_utf8_m           0x7FFFFFFF =>   # ������               ������ => [ $'\375\277\277\277\277\277' = $'\375\277\277\277\277\277'(������) ] Pass



  #########################################################
  # to help debug problems try this
  #########################################################
  # printf "%q\n" $'\xff'                  # => $'\377'
  # printf "%q\n" $'\uffff'                # => $'\357\277\277'
  # printf "%q\n" "$(chr_utf8_echo 0x100)" # => $'\304\200'
  #
  # This can help a lot when it comes to diagnosing problems 
  # with read and or xterm program output 
  # I use it a lot in error case to create a human readable error message
  # i.e. 
  echo "Type to test, Enter to continue"
  while read -srN1 ; do
    ord asciiValue "${REPLY}"
    case "${asciiValue}" in
      10) echo "Goodbye" ; break ;;
      20|21|22) echo "Yay expected input" ;;
      *) printf ':( Unexpected Input 0x%02x %q "%s"\n' "${asciiValue}" "${REPLY}" "${REPLY//[[:cntrl:]]}" ;;
    esac
  done

  #########################################################
  # More exotic approach 1
  #########################################################
  # I used to use this before I figured out the LC_CTYPE=C approach
  # printf "EAsciiLookup=%q" "$(for (( x=0x0; x<0x100 ; x++)); do printf '%b' $(printf '\\x%02x' "$x"); done)"
  EAsciiLookup=$'\001\002\003\004\005\006\a\b\t\n\v\f\r\016\017\020\021\022\023'
  EAsciiLookup+=$'\024\025\026\027\030\031\032\E\034\035\036\037 !"#$%&\'()*+,-'
  EAsciiLookup+=$'./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi'
  EAsciiLookup+=$'jklmnopqrstuvwxyz{|}~\177\200\201\202\203\204\205\206\207\210'
  EAsciiLookup+=$'\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227'
  EAsciiLookup+=$'\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246'
  EAsciiLookup+=$'\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265'
  EAsciiLookup+=$'\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304'
  EAsciiLookup+=$'\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323'
  EAsciiLookup+=$'\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342'
  EAsciiLookup+=$'\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361'
  EAsciiLookup+=$'\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
  function ord_eascii2 {
    local idx="${EAsciiLookup%%${2:0:1}*}"
    eval ${1}'=$(( ${#idx} +1 ))'
  }

  #########################################################
  # More exotic approach 2
  #########################################################
  #printf "EAsciiLookup2=(\n    %s\n)" "$(for (( x=0x1; x<0x100 ; x++)); do printf '%-18s'  "$(printf '[_%q]="0x%02x"' "$(printf "%b" "$(printf '\\x%02x' "$x")")" $x )" ; [ "$(($x%6))" != "0" ] || echo -en "\n    " ; done)"
  typeset -A EAsciiLookup2
  EAsciiLookup2=(
    [_$'\001']="0x01" [_$'\002']="0x02" [_$'\003']="0x03" [_$'\004']="0x04" 
    [_$'\005']="0x05" [_$'\006']="0x06" [_$'\a']="0x07"   [_$'\b']="0x08"   
    [_$'\t']="0x09"   [_'']="0x0a"      [_$'\v']="0x0b"   [_$'\f']="0x0c"   
    [_$'\r']="0x0d"   [_$'\016']="0x0e" [_$'\017']="0x0f" [_$'\020']="0x10" 
    [_$'\021']="0x11" [_$'\022']="0x12" [_$'\023']="0x13" [_$'\024']="0x14" 
    [_$'\025']="0x15" [_$'\026']="0x16" [_$'\027']="0x17" [_$'\030']="0x18" 
    [_$'\031']="0x19" [_$'\032']="0x1a" [_$'\E']="0x1b"   [_$'\034']="0x1c" 
    [_$'\035']="0x1d" [_$'\036']="0x1e" [_$'\037']="0x1f" [_\ ]="0x20"      
    [_\!]="0x21"      [_\"]="0x22"      [_\#]="0x23"      [_\$]="0x24"      
    [_%]="0x25"       [_\&]="0x26"      [_\']="0x27"      [_\(]="0x28"      
    [_\)]="0x29"      [_\*]="0x2a"      [_+]="0x2b"       [_\,]="0x2c"      
    [_-]="0x2d"       [_.]="0x2e"       [_/]="0x2f"       [_0]="0x30"       
    [_1]="0x31"       [_2]="0x32"       [_3]="0x33"       [_4]="0x34"       
    [_5]="0x35"       [_6]="0x36"       [_7]="0x37"       [_8]="0x38"       
    [_9]="0x39"       [_:]="0x3a"       [_\;]="0x3b"      [_\<]="0x3c"      
    [_=]="0x3d"       [_\>]="0x3e"      [_\?]="0x3f"      [_@]="0x40"       
    [_A]="0x41"       [_B]="0x42"       [_C]="0x43"       [_D]="0x44"       
    [_E]="0x45"       [_F]="0x46"       [_G]="0x47"       [_H]="0x48"       
    [_I]="0x49"       [_J]="0x4a"       [_K]="0x4b"       [_L]="0x4c"       
    [_M]="0x4d"       [_N]="0x4e"       [_O]="0x4f"       [_P]="0x50"       
    [_Q]="0x51"       [_R]="0x52"       [_S]="0x53"       [_T]="0x54"       
    [_U]="0x55"       [_V]="0x56"       [_W]="0x57"       [_X]="0x58"       
    [_Y]="0x59"       [_Z]="0x5a"       [_\[]="0x5b"      #[_\\]="0x5c"      
    #[_\]]="0x5d"      
                      [_\^]="0x5e"      [__]="0x5f"       [_\`]="0x60"      
    [_a]="0x61"       [_b]="0x62"       [_c]="0x63"       [_d]="0x64"       
    [_e]="0x65"       [_f]="0x66"       [_g]="0x67"       [_h]="0x68"       
    [_i]="0x69"       [_j]="0x6a"       [_k]="0x6b"       [_l]="0x6c"       
    [_m]="0x6d"       [_n]="0x6e"       [_o]="0x6f"       [_p]="0x70"       
    [_q]="0x71"       [_r]="0x72"       [_s]="0x73"       [_t]="0x74"       
    [_u]="0x75"       [_v]="0x76"       [_w]="0x77"       [_x]="0x78"       
    [_y]="0x79"       [_z]="0x7a"       [_\{]="0x7b"      [_\|]="0x7c"      
    [_\}]="0x7d"      [_~]="0x7e"       [_$'\177']="0x7f" [_$'\200']="0x80" 
    [_$'\201']="0x81" [_$'\202']="0x82" [_$'\203']="0x83" [_$'\204']="0x84" 
    [_$'\205']="0x85" [_$'\206']="0x86" [_$'\207']="0x87" [_$'\210']="0x88" 
    [_$'\211']="0x89" [_$'\212']="0x8a" [_$'\213']="0x8b" [_$'\214']="0x8c" 
    [_$'\215']="0x8d" [_$'\216']="0x8e" [_$'\217']="0x8f" [_$'\220']="0x90" 
    [_$'\221']="0x91" [_$'\222']="0x92" [_$'\223']="0x93" [_$'\224']="0x94" 
    [_$'\225']="0x95" [_$'\226']="0x96" [_$'\227']="0x97" [_$'\230']="0x98" 
    [_$'\231']="0x99" [_$'\232']="0x9a" [_$'\233']="0x9b" [_$'\234']="0x9c" 
    [_$'\235']="0x9d" [_$'\236']="0x9e" [_$'\237']="0x9f" [_$'\240']="0xa0" 
    [_$'\241']="0xa1" [_$'\242']="0xa2" [_$'\243']="0xa3" [_$'\244']="0xa4" 
    [_$'\245']="0xa5" [_$'\246']="0xa6" [_$'\247']="0xa7" [_$'\250']="0xa8" 
    [_$'\251']="0xa9" [_$'\252']="0xaa" [_$'\253']="0xab" [_$'\254']="0xac" 
    [_$'\255']="0xad" [_$'\256']="0xae" [_$'\257']="0xaf" [_$'\260']="0xb0" 
    [_$'\261']="0xb1" [_$'\262']="0xb2" [_$'\263']="0xb3" [_$'\264']="0xb4" 
    [_$'\265']="0xb5" [_$'\266']="0xb6" [_$'\267']="0xb7" [_$'\270']="0xb8" 
    [_$'\271']="0xb9" [_$'\272']="0xba" [_$'\273']="0xbb" [_$'\274']="0xbc" 
    [_$'\275']="0xbd" [_$'\276']="0xbe" [_$'\277']="0xbf" [_$'\300']="0xc0" 
    [_$'\301']="0xc1" [_$'\302']="0xc2" [_$'\303']="0xc3" [_$'\304']="0xc4" 
    [_$'\305']="0xc5" [_$'\306']="0xc6" [_$'\307']="0xc7" [_$'\310']="0xc8" 
    [_$'\311']="0xc9" [_$'\312']="0xca" [_$'\313']="0xcb" [_$'\314']="0xcc" 
    [_$'\315']="0xcd" [_$'\316']="0xce" [_$'\317']="0xcf" [_$'\320']="0xd0" 
    [_$'\321']="0xd1" [_$'\322']="0xd2" [_$'\323']="0xd3" [_$'\324']="0xd4" 
    [_$'\325']="0xd5" [_$'\326']="0xd6" [_$'\327']="0xd7" [_$'\330']="0xd8" 
    [_$'\331']="0xd9" [_$'\332']="0xda" [_$'\333']="0xdb" [_$'\334']="0xdc" 
    [_$'\335']="0xdd" [_$'\336']="0xde" [_$'\337']="0xdf" [_$'\340']="0xe0" 
    [_$'\341']="0xe1" [_$'\342']="0xe2" [_$'\343']="0xe3" [_$'\344']="0xe4" 
    [_$'\345']="0xe5" [_$'\346']="0xe6" [_$'\347']="0xe7" [_$'\350']="0xe8" 
    [_$'\351']="0xe9" [_$'\352']="0xea" [_$'\353']="0xeb" [_$'\354']="0xec" 
    [_$'\355']="0xed" [_$'\356']="0xee" [_$'\357']="0xef" [_$'\360']="0xf0" 
    [_$'\361']="0xf1" [_$'\362']="0xf2" [_$'\363']="0xf3" [_$'\364']="0xf4" 
    [_$'\365']="0xf5" [_$'\366']="0xf6" [_$'\367']="0xf7" [_$'\370']="0xf8" 
    [_$'\371']="0xf9" [_$'\372']="0xfa" [_$'\373']="0xfb" [_$'\374']="0xfc" 
    [_$'\375']="0xfd" [_$'\376']="0xfe" [_$'\377']="0xff" 
  )
  function ord_eascii3 {
        local -i val="${EAsciiLookup2["_${2:0:1}"]-}"
        if [ "${val}" -eq 0 ]; then
                case "${2:0:1}" in 
                        ])  val=0x5d ;;
                        \\) val=0x5c ;;
                esac
        fi
        eval "${1}"'="${val}"'
  }
  #
  # Some Performance stats
  #
  function time_test_func {
    local TIMEFORMAT=$'%3lR' 
    local IterrationCnt=1000

    printf "  # %-4d x { %-30s } took " ${IterrationCnt} "${*}"
    time for (( i=0 ; i <${IterrationCnt}; i++ )); do "${@}" >/dev/null ; done   
  }
  time_test_func ord TmpVar 'a'
  time_test_func ord_eascii TmpVar 'a'
  time_test_func ord_utf8 TmpVar 'a'
  time_test_func ord_eascii2 TmpVar 'a'
  time_test_func ord_eascii3 TmpVar 'a'
  time_test_func ord_echo 'a'
  time_test_func ord_eascii_echo 'a'
  time_test_func ord_utf8_echo 'a'
  time_test_func chr_utf8 TmpVar 16
  time_test_func chr_utf8 TmpVar 020
  time_test_func chr_utf8 TmpVar 0x10
  time_test_func chr_utf8 TmpVar 0x100
  time_test_func chr_utf8 TmpVar 0x1000
  time_test_func chr_utf8 TmpVar 0x10000
  time_test_func chr_utf8 TmpVar 0x1000000 
  time_test_func chr_utf8 TmpVar 0x3000000 
  time_test_func chr_utf8_m TmpVar 0x10
  time_test_func chr_utf8_m TmpVar 0x100
  time_test_func chr_utf8_m TmpVar 0x1000
  time_test_func chr_utf8_m TmpVar 0x10000
  time_test_func chr_utf8_m TmpVar 0x1000000 
  time_test_func chr_utf8_m TmpVar 0x3000000 
  time_test_func test_utf8_mode
  # 1000 x { ord TmpVar a                   } took 0m0.113s
  # 1000 x { ord_eascii TmpVar a            } took 0m0.112s
  # 1000 x { ord_utf8 TmpVar a              } took 0m0.256s
  # 1000 x { ord_eascii2 TmpVar a           } took 0m1.089s
  # 1000 x { ord_eascii3 TmpVar a           } took 0m0.171s
  # 1000 x { ord_echo a                     } took 0m0.081s
  # 1000 x { ord_eascii_echo a              } took 0m0.091s
  # 1000 x { ord_utf8_echo a                } took 0m0.209s
  # 1000 x { chr_utf8 TmpVar 16             } took 0m0.154s
  # 1000 x { chr_utf8 TmpVar 020            } took 0m0.159s
  # 1000 x { chr_utf8 TmpVar 0x10           } took 0m0.157s
  # 1000 x { chr_utf8 TmpVar 0x100          } took 0m0.152s
  # 1000 x { chr_utf8 TmpVar 0x1000         } took 0m0.152s
  # 1000 x { chr_utf8 TmpVar 0x10000        } took 0m0.153s
  # 1000 x { chr_utf8 TmpVar 0x1000000      } took 0m0.154s
  # 1000 x { chr_utf8 TmpVar 0x3000000      } took 0m0.156s
  # 1000 x { chr_utf8_m TmpVar 0x10         } took 0m0.166s
  # 1000 x { chr_utf8_m TmpVar 0x100        } took 0m0.203s
  # 1000 x { chr_utf8_m TmpVar 0x1000       } took 0m0.228s
  # 1000 x { chr_utf8_m TmpVar 0x10000      } took 0m0.256s
  # 1000 x { chr_utf8_m TmpVar 0x1000000    } took 0m0.287s
  # 1000 x { chr_utf8_m TmpVar 0x3000000    } took 0m0.284s

