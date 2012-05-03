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
#I Description: Auto Created for aliases.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : aliases.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
alias sedit=$HOME/scripts/bash/sedit.sh
alias grepb=$HOME/scripts/bash/grepb.sh
alias tagit=$HOME/scripts/bash/tagit.sh
alias SetEnvJK=$HOME/scripts/bash/SetEnvJK.sh
alias obnc=$HOME/scripts/bash/obnc.sh
alias oc=$HOME/scripts/bash/oc.sh
alias chbase=eval\ $($HOME/scripts/bash/SetEnvJK.sh)
alias carch=7za\ a\ -t7z\ -m0=lzma\ -mx=9\ -mfb=64\ -md=32m\ -ms=on
alias ll=ls\ -alFh
alias xterm=xterm\ -name\ XTerm
alias ksyncl=rsync\ -Prc\ root@192.168.178.48:/mnt/base-us/documents\ $HOME/Kindle/Clone/documents
alias ksyncr=rsync\ -Prc\ $HOME/Kindle/Clone/documents\ root@192.168.178.48:/mnt/base-us/documents
alias ffox=ffox.sh
alias ralias=source\ '$HOME/scripts/bash/aliases.sh'

function UpdateCalibre {
		sudo python -c "import urllib2; exec urllib2.urlopen('http://status.calibre-ebook.com/linux_installer').read(); main()"
}

function PScripts {
	pushd $HOME/scripts > /dev/null
	svn update bash
	popd > /dev/null
	ralias
}
function UScripts {
	pushd $HOME/scripts > /dev/null
	svn ci bash
	popd > /dev/null
}
if have apt-get ; then
	function sysupdate {
		sudo apt-get update && sudo apt-get upgrade
	}
elif have yum ; then
	function sysupdate {
		sudo yum update
	}
elif have emerge ; then
	function sysupdate {
		sudo emerge -f --update --deep world && sudo emerge --update --deep world && sudo emerge --depclean
	}
fi

function fdoc {
	find "/mnt/DETH00/media/Documentaries/" | grep -iP "${1}" 
}
function ffilm {
	find "/mnt/DETH00/media/Films/" | grep -iP "${1}" 
}
function fepisode {
	find "/mnt/DETH00/media/Episodes/" | grep -iP "${1}" 
}
if [ -d "${HOME}/.local/share/wineprefixes" ]; then
	#
	# Winetricks specific
	#
	prefix() {
		if [ -z "${1}" ]; then 
			WINEPREFIX="${HOME}/.wine/"
		elif [ -d "${HOME}/.local/share/wineprefixes/${1}" ]; then
			WINEPREFIX="${HOME}/.local/share/wineprefixes/${1}"
		else
			echo "ERROR: Unknown prefix \"${1}\""
			return 1
		fi
		export WINEPREFIX
		return 0
	}

	goc() {
		cd "${WINEPREFIX}/drive_c"
	}

	lsp() {
		ls $* "${HOME}/.local/share/wineprefixes"
	}

	run() {
		local WINEPREFIX
		prefix "${1}" || return 1
		pushd "${WINEPREFIX}/drive_c" >/dev/null
		wine cmd /c "run-${1}.bat"
		popd >/dev/null
	}

	complete -W "$(lsp)" prefix run
fi


