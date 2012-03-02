#!/bin/bash
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/DetectDistro.sh $
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
#I  File Name            : DetectDistro.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: DetectDistro.sh 51 2012-01-17 12:33:18Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__DetectDistro_sh__:-}" ]; then
	__DetectDistro_sh__=1

	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	#SourceCoreFiles_ "DiskFuncs.sh" "CreateMasterList.sh" "ScriptWrappers.sh"


	OS=`uname -s`
	REV=`uname -r`
	MACH=`uname -m`

	GetVersionFromFile()
	{
		VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
	}

	if [ "${OS}" = "SunOS" ] ; then
		OS=Solaris
		ARCH=`uname -p`	
		OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
	elif [ "${OS}" = "AIX" ] ; then
		OSSTR="${OS} `oslevel` (`oslevel -r`)"
	elif [ "${OS}" = "Linux" ] ; then
		KERNEL=`uname -r`
		if [ -f /etc/redhat-release ] ; then
			DIST='RedHat'
			PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
			REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/SUSE-release ] ; then
			DIST=`cat /etc/SUSE-release | tr "\n" ' '| sed s/VERSION.*//`
			REV=`cat /etc/SUSE-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/fedora-release ] ; then
			DIST=`cat /etc/fedora-release | tr "\n" ' '| sed s/VERSION.*//`
			REV=`cat /etc/fedora-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/slackware-release ] ; then
			DIST=`cat /etc/slackware-release | tr "\n" ' '| sed s/VERSION.*//`
			REV=`cat /etc/slackware-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/gentoo-release ] ; then
			DIST=`cat /etc/gentoo-release | tr "\n" ' '| sed s/VERSION.*//`
			REV=`cat /etc/gentoo-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/lsb-release ] ; then
			DIST=`cat /etc/lsb-release | tr "\n" ' '| sed s/VERSION.*//`
			REV=`cat /etc/lsb-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/mandrake-release ] ; then
			DIST='Mandrake'
			PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
			REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/debian_version ] ; then
			DIST="Debian `cat /etc/debian_version`"
			REV=""

		fi
		if [ -f /etc/UnitedLinux-release ] ; then
			DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
		fi
		
		OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"

	fi


	echo ${OSSTR}

	if [ "${SBaseName2}" = "DetectDistro.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 51 $')

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

		SetLogFileName "&1"

		sLogOut "${0}" "$@"

		#########################################################################
		# Argument Processing
		#########################################################################
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
					-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
					*)
						push_element "${ArrayName}" "${1}"
						;;
				esac
				shift
			done
		}
		CommonOptionArg ArgFiles "${@}"
		MainOptionArg ArgFiles  "${ArgFiles[@]}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"

		sNormalExit 0
	fi
fi

