#!/bin/bash
#if [ "${DEBUG}" != "1" ]; then stty -echo; fi
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
#I  File Name            : SetEnvJK.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__SetEnvJK_SH__}" ]; then
	__SetEnvJK_SH__="1"

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"


	#########################################################################
	# PROCEDURES
	#########################################################################
	function TestFile {
	  if [ -f "${1}" ]; then 
	    ValidCount="`expr ${ValidCount} + 1`"; 
	    #sDebugOut POS0 ${ValidCount} ${1}
	  fi
	}
	function TestDir {
	  if [ -d "${1}" ]; then 
	    ValidCount="`expr ${ValidCount} + 1`"; 
	    #sDebugOut POS8 ${ValidCount} ${1}
	  fi
	}
	function TestPhoenix {
	  ValidCount=0
	  TestDir "${1}/CPU"
	  TestDir "${1}/CRISIS"
	  TestDir "${1}/INCLUDE.600"
	  TestDir "${1}/tools600"
	  TestDir "${1}/script.600"
	  TestDir "${1}/BUILD"
	  if [ ${ValidCount} -gt 3 ]; then 
	    DirType="PHOENIX"
	    nubios="${1}"
	    return 0
	  fi     
	  return 1
	}
	function TestAmiCore8 {
	  ValidCount=0
	  TestDir "${1}/BSP"
	  TestDir "${1}/CSP"
	  TestDir "${1}/CORE"
	  TestDir "${1}/BUILD"
	  if [ ${ValidCount} -gt 3 ]; then 
	    DirType="AMIBIOS"
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function TestLinuxIEGD {
	  ValidCount=0
	  TestDir "${1}/doxygen"
	  TestDir "${1}/pal"
	  TestDir "${1}/iegd-extra"
	  TestDir "${1}/ral"
	  TestDir "${1}/oal"
	  if [ ${ValidCount} -gt 3  ]; then 
	    DirType="IEGD"
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function TestLinuxKernel {
	  ValidCount=0
	  TestDir "${1}/arch"
	  TestDir "${1}/drivers"
	  TestDir "${1}/block"
	  TestDir "${1}/fs"
	  TestDir "${1}/kernel"
	  TestDir "${1}/net"
	  TestDir "${1}/usr"
	  if [ ${ValidCount} -gt 7 ]; then 
	    DirType="LinuxKernel"
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function TestAlaska {
	  ValidCount=0
	  TestDir "${1}/Addon"
	  TestDir "${1}/Chipset"
	  TestDir "${1}/CORE"
	  TestDir "${1}/BUILD"
	  TestDir "${1}/Platform"
	  if [ ${ValidCount} -gt 4 ]; then 
	    DirType="AMIBIOS"
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function TestMSC8 {
	  ValidCount=0
	  TestFile "${1}/UseMeAsBaseFolderMSC8.bat"
	  TestFile "${1}/UseMeAsBaseFolderMSC8.BAT"
	  if [ ${ValidCount} -gt 0 ]; then 
	    DirType="MSC8."00C
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function TestAward {
	  ValidCount=0
	  TestFile "${1}/bios.mak"
	  TestFile "${1}/bios.bat"
	  TestFile "${1}/bios.cfg"
	  TestFile "${1}/ADDROM.BAT"
	  TestFile "${1}/USERINT.MAC"
	  if [ ${ValidCount} -gt 4 ]; then 
	    DirType="AWARD"
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function TestHome {
	  if [ "${1}" = "${HOME}" ]; then 
	    DirType="HOME"
	    nubios="${1}"
	    return 1
		fi
	  return 0
	}
	function TestUMABF {
	  ValidCount=0
	  TestFile "${1}/UseMeAsBaseFolder.bat"
	  TestFile "${1}/UseMeAsBaseFolder.BAT"
	  TestFile "${1}/UseMeAsBaseFolder.cmd"
	  TestFile "${1}/UseMeAsBaseFolder.CMD"
	  TestFile "${1}/UseMeAsBaseFolder.sh"
	  if [ ${ValidCount} -gt 0 ]; then 
	    DirType="FILEMARK"
			ExtractBatchVariable "${1}/UseMeAsBaseFolder.bat" DirType
			ExtractBatchVariable "${1}/UseMeAsBaseFolder.BAT" DirType
			ExtractBatchVariable "${1}/UseMeAsBaseFolder.cmd" DirType
			ExtractBatchVariable "${1}/UseMeAsBaseFolder.CMD" DirType
	    nubios="${1}"
	    return 0
	  fi
	  return 1
	}
	function LoopDirs {
	  TestUMABF 		  "${1}" && return $? 
	  TestAward 		  "${1}" && return $? 
	  TestMSC8 		    "${1}" && return $? 
	  TestAlaska 		  "${1}" && return $? 
	  TestLinuxKernel "${1}" && return $? 
	  TestLinuxIEGD 	"${1}" && return $? 
	  TestAmiCore8 		"${1}" && return $? 
	  TestPhoenix 		"${1}" && return $? 
	  TestHome				"${1}" && return $? 
	  if [ "${1}" = "$(dirname "${1}")" ]; then 
	    # sDebugOut Last ${1}
	    return 1
	  else
	    LoopDirs "$(dirname "${1}")"
	  fi
	}

	function IdentifyDir {
		#ConsoleStdout "${FUNCNAME}" "${LINENO}" "${@}"
	  if [ -d "${1}" ]; then 
	    DirName1="${1}"
	  elif [ -f "${1}" ]; then
			DirName1="$(dirname "${1}")"
	  else
	    DirType="UNKNOWN"
			nubios="$(pwd)"
	    return 0
	  fi
	  LoopDirs "${DirName1}"
		ReturnValue="$?"
	  #sDebugOut POS4 ${ReturnValue} ${1}
	  if [ ${ReturnValue} -gt 0 ]; then 
	    DirType="UNKNOWN"
	    nubios="${DirName1}"
	  fi
	}
	function ExtractBatchVariable {
	  if [ -f "${1}" ]; then 
	    eval "${2}=$(grep "${2}" ${1} | sed -r -n s/^\\s*SET\\s\+${2}=\\s*\(.*\)/\\1/p)"
	  fi
	  return 0;
	}
	if [ "${SBaseName2}" = "SetEnvJK.sh" ]; then 
		ScriptRevision="$(CleanRevision '$Revision: 64 $')"
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
		MainOptionArg ""  "${@}"

		IdentifyDir "$(pwd)"

		#ConsoleStdout \#I SetEnvJK.sh ........................... \${Revision}: 1.10 $
		#ConsoleStdout \#+-------------------------------------------------------- 
		#ConsoleStdout \#I $(gettext "Directory Type") ${DirType} 
		#ConsoleStdout \#I $(gettext "Using following base folder") ${nubios} 
		#ConsoleStdout \#+--------------------------------------------------------

		[ -f "${nubios}/UseMeAsBaseFolder.sh" ] && source "${nubios}/UseMeAsBaseFolder.sh"

		ReturnString "export DirType=\"${DirType}\"; export nubios=\"${nubios}\";"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		sNormalExit $?; return $?;
	#else
		#IdentifyDir "$(pwd)"
		#export DirType="${DirType}"
		#export nubios="${nubios}"

		#[ -f "${nubios}/UseMeAsBaseFolder.sh" ] && source "${nubios}/UseMeAsBaseFolder.sh"
	fi
fi




