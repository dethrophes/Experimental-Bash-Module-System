#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/SortFuncs.sh $
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
#I  File Name            : SortFuncs.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 55 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-26 11:37:11 +0100 (Sun, 26 Feb 2012) $
#I  ID                   : $Id: SortFuncs.sh 55 2012-02-26 10:37:11Z dethrophes $
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -n "${ScriptDir:-}"	] || ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh"
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi

if [ -z "${__SortFuncs_sh__:-}" ]; then
	__SortFuncs_sh__=1

	SourceCoreFiles_ "move.sh"
	#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

	

	#########################################################################
	# Procedures
	#########################################################################

	
	declare -gr SpaceChars="[[:space:](),._-]"
	declare -gr SpaceChars1="[[:space:],._-]"
	declare -gr SpaceCharsL="[([[:space:],._-]"
	declare -gr SpaceCharsR="[])[:space:],._-]"

	declare -gar MatchNumbers=(
			"Zero|zero|null|Zero|ling"
			"One|one|I|ein|Un|yi"
			"Two|two|II|zwei|Deux|er"
			"Three|three|III|drei|Trois|san"
			"Four|four|IV|vier|Quatre|si"
			"Five|five|V|funf|Cinq|wu"
			"Six|six|VI|sechs|Six|liou"
			"Seven|seven|VII|sieben|Sept|chi"
			"Eight|eight|VIII|acht|Huit|ba"
			"Nine|nine|IX|neun|neuf|jiou"
			"Ten|ten|X|zehn|Dix|shr"
	)

	IFS='|' eval 'declare -gr NumWords="${MatchNumbers[*]}"'

	declare -gr MatchYear="19[6-9][0-9]|20[0-8][0-9]"
	declare -gr SeasonNames="Season|Series|Saison|Serie"
	declare -gr EpisodeNames="Part|Ep|Episode|teil"
	declare -gr Match_xofx="[0-9]+${SpaceChars}*of${SpaceChars}*[0-9]"


	Spacer=$'\v'
	function EncodeArgs {
		IFS=${Spacer} eval 'echo "${*}"'
	}
	function DecodedArgs {
		#echo \""2=${2}"\"
		IFS=${Spacer} read -ra ${1} <<< "${2}"
		#IFS=${Spacer} eval ${1}'=( .${2}. )'
		#eval ${1}'[0]="${'${1}'[0]#.}"'
		#eval ${1}'[${#'${1}'[@]}-1]="${'${1}'[${#'${1}'[@]}-1]]%.}"'
	}
	declare -ga EpisodeMatchPaters=(
				# Name.2012.S01E01
				# Name.2012.1x01
				"s/(.+)${SpaceCharsL}+(${MatchYear})${SpaceCharsR}+(S(0?[0-9]+)E[0-9]{2}|([0-9]+)x[0-9]{2}).*/\1${Spacer}\2${Spacer}\4\5/i"
				# Name.S01E01
				# Name.1x01
        "s/(.+)${SpaceChars}+(S(0?[0-9]+)E[0-9]{2}|([0-9]+)x[0-9]{2}).*/\1${Spacer}${Spacer}\3\4/i"
				# Name.201.
        "s/(.+)${SpaceChars}+([0-1]?[0-8]|0?9)[0-9][0-9][^0-9p].*/\1${Spacer}${Spacer}\2/i"
				# Name.Season1
        "s/(.+)(${SpaceChars}+(Collection|${SeasonNames})\.?(${NumWords}))${SpaceChars}.*/\1${Spacer}${Spacer}\4/i"
				# Name.Season.1
				# Name.Season.One
        "s/(.+)(${SpaceChars}+(${SeasonNames})${SpaceChars}?([1-9]|${NumWords}))${SpaceChars}.*/\1${Spacer}${Spacer}\4/i"
				"s/(.+)(${SpaceChars}+(${SeasonNames})${SpaceChars}?([1-9]))?${SpaceChars}+(${EpisodeNames})${SpaceChars}+${Match_xofx}.*/\1${Spacer}${Spacer}\4/i"
				"s/(.+)(${SpaceChars}+(${SeasonNames})${SpaceChars}?([1-9]))?${SpaceChars}+${Match_xofx}.*/\1${Spacer}${Spacer}\4/i"
        "s/(.+)${SpaceChars}+(${EpisodeNames})${SpaceChars}*([0-9]|${NumWords}).*/\1${Spacer}${Spacer}/i"
				# Name.2012
				"s/(.{9}.+)${SpaceCharsL}+(${MatchYear})${SpaceCharsR}+.*/\1${Spacer}\2${Spacer}/i"
				"s/(BBC\..+)${SpaceCharsL}+(${MatchYear})${SpaceCharsR}+.*/\1${Spacer}\2${Spacer}/i"
	)
	function EpisodeName1 {
		local CPatern
		local -i Index=0 Malgorithim=0
		#IFS=${Spacer} _RETURN=( $(basename "${1}" | sed -re "${EpisodeMatchPaters[*]}") ) 
		for CPatern in "${EpisodeMatchPaters[@]}" ; do

			DecodedArgs _RETURN "$(basename "${1}" | sed   -re "${CPatern}")"
			[ ${#_RETURN[@]} -ne 3 ] || break
			Malgorithim+=1
		done
				#sDebugOut "${1}" "${_RETURN[@]}"
		if [ ${#_RETURN[@]} -lt 3 ]; then
			unset _RETURN[@]
			return 1
		fi
		if [ -n "${_RETURN[2]:-}" ]; then
			case "${_RETURN[2]}" in
				0[0-9]*)													_RETURN[2]="${_RETURN[2]#0}"	;;
				*)
					if [[ ${_RETURN[2]} =~ (${NumWords}) ]]; then
						Index=0
						for CPatern in "${MatchNumbers[@]}"; do
							if [[ ${_RETURN[2]} =~ (${CPatern}) ]]; then
								_RETURN[2]=${Index}
							fi
							Index+=1
						done
					fi
					;;
			esac
		fi
		[ ${#_RETURN[@]} -lt 1 ] || _RETURN[0]="$(echo "${_RETURN[0]}"| sed -re "s/${SpaceCharsL}+$//")"

		unshift_element _RETURN "${Malgorithim}" "$(basename "${1}")" "$(dirname "${1}")"
	}
	function FindMatchDir {
		[ $# -eq 1 ] || return 1
		local CFolder FileList CFile
		local -a  FolderMatches FileMatches
		IFS=$'\n' FolderMatches=( $(find "${1}"  -mindepth 1 -maxdepth 1 -type d -exec basename {} \;) )
		[ "${#FolderMatches[@]}" -gt 0 ] || return 0
		FileList="$(find "${1}"  -mindepth 1 -maxdepth 1 -type f -exec basename {} \;)"
		for CFolder in "${FolderMatches[@]}"; do
			#sDebugOut "${CFolder}"
			IFS=$'\n' FileMatches=( $(echo "${FileList}" | grep -F "${CFolder}") )
      [ "${#FileMatches[@]}" -gt 0 ] || continue
			for CFile in "${FileMatches[@]}"; do
					FileName="${1}/${CFolder}"
					if [ ${TestFuncs} -ne 0 ] ; then
						sDebugOut	MoveMain "${1}/${CFile}" "${FileName}"
					else
						SimpleMkdir "${FileName}" 
						if [ -h "${1}/${CFile}" ]; then
							mv "${1}/${CFile}" "${FileName}/${CFile}"
						else
							MoveMain "${1}/${CFile}" "${FileName}"
						fi
					fi
			done
		done
	}
	ChannelNameCleanup=(
			"s/^(DC|Discovery|Discovery.Channel|Discovery.Ch)${SpaceChars}/Discovery.Ch./i"
			"s/^(NG|National.Geographic|National.Geo|Nat.?Geo)${SpaceChars}/National.Geographic./i"
			"s/^(HC|History.Ch|History.Channel)${SpaceChars}/History.Channel./i"
			"s/^(NS|Naked.Science)${SpaceChars}/Naked.Science./i"
			"s/^(Nova)${SpaceChars}/PBS.Nova./i"
			"s/^(PBS)${SpaceChars}/PBS./i"
			"s/^(Thames.Television)${SpaceChars}/Thames.Television./i"

		)
	function CanoniseChannelNames {
		local CPatern
		Filename="${1}"
		for CPatern in "${ChannelNameCleanup[@]}" ; do
			Filename="$(echo "${Filename}" | sed   -re "${CPatern}")" 
		done
		
	}

		
	# SortToSubFolders '/mnt/DETH00/media/GenData/Downloads/Finished/Series/'
	function SortToSubFolders {
		[ $# -eq 1 ] || return 1
		local FileName CFile
		local -a _RETURN
		for CFile in "${1}"*; do 
			if [ -f "${CFile}" ]; then 
				if EpisodeName1 "${CFile}"; then
					local SrcEpisodeFileName="${_RETURN[1]}"
					local SrcFolder="${_RETURN[2]}"
					local EpisodeName="${_RETURN[3]}"
					local EpisodeNum="${_RETURN[5]:-}"
					local EpisodeYear="${_RETURN[4]:-}"
					local Foldername="${EpisodeName}"
					if ! FixupFileName1_sub "${SrcFolder}/${EpisodeName}" ; then
						FileName="${SrcFolder}/$(FixupFileName "${EpisodeName}")"
					fi
					[ -z "${EpisodeNum}" ] || FileName+="/Season ${EpisodeNum}"
					if [ ${TestFuncs} -ne 0 ] ; then
						sDebugOut "${FileName}" "${SrcEpisodeFileName}"
					else
						SimpleMkdir "${FileName}" 
						if [ -h "${CFile}" ]; then
							mv "${CFile}" "${FileName}/${SrcEpisodeFileName}"
						else
							MoveMain "${CFile}" "${FileName}"
						fi
					fi
				else
					nop
					#sErrorOut "${CFile}"
				fi
			fi 
		done
	}          
	function curlwrapper_2 {
		echo "${1}"  >&2
		CBuffer="$(curl  "${1}" 2>/dev/null ) " || return $?
  }
	function GetYearFromWikipedia {
    local ShowName="${2//[. $'\t']/_}"
		local CBuffer
      echo "${ShowName}"  >&2
		if [ "${ShowName%_US}" != "${ShowName}" ]; then
			if curlwrapper_2 "http://en.wikipedia.org/wiki/${ShowName%_US}_(North_American_TV_series)" "${TmpFile}"; then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release .*date/ || /Original .*run/ { Found=1; next} Found==1 {Found=0; print $5 }'  | sed -re 's/<.*//')"
			fi
		else
			if curlwrapper_2 "http://en.wikipedia.org/wiki/${ShowName}_(TV_series)"  ;then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release Date/ || /Original run/ { Found=1; next} Found==1 {Found=0; print $5 }'   | sed -re 's/<.*//')"
			fi
			if [ -z "${!1}" ] && curlwrapper_2 "http://en.wikipedia.org/wiki/${ShowName}_(film)" "${TmpFile}"; then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release .*date/ || /Original .*run/ { Found=1; next} Found==1 {Found=0; print $5 }'  | sed -re 's/<.*//')"
			fi
			if [ -z "${!1}" ] && curlwrapper_2 "http://en.wikipedia.org/wiki/${ShowName}_(North_American_TV_series)" "${TmpFile}"; then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release .*date/ || /Original .*run/ { Found=1; next} Found==1 {Found=0; print $5 }'  | sed -re 's/<.*//')"
			fi
			if [ -z "${!1}" ] && curlwrapper_2 "http://en.wikipedia.org/wiki/${ShowName}_(UK_TV_series)" "${TmpFile}"; then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release .*date/ || /Original .*run/ { Found=1; next} Found==1 {Found=0; print $5 }'  | sed -re 's/<.*//')"
			fi
			if [ -z "${!1}" ] && curlwrapper_2 "http://en.wikipedia.org/wiki/${ShowName}" ; then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release .*date/ || /Original .*run/ { Found=1; next} Found==1 {Found=0; print $5 }'  | sed -re 's/<.*//')"
			fi
			if [ -z "${!1}" ] && curlwrapper_2 "http://de.wikipedia.org/wiki/${ShowName}_(Film)" ;then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Erstausstrahlung/ || /Erscheinungsjahr/ { Found=1; next} Found==1 {Found=0; print $5 }'  | sed -re 's/<.*//')"
			fi
			if [ -z "${!1}" ] && curlwrapper_2 "http://de.wikipedia.org/wiki/${ShowName}" ;then
				set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Erstausstrahlung/ || /Erscheinungsjahr/ { Found=1; next} Found==1 {Found=0; print $5 }'   | sed -re 's/<.*//')"
			fi
		fi
		[ -n "${!1}" ]
  }
	function GetYearFromImdb {
    local ShowName="${2//[. $'\t']/+}"
		local CBuffer
    if curlwrapper_2 "http://www.imdb.com/find?q=${ShowName}&s=all" ; then
      set_variable "${1}" "$(echo "${CBuffer}" | awk   '/Release .*date/ || /Original .*run/ { Found=1; next} Found==1 {Found=0; print $4 }' | sed -re 's/<.*//')"
    fi
		[ -n "${!1}" ]
  }
  function CreateSortCfgEntry {
		[ $# -ge 1 ] || return 1
		local -a _RETURN
		local FileName CFile
		for CFile in "${@}"; do 
			 # sDebugOut "${CFile}"
			if EpisodeName1 "${CFile}"; then
				local SrcFileName="${_RETURN[1]}"
				local SrcFolder="${_RETURN[2]}"
				local EpisodeName="${_RETURN[3]}"
				local EpisodeYear="${_RETURN[4]:-}"
				local EpisodeNum="${_RETURN[5]:-}"
				local Foldername="${EpisodeName}"
        [ -n "${EpisodeYear}" ] || GetYearFromWikipedia EpisodeYear "${EpisodeName}"
        [ -n "${EpisodeYear}" ] || GetYearFromImdb			EpisodeYear "${EpisodeName}"
				[ -z "${EpisodeYear}" ] || Foldername+=".${EpisodeYear}"
				#sDebugOut "${_RETURN[@]}"
				if [ -n "${EpisodeNum}" ]; then
					if [ -z "${EpisodeYear}" -a "${EpisodeNum}" = "1" ]; then
						local FDate="$(stat -Lc "%y" "${CFile}" )"
						Foldername+=".${FDate:0:4}"
					fi
					printf  '[\\\\/]%s.+(S%02dE|%dx);/mnt/DETH00/media/Episodes/%s/Season %02d/\n' "${EpisodeName}" "${EpisodeNum}" "${EpisodeNum}" "${Foldername}" "${EpisodeNum}"
				elif [ -n "${EpisodeYear}" ]; then
					printf  '[\\\\/]%s.+%s;/mnt/DETH00/media/Episodes/%s/\n' "${EpisodeName}" "${EpisodeYear}" "${Foldername}"
				#else
				#	case "${EpisodeName}" in
				#		DC*)
				#			echo  "[\\/]${_RETURN[2]}.+(S${EpisodeNum}E|${_RETURN[4]x);/mnt/DETH00/media/Episodes/${Foldername}/Season ${EpisodeNum}/"
				#			;;
				#	esac
				fi
			fi
		done
	}          
	function AddToSortCfg {
		[ $# -ge 1 ] || return 1
		local TBuffer="$(CreateSortCfgEntry "${@}")"
			echo "${TBuffer}"
		TBuffer="$(PromptUserEdit "${TBuffer}" "Select SortCfg Entries" ""  || true )"
		if [ -n "${TBuffer}" ]; then
			#echo "${TBuffer}"
			echo "${TBuffer}" >>"/mnt/DETH00/media/New/SortCfg.csv"
		fi
	}          

	TestFuncs=0

	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_SortFuncs_Flags {
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

	SortFuncsRevision=$(CleanRevision '$Revision: 55 $')
	SortFuncsDescription=''
	push_element	ScriptsLoaded "SortFuncs.sh;${SortFuncsRevision};${SortFuncsDescription}"
	if [ "${SBaseName2}" = "SortFuncs.sh" ]; then 
		ScriptRevision="${SortFuncsRevision}"

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
		push_element ModulesArgHandlers SupportCallingFileFuncs Set_SortFuncs_Flags Set_SortFuncs_exec_Flags
		#push_element SupportedCLIOptions 
		function Set_SortFuncs_exec_Flags {
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
				#	--SortToSubFolders|--FindMatchDir|--CreateSortCfgEntry|--AddToSortCfg)
				#		${1:2} "${@:2}"
				#		exit
				#		;;
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
    declare -i ECnt=0
		declare -a TestEpisodeName1
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Andromeda 202 Exit Strategies.avi" \
																	2 "Andromeda 202 Exit Strategies.avi" "/Dir/Path" "Andromeda" "" "2" 
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/American.Dad.S05E04.Brains.Brains.and.Automobiles.PDTV.XviD-FQM.avi" \
																	1 "American.Dad.S05E04.Brains.Brains.and.Automobiles.PDTV.XviD-FQM.avi" "/Dir/Path" "American.Dad" "" "5" 
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/A-Team,.The.1x03.Children.Of.Jamestown.DVDRip-sInUs.[tvu.org.ru].avi" \
																	1 "A-Team,.The.1x03.Children.Of.Jamestown.DVDRip-sInUs.[tvu.org.ru].avi" "/Dir/Path" "A-Team,.The" "" "1"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Futurama - S04E12 - Where No Fan Has Gone Before [dd].avi" \
																	1 "Futurama - S04E12 - Where No Fan Has Gone Before [dd].avi" "/Dir/Path" "Futurama" "" "4"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Greys.Anatomy.S06E01E02.HDTV.XviD-NoTV.avi" \
																	1 "Greys.Anatomy.S06E01E02.HDTV.XviD-NoTV.avi" "/Dir/Path" "Greys.Anatomy" "" "6"

		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Hawaii.Five-0.2010.S01E23.HDTV.XviD-LOL.[VTV].avi" \
																	0 "Hawaii.Five-0.2010.S01E23.HDTV.XviD-LOL.[VTV].avi" "/Dir/Path" "Hawaii.Five-0" "2010" "1"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/BBC.Billy.Connelly.World.Tour.of.Australia.2of8.Canberra.XviD.AC3.MVGroup.org.avi" \
																	6 "BBC.Billy.Connelly.World.Tour.of.Australia.2of8.Canberra.XviD.AC3.MVGroup.org.avi" "/Dir/Path" "BBC.Billy.Connelly.World.Tour.of.Australia" "" ""

		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/National.Geographic.Ancient.Megastructures.Collection.2of8.St.Pauls.Cathedral.PDTV.XviD.MP3.MVGroup.org.avi" \
																	6 "National.Geographic.Ancient.Megastructures.Collection.2of8.St.Pauls.Cathedral.PDTV.XviD.MP3.MVGroup.org.avi" "/Dir/Path" "National.Geographic.Ancient.Megastructures.Collection" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/National.Geographic.Mystery.Files.Season.2.01of13.The.Birth.of.Christ.PDTV.XviD.MP3.MVGroup.org.avi" \
																	4 "National.Geographic.Mystery.Files.Season.2.01of13.The.Birth.of.Christ.PDTV.XviD.MP3.MVGroup.org.avi" "/Dir/Path" "National.Geographic.Mystery.Files" "" "2"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/National.Geographic.Ultimate.Car.Factories.Series2.1of3.Chevrolet.Camaro.PDTV.XviD.AC3.MVGroup.org.avi" \
																	4 "National.Geographic.Ultimate.Car.Factories.Series2.1of3.Chevrolet.Camaro.PDTV.XviD.AC3.MVGroup.org.avi" "/Dir/Path" "National.Geographic.Ultimate.Car.Factories" "" "2"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/History.Ch.Mega.Disasters.Collection.One.03of12.Asteroid.Apocalypse.XviD.AC3.MVGroup.org.avi" \
																	3 "History.Ch.Mega.Disasters.Collection.One.03of12.Asteroid.Apocalypse.XviD.AC3.MVGroup.org.avi" "/Dir/Path" "History.Ch.Mega.Disasters" "" "1"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/History.Ch.The.Universe.Season.Five.5of8.Secrets.of.the.Space.Probes.XviD.AC3.MVGroup.org.avi" \
																	3 "History.Ch.The.Universe.Season.Five.5of8.Secrets.of.the.Space.Probes.XviD.AC3.MVGroup.org.avi" "/Dir/Path" "History.Ch.The.Universe" "" "5"

		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Evidence of Revision, Episode 1: The Assassinations of Kennedy and Oswald.avi" \
																	7 "Evidence of Revision, Episode 1: The Assassinations of Kennedy and Oswald.avi" "/Dir/Path" "Evidence of Revision" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Leonardo_Da_Vinci_1_of_18_.avi" \
																	6 "Leonardo_Da_Vinci_1_of_18_.avi" "/Dir/Path" "Leonardo_Da_Vinci" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Leonardo_Da_Vinci__Part_1_of_18_.avi" \
																	5 "Leonardo_Da_Vinci__Part_1_of_18_.avi" "/Dir/Path" "Leonardo_Da_Vinci" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Nova - scienceNOW Episode 01 [digitaldistractions].avi" \
																	7 "Nova - scienceNOW Episode 01 [digitaldistractions].avi" "/Dir/Path" "Nova - scienceNOW" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/PBS.The.Fabric.of.the.Cosmos.1of4.What.is.Space.x264.AC3.MVGroup.org.avi" \
																	6 "PBS.The.Fabric.of.the.Cosmos.1of4.What.is.Space.x264.AC3.MVGroup.org.avi" "/Dir/Path" "PBS.The.Fabric.of.the.Cosmos" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Spacecraft Films - The Mighty Saturns - Part I - The Early Saturns (2002).avi" \
																	7 "Spacecraft Films - The Mighty Saturns - Part I - The Early Saturns (2002).avi" "/Dir/Path" "Spacecraft Films - The Mighty Saturns" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/DC.The.Deep.02of10.In.the.Company.of.Whales.Part1.XviD.AC3.MVGroup.org.avi" \
																	6 "DC.The.Deep.02of10.In.the.Company.of.Whales.Part1.XviD.AC3.MVGroup.org.avi" "/Dir/Path" "DC.The.Deep" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/DNA (1 of 5) - Secret of Life.avi" \
																	6 "DNA (1 of 5) - Secret of Life.avi" "/Dir/Path" "DNA" "" ""

		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/National.Geographic.Built For The Kill - s1e01 - Desert [zr].avi" \
																	1 "National.Geographic.Built For The Kill - s1e01 - Desert [zr].avi" "/Dir/Path" "National.Geographic.Built For The Kill" "" "1"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/National.Geographic.Ancient.Megastructures.Collection.Ep9.Chartres.Cathedral.PDTV.XviD.MP3.MVGroup.org.avi" \
																	7 "National.Geographic.Ancient.Megastructures.Collection.Ep9.Chartres.Cathedral.PDTV.XviD.MP3.MVGroup.org.avi" "/Dir/Path" "National.Geographic.Ancient.Megastructures.Collection" "" ""
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Hustle.8x01.HDTV_XviD-FoV.[VTV].avi" \
																	1 "Hustle.8x01.HDTV_XviD-FoV.[VTV].avi" "/Dir/Path" "Hustle" "" "8"
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/Stephen_Hawking's_-_Part_1_-_Seeing_is_believing.avi" \
																	7 "Stephen_Hawking's_-_Part_1_-_Seeing_is_believing.avi" "/Dir/Path" "Stephen_Hawking's" "" ""
                                   
		AddTestCase TestEpisodeName1 0 1 "/Dir/Path/The.Gruffalos.Child.2011.HDTV.XviD-BARGE.avi" \
																	8 "The.Gruffalos.Child.2011.HDTV.XviD-BARGE.avi" "/Dir/Path" "The.Gruffalos.Child" "2011" ""

		#AddTestCase TestEpisodeName1 1 1 "/Dir/Path/KwabenaBoahen_2007G_480.avi" \
		#															"" "KwabenaBoahen_2007G_480.avi" "/Dir/Path" "" "" ""
		#test_FuncType_RETURN EpisodeName1 "${TestEpisodeName1[@]}"   || ECnt+=${?}



		declare -a TestGetYearFrom
		AddTestCase TestGetYearFrom 0 2 _RETURN "The.Gruffalos.Child" 2011  
    AddTestCase TestGetYearFrom 0 2 _RETURN "Alcatraz" 2012  
    AddTestCase TestGetYearFrom 0 2 _RETURN "Stargate" 1994  
    AddTestCase TestGetYearFrom 0 2 _RETURN "Being.Human.US" 2011  
    AddTestCase TestGetYearFrom 0 2 _RETURN "David.Letterman" 2011  
    AddTestCase TestGetYearFrom 0 2 _RETURN "Saturday.Night.Live" 1975  

		test_FuncType_RETURN GetYearFromWikipedia  "${TestGetYearFrom[@]}"   || ECnt+=${?}

		#test_FuncType_RETURN GetYearFromImdb  "${TestGetYearFrom[@]}"   || ECnt+=${?}
												
	
    if [[ ${ECnt} -gt 0 ]]; then
      sError_Exit 5 "${ECnt} $(gettext "Tests failed")"
    else
      sDebugOut "$(gettext "All tests passed")"
      sNormalExit 0
    fi


		sNormalExit 0
	fi
fi

