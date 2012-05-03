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
#I              File Name            : ArrayFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : ArrayFuncs.sh
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
    source "${ScriptDir}/GenFuncs.sh"
  else
    echo "# "
    echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
    echo "# "
    exit 7
  fi
fi

if [ -z "${__ArrayFuncs_sh__:-}" ]; then
  __ArrayFuncs_sh__=1


  # check_valid_var_name VariableName
  function check_valid_var_name {
    case "${1:?Missing Variable Name}" in
      [!a-zA-Z_]* | *[!a-zA-Z_0-9]* ) return 3;;
    esac
  }
  function check_valid_var_name_alt2 {
    (unset "${1:?Missing Variable Name}" 2>/dev/null)  || return 3 
  }
  function check_valid_var_name_alt3 {
    [[ ${1:?Missing Variable Name} =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]] || return 3
  }
  function check_valid_var_name_alt4 {
    local "${1:?Missing Variable Name}" 2>/dev/null  || return 3 
    unset "${1}" 2>/dev/null  || return 3 
  }
  function check_valid_var_name_alt5 {
    [ "${1:?Missing Variable Name}" = "${1//[!a-zA-Z0-9_]}" ] || return 3
  }
  # set_variable VariableName [<Variable Value>]
  function set_variable {
		printf -v "${1:?Missing Destination Variable Name}" "%s" "${2:-}" || ErrorOut 1 "$(gettext "Error setting variable")" "${1}"
    #check_valid_var_name "${1:?Missing Variable Name}" || return $?
    #eval "${1}"'="${2:-}"' || ErrorOut 1 "$(gettext "Error setting variable")" "${1}"
  }
  # get_array_element VariableName ArrayName ArrayElement
  function get_array_element {
    check_valid_var_name "${1:?Missing Variable Name}" || return $?
    check_valid_var_name "${2:?Missing Array Name}" || return $?
    #echo "${1}=\${${2}[${3:?Missing Array Index}]}"
    eval "${1}"'="${'"${2}"'["${3:?Missing Array Index}"]}"' || ErrorOut 1 "$(gettext "Error setting variable")" "${1}"
  }
 	function get_array_element_echo {
    check_valid_var_name "${1:?Missing Array Name}" || return $?
		eval echo "\"\${${1}[${2:?Missing Array Index}]}\""
  }
  # set_array_element ArrayName ArrayElement [<Variable Value>]
  function set_array_element {
    check_valid_var_name "${1:?Missing Array Name}" || return $?
    eval "${1}"'["${2:?Missing Array Index}"]="${3:-}"'
  }
  # unset_array_element ArrayName ArrayElement
  function unset_array_element {
    unset "${1}[${2}]"
  }
  # unset_array_element VarName ArrayName
  function get_array_element_cnt {
    check_valid_var_name "${1:?Missing Variable Name}" || return $?
    check_valid_var_name "${2:?Missing Array Name}" || return $?
    eval "${1}"'="${#'"${2}"'[@]}"'
  }
  # push_element ArrayName <New Element 1> [<New Element 2> ...]
  function push_element {
    check_valid_var_name "${1:?Missing Array Name}" || return $?
    local ArrayName="${1}"
    local LastElement
    eval 'LastElement="${#'"${ArrayName}"'[@]}"'
    while shift && [ $# -gt 0 ] ; do
      eval "${ArrayName}"'["${LastElement}"]="${1}"'
      let LastElement+=1
    done
  }
  # pop_element ArrayName <Destination Variable Name 1> [<Destination Variable Name 2> ...]
  function pop_element {
    check_valid_var_name "${1:?Missing Array Name}" || return $?
    local ArrayName="${1}"
    local LastElement
    eval 'LastElement="${#'"${ArrayName}"'[@]}"'
    while shift && [[ $# -gt 0 && ${LastElement} -gt 0 ]] ; do
      let LastElement-=1
      check_valid_var_name "${1:?Missing Variable Name}" || return $?
      eval "${1}"'="${'"${ArrayName}"'["${LastElement}"]}"'
      unset "${ArrayName}[${LastElement}]" 
    done
    [[ $# -eq 0 ]] || return 8
  }
  # shift_element ArrayName [<Destination Variable Name>]
  function shift_element {
    check_valid_var_name "${1:?Missing Array Name}" || return $?
    local ArrayName="${1}"
    local CurElement=0 LastElement
    eval 'LastElement="${#'"${ArrayName}"'[@]}"'
    while shift && [[ $# -gt 0 && ${LastElement} -gt ${CurElement} ]] ; do
      check_valid_var_name "${1:?Missing Variable Name}" || return $?
      eval "${1}"'="${'"${ArrayName}"'["${CurElement}"]}"'
      let CurElement+=1
    done
    eval "${ArrayName}"'=("${'"${ArrayName}"'[@]:${CurElement}}")'
    [[ $# -eq 0 ]] || return 8
  }
  # unshift_element ArrayName <New Element 1> [<New Element 2> ...]
  function unshift_element {
    check_valid_var_name "${1:?Missing Array Name}" || return $?
    [ $# -gt 1 ] || return 0
    eval "${1}"'=("${@:2}" "${'"${1}"'[@]}" )'
  }


  ArrayFuncsRevision=$(CleanRevision '$Revision: 64 $')
  push_element  ScriptsLoaded "ArrayFuncs.sh;${ArrayFuncsRevision}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "ArrayFuncs.sh" ]; then 
  ScriptRevision="${ArrayFuncsRevision}"

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
  #push_element ModulesArgHandlers
  #push_element SupportedCLIOptions 
  MainOptionArg ""  "${@}"

  #########################################################################
  # MAIN PROGRAM
  #########################################################################
	SourceCoreFiles_ "TesterFuncs.sh"

  TestArray=("testqdd   dd" "testg" "sdgsdg    dd")
  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"
  sRunProg push_element TestArray "Push    1" "Push    2"

  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"
  sRunProg unshift_element TestArray "Shift    1" "Shift    2" "Shift    3"
  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"

  pop_element TestArray pop_elemen1
  echo "pop_element=\"${pop_elemen1}\""
  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"

  shift_element TestArray shift_element1
  echo "shift_element=\"${shift_element1}\""
  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"

  pop_element TestArray pop_elemen1
  echo "pop_element=\"${pop_elemen1}\""
  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"

  shift_element TestArray shift_element1
  echo "shift_element=\"${shift_element1}\""
  echo "TestArray=$(CreateEscapedArgList "${TestArray[@]}")"

    # Allow us to set IFS for 1 assigment
  Array1=( "Var 1" "Var 2" "Var 3" "Var 4" )
  IFS=";" eval 'echo "${Array1[*]}"'                    
  IFS=";" eval 'JoinedVariable="${Array1[*]}"' 
  echo "${JoinedVariable}"                   
  # joins each array element with a ";"

  IFS=";" eval 'Array2=(${JoinedVariable})'  
  # splits the string at ";"
  IFS="_" eval 'echo "${Array2[*]}"'  
  set_variable "laksdpaso" "dasädöas# #-c,c pos 9302 1´ "
  set_variable "la=k echo del  /*" "dasädöas# #-c,c pos 9302 1´ " 

  declare -ga CheckValidTestCases 
  AddTestCase CheckValidTestCases  0 1 "la" ""
  AddTestCase CheckValidTestCases  3 1 "la=k echo del  /*" ""
  test_FuncType_return_only check_valid_var_name      "${CheckValidTestCases[@]}"
  test_FuncType_return_only check_valid_var_name_alt2 "${CheckValidTestCases[@]}"
  test_FuncType_return_only check_valid_var_name_alt3 "${CheckValidTestCases[@]}"
  test_FuncType_return_only check_valid_var_name_alt4 "${CheckValidTestCases[@]}"
  test_FuncType_return_only check_valid_var_name_alt5 "${CheckValidTestCases[@]}"

  
  time_test_func set_variable "la=k echo del  /*" "dasädöas# #-c,c pos 9302 1´ " 
  time_test_func check_valid_var_name      "la"
  time_test_func check_valid_var_name_alt2 "la"
  time_test_func check_valid_var_name_alt3 "la"
  time_test_func check_valid_var_name_alt4 "la"
  time_test_func check_valid_var_name_alt5 "la"
  time_test_func check_valid_var_name_alt2 "la=k echo del  /*"
  time_test_func check_valid_var_name_alt3 "la=k echo del  /*"
  time_test_func check_valid_var_name_alt4 "la=k echo del  /*"
  time_test_func check_valid_var_name_alt5 "la=k echo del  /*"
  time_test_func check_valid_var_name      "la=k echo del  /*"
  time_test_func eval "laksdpaso=dasädöas# #-c,c pos 9302 1´ "
  time_test_func declare "laksdpaso=dasädöas# #-c,c pos 9302 1´ "
  time_test_func set_variable "laksdpaso" "dasädöas# #-c,c pos 9302 1´ "
  time_test_func get_array_element  TestVar TestArray 1
  time_test_func set_array_element  TestArray 1 "dfds  edfs fdf df"
  time_test_func set_array_element  TestArray 0
  time_test_func get_array_element_cnt TestVar TestArray
  TestArray=( {1..2000} )
  time_test_func push_element  TestArray "dsf sdf ss s" 
  TestArray=( {1..2000} )
  time_test_func pop_element  TestArray TestVar
  TestArray=( {1..2000} )
  time_test_func unshift_element  TestArray "dsf sdf ss s" 
  TestArray=( {1..2000} )
  time_test_func shift_element TestArray TestVar 
  
  sNormalExit 0
fi

