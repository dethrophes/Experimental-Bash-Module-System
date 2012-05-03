#!/bin/bash +x
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
#I Description: Auto Created for audio-convert.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : audio-convert.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
#
#
# audio convert 0.3.1
#
# a program to convert wav, ogg, mp3, mpc, flac, ape, aac or wma files into 
# wav, ogg, mp3, mpc, flac, ape or aac files. with an easy to use interface
# it's actually possible to fill in the tags for a few formats, pass them on
# from format to format, and choose the quality of compression.
#
# copyright (C) 2005 linfasoft
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  
# USA
#
# dependencies
#	bash
#       zenity
#	awk
#	file >= 4.16
#       mplayer -- if you want to decode wma files
#       lame
#       vorbis tools
#       id3tag
#       musepack-tools
#	flac
#	mac
#	faac,faad
#
# based on
#	wom_audioconverter, by yekcim <yeknan@yahoo.fr>, http://yeknan.free.fr.
#

version="0.4.0.1"
#################################################
#       TRADUCTIONS
        ###### Default = English #####
        title="audio convert "$version""
        pleasesel="please select at least one file."
        noselec=""$title" converts audio files. "$pleasesel""
        choix="extension of output file:"
        warning="warning"
        proceed="already exists. overwrite?"
        recur=""$title" can't convert a directory. "$pleasesel""
        conversion="converting file:"
        ask_artist="enter the artist name:"
        ask_album="enter the album name:"
        ask_song="enter the song name:"
        ask_track="enter the track number:"
        ask_year="enter the track year:"
        ask_genre="enter the track genre:"
        ask_comment="enter the track comment:"
        ask_quality="select the desired quality:"
	ask_compression="select the desired compression level:"
	confirmation="do you want to convert"
	decoding="decoding file:"
	ask_fields="manually enter file metatags"
	ask_confirmation_question="get prompted for confirmation question before converting each file"
	no_codec="you don't have the right codec to decode the selected file. missin' codec:"
	not_supported="format not supported"
	completed="conversion completed. goodbye!"
	aborted="conversion aborted. goodbye!"
	ask_to_pass="pass the metatags on to the new files"
	options="choose from the followin' options:"
	options_conflict="options one and two conflict. please unselect one of them"

	ask_to_recursive_question="Recursive"
	ask_progress_popups_question="Progress popups for each encoding & decoding processes"
	action_for_duplicates_message="Action for duplicates"
	overwite_all_existig_option="Overwrite All existing file"
	skip_all_existig_option="Skip All existing files"
	ask_in_each_case_option="Ask in each case"
	skip_option="Skip"
	replace_option="Replace"

case $LANG in
        ######## Fran√ßais ########
        fr* )
		title="audio convert "$version""
		pleasesel="Merci de selectionner au moins un fichier."
		noselec=""$title" permet de convertir des fichiers audio. "$pleasesel""
		choix="Format du fichier de sortie :"
		warning="Attention"
		proceed="existe deja. Ecraser ?"
		recur=""$title" ne permet pas la conversion de dossiers. "$pleasesel""
		conversion="Conversion du fichier :"
		ask_artist="Nom de l'artiste:"
		ask_album="Nom de l'album:"
		ask_song="Nom de la chanson:"
		ask_track="Numero de la piste:"
		ask_quality="Choisir la qualite voulue:"
		confirmation="voulez-vous convertir"
		decoding="decodage du fichier:"
		ask_fields="voulez-vous completer les metatags du fichier?"
		ask_confirmation_question="voulez-vous confirmer avant de convertir chaque
		fichier?";;
	######## italiano #########
	it* )
		title="audio convert "$version""
		pleasesel="per favore, scegli almeno un file."
		noselec=""$title" converte i file audio. "$pleasesel""
		choix="formato di conversione:"
		warning="attenzione"
		proceed="esiste! sovrascrivo?"
		recur=""$title" non puÚ convertire directory. "$pleasesel""
		conversion="sto convertendo il file:"
		ask_artist="immetti il nome dell'artista:"
		ask_album="immetti il nome dell'album:"
		ask_song="immetti il nome della canzone:"
		ask_track="immetti il numero della traccia:"
		ask_quality="scegli la qualit‡ del file:"
		ask_compression="scegli il livello di compressione:"
		confirmation="vuoi convertire"
		decoding="sto decodificando il file:"
		ask_fields="completare manualmente le metatags"
		ask_confirmation_question="chiedi una conferma per ogni file da convertire"
		no_codec="non hai il codec corretto per decodificare il file selezionato. codec mancante:"
		not_supported="formato non supportato"
		completed="conversione completata. arrivederci!"
		ask_to_pass="copiare le metatags nel nuovo file"
		options="scegli fra le seguenti opzioni:"
		options_conflict="le opzioni uno e due sono in conflitto. per favore deselezionane una";;
	###### Brazilian Portuguese ######
	pt-br* )
		title="audio convert "$version""
		pleasesel="por favor, selecione pelo menos um arquivo."
		noselec=""$title" converter arquivos de audio. "$pleasesel""
		choix="extens„o do arquivo de saÌda:"
		warning="atenÁ„o"
		proceed="j· existe! sobrescrever?"
		recur=""$title" n„o e possÌvel converter pasta. "$pleasesel""
		conversion="convertendo arquivo:"
		ask_artist="digite o nome do artista:"
		ask_album="digite o nome do album:"
		ask_song="digite o nome da m˙sica:"
		ask_track="digite o n˙mero da faixa:"
		ask_quality="selecione a qualidade desejada:"
		confirmation="vocÍ quer converter"
		decoding="decodificando arquivo:";;
	######## dutch ########
	nl* )
               title="audio convert "$version""
               pleasesel="selecteer minimaal 1 bestand."
               noselec=""$title" converteer audio bestanden. "$pleasesel""
               choix="extensie van uitvoerbestanden:"
               warning="waarschuwing"
               proceed="bestaat al. overschrijven?"
               recur=""$title" kan geen directory converteren. "$pleasesel""
               conversion="converteren van bestand:"
               ask_artist="voer naam van artiest in:"
               ask_album="voer naam van album in:"
               ask_song="voer naam van nummer in:"
               ask_track="voer volgnummer in:"
               ask_quality="selecteer de gewenste kwaliteit:"
		confirmation="wil je converteren"
		decoding="decoderen bestand:"
		ask_fields="Wil je metatags aan de bestanden toevoegen?"
               ask_confirmation_question="Wil je bevestiging voor het converteren van elk bestand?"
               no_codec="Je hebt niet de juiste codec voor het converteren van dit bestand. Missende codec:"
               not_supported="Formaat niet ondersteund"
               completed="Conversie compleet."
               ask_to_pass="Wil je de metatags toevoegen aan de nieuwe bestanden?";;
	######## german ########
	de* )
		title="Audio Konvertier Skript "$version"" 
		pleasesel="Bitte w‰hlen Sie mindestens eine Datei." 
		noselec=""$title" verarbeitet Dateien. "$pleasesel"" 
		choix="Konvertiere in folgendes Format:" 
		warning="Warnung" 
		proceed="existiert bereits. ‹berschreiben?" 
		recur=""$title" kann kein Verzeichnis konvertieren. "$pleasesel"" 
		conversion="Encodiere Datei:" 
		ask_artist="K¸nstlername:" 
		ask_album="Albumname:" 
		ask_song="Songname:" 
		ask_track="Titelnummer:" 
		ask_quality="W‰hlen Sie die gew¸nschte Qualit‰t:" 
		ask_compression="geben Sie die gew¸nschte Komprimierungsst‰rke an:" 
		confirmation="Wollen Sie jetzt konvertieren?" 
		decoding="Dekodiere Datei:" 
		ask_fields="Metatags von Hand eintragen" 
		ask_confirmation_question="F¸r jede Datei nachfragen" 
		no_codec="Notweniger Codec zur dekodierung der Datei nicht gefunden." 
		not_supported="Format wird nicht unterst¸tzt" 
		completed="Konvertierung abgeschlossen." 
		ask_to_pass="Uebertrage Metatags in konvertierte Dateien" 
		options="Bitte w‰hlen Sie eine der folgende Optionen:" 
		options_conflict="Bitte w‰hlen sie nur eine der Optionen"
		ask_to_recursive_question="Rekursive"
		ask_progress_popups_question="Popups f¸r die Codierung und Decodierung Prozesse"
		action_for_duplicates_message="Aktion f¸r Duplikate"
		skip_all_existig_option="Skip Alle vorhandenen Dateien"
		skip_option="Skip"
		replace_option="Ersetzen";;
	######## Spanish(EspaÒol - Castellano) ########
	es* )
               title="audio convert "$version""
               pleasesel="Seleccione al menos un archivo."
               noselec=""$title" - Convierte archivos de audio."$pleasesel""
               choix="Formato del archivo resultante:"
               warning="AtenciÛn"
               proceed="Ya existe, sobreescribir?"
               recur=""$title" No se puede convertir el directorio. "$pleasesel""
               conversion="Convirtiendo archivo:"
               ask_artist="Nombre del artista:"
               ask_album="Nombre del ·lbum:"
               ask_song="Nombre de la canciÛn:"
               ask_track="N˙mero de la pista:"
               ask_quality="Seleccione la calidad deseada:"
               confirmation="Convertir?"
               decoding="Decodificando archivo:"
               ask_fields="Editar las \"metatags\" del archivo?"
		ask_confirmation_question="Desea una pregunta de confirmaciÛn antes de convertir cada archivo?"
		ask_compression="seleccione el nivel de compresiÛn deseable:"
		completed="conversiÛn completo. AdiÛs!"
		no_codec="No tenrs el codec correcto para descodificar el elijido archivo. Falta:"
		not_supported="Format no es  soportado";;
	######## polish ########
	pl* )
		title="konwersja audio "$version""
		pleasesel="wybierz co najmniej jeden plik."
		noselec="konwersja pliku "$title". "$pleasesel""
		choix="rozszerzenie pliku wynikowego:"
		warning="ostrze≈ºenie"
		proceed="ju≈º istnieje. zastƒ~Epiƒ~G ?"
		recur=""$title" nie mo≈ºna konwertowaƒ~G katalog√≥w. "$pleasesel""
		conversion="konwersja pliku:"
		ask_artist="podaj nazwƒ~Y wykonawcy:"
		ask_album="podaj nazwƒ~Y albumu:"
		ask_song="podaj nazwƒ~Y utworu:"
		ask_track="podaj numer ≈~[cie≈ºki:"
		ask_quality="wybierz wymagany poziom jako≈~[ci:"
		ask_compression="wybierz wymagany poziom kompresji:"
		confirmation="chcesz u≈ºyƒ~G konwersji"
		decoding="dekodowany plik:"
		ask_fields="chcesz umie≈~[ciƒ~G tagi ?"
		ask_confirmation_question="chcesz u≈ºywaƒ~G potwierdzenia przed ka≈ºdƒ~E konwersjƒ~E ?"
		no_codec="nie posiadasz odpowiedniego kodeka dla wykonania wymaganej operacji. missin' codec:"
		ask_to_pass="chcesz eksportowaƒ~G metatagi do innych plik√≥w?"
		completed="konwersjƒ~Y zako≈~Dczono. Pa, pa!"
		ask_to_pass="chcesz eksportowaƒ~G metatagi do innych plik√≥w?"
esac

ReplaceFiles=0
UseAccPlus=1
ReducePopups=0
Logfile="audio-convert.log"

#################################################
#       FONCTIONS
handle_abort()
{
	if [ $1 -gt 0 ] ; then
		ABBOT_RECIEVED=1
		if [ "$2" ] ; then
			rm "$2"
			zenity --info --title "$title" --text="$aborted \"$2\""
		else
			zenity --info --title "$title" --text="$aborted"
		fi
		exit
	fi
}
get_field_names ()
{
        artist_name=`zenity --entry --title="$title" --text="$ask_artist" --entry-text="$artist_name"`
        album_name=`zenity --entry --title="$title" --text="$ask_album" --entry-text="$album_name"`
        song_name=`zenity --entry --title="$title" --text="$ask_song" --entry-text="$album_name"`
        track_number=`zenity --entry --title="$title" --text="$ask_track" --entry-text="$album_name"`
        track_year=`zenity --entry --title="$title" --text="$ask_year" --entry-text="$album_year"`
        track_genre=`zenity --entry --title="$title" --text="$ask_genre" --entry-text="$album_genre"`
        #track_comment=`zenity --entry --title="$title" --text="$ask_comment" --entry-text="$album_comment"`
}

get_ogg_quality ()
{
        zenity --title="$title" --width=200 --height=450 --list --radiolist --column="" --column="$ask_quality" -- "-1" FALSE "0" FALSE "1" FALSE "2" FALSE "3" FALSE "4" FALSE "5" FALSE "6" TRUE "7" FALSE "8" FALSE "9" FALSE "10"
	handle_abort $?
}

get_mp3_quality ()
{
        zenity --title="$title" --width=200 --height=200 --list --radiolist --column="" --column="$ask_quality" FALSE "medium" FALSE "standard" TRUE "extreme" FALSE "insane"
	handle_abort $?
}

get_mpc_quality ()
{
        zenity --title="$title" --width=200 --height=200 --list --radiolist --column="" --column="$ask_quality" FALSE "thumb" FALSE "radio" TRUE "standard" FALSE "xtreme"
	handle_abort $?
}

get_flac_quality ()
{
	zenity --title="$title" --width=200 --height=350 --list --radiolist --column="" --column="$ask_compression" FALSE "0" FALSE "1" FALSE "2" FALSE "3" FALSE "4" FALSE "5" FALSE "6" FALSE "7" TRUE "8"
	handle_abort $?
}

get_mac_quality ()
{
	zenity --title="$title" --width=200 --height=250 --list --radiolist --column="" --column="$ask_compression" FALSE "1000" FALSE "2000" TRUE "3000" FALSE "4000" FALSE "5000"
	handle_abort $?
}

get_faac_quality ()
{
	zenity --title="$title" --width=200 --height=380 --list --radiolist --column="" --column="$ask_compression" FALSE "10"  FALSE "25"  FALSE "50"  TRUE "100" FALSE "200" FALSE "300" FALSE "400" FALSE "500"
	handle_abort $?
}
get_naac_quality ()
{
	zenity --title="$title" --width=200 --height=250 --list --radiolist --column="" --column="$ask_compression" TRUE "32" FALSE "44" FALSE "48" FALSE "64"
	handle_abort $?
}
get_Naac_quality ()
{
	zenity --title="$title" --width=200 --height=250 --list --radiolist --column="" --column="$ask_compression" TRUE "0.1" FALSE "0.2" FALSE "0.3" FALSE "0.4" FALSE "0.5" FALSE "0.6" FALSE "0.7" FALSE "0.8" FALSE "0.9" FALSE "1"
	handle_abort $?
}
get_aac_quality ()
{
	if [ $UseAccPlus -gt 0 ]
	then 
		get_naac_quality
	#elif [ $faac_cmd -gt 0 ]
	#then
	#	get_Naac_quality
	else
		get_faac_quality
	fi
}

get_quality ()
{
	if [ "$1" == "mp3" ]
	then
		quality="$(get_mp3_quality)"
	elif [ "$1" == "ogg" ]
	then
		quality="$(get_ogg_quality)"
	elif [ "$1" == "mpc" ]
	then
		quality="$(get_mpc_quality)"
	elif [ "$1" == "flac" ]
	then
		quality="$(get_flac_quality)"
	elif [ "$1" == "ape" ]
	then
		quality="$(get_mac_quality)"
	elif [ "$1" == "aac" ]
	then
		quality="$(get_aac_quality)"
	else
		quality=
	fi
}

test_fields_set()
{
	!( [ "$artist_name" ] || [ "$album_name" ] || [ "$song_name" ] || [ "$track_number" ] || [ "$track_year" ]  || [ "$track_genre" ] )
}

get_metatags ()
{
	info_file=$(mktemp)
	if (is_mp3 "$1")
	then
		id3info "$1" > "$info_file"
		artist_name=`cat "$info_file" | awk '/TPE1/ { print substr($0, match($0, /:/) + 2 ) }'`
		album_name=`cat "$info_file" | awk '/TALB/ { print substr($0, match($0, /:/) + 2 ) }'`
		song_name=`cat "$info_file" | awk '/TIT2/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_number=`cat "$info_file" | awk '/TRCK/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_year=`cat "$info_file" | awk '/TYER/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_genre=`cat "$info_file" | awk '/TCON/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_comment=`cat "$info_file" | awk '/COMM/ { print substr($0, match($0, /:/) + 2 ) }'`
	elif (is_ogg "$1")
	then
		ogginfo "$1" > "$info_file"
		artist_name=`cat "$info_file" | grep artist | cut -d \= -f 2`
		album_name=`cat "$info_file" | grep album | cut -d \= -f 2`
		song_name=`cat "$info_file" | grep title | cut -d \= -f 2`
		track_number=`cat "$info_file" | grep tracknumber | cut -d \= -f 2`
		track_year=`cat "$info_file" | grep trackyear | cut -d \= -f 2`
		track_genre=`cat "$info_file" | grep trackgenre | cut -d \= -f 2`
		#track_comment=`cat "$info_file" | grep comment | cut -d \= -f 2`
	elif (is_flac "$1")
	then
		artist_name=`metaflac --show-tag=artist "$1" | cut -d \= -f 2`
		album_name=`metaflac --show-tag=album "$1" | cut -d \= -f 2`
		song_name=`metaflac --show-tag=title "$1" | cut -d \= -f 2`
		track_number=`metaflac --show-tag=tracknumber "$1" | cut -d \= -f 2`
		track_year=`metaflac --show-tag=date "$1" | cut -d \= -f 2`
		track_genre=`metaflac --show-tag=genre "$1" | cut -d \= -f 2`
		#track_comment=`metaflac --show-tag=comment "$1" | cut -d \= -f 2`
	elif (is_aac "$1") || (is_m4a "$1")
	then
		faad -i  "$1" > "$info_file" 2>&1 
		artist_name=`cat "$info_file" | awk '/artist/ { print substr($0, match($0, /:/) + 2 ) }'`
		album_name=`cat "$info_file" | awk '/album/ { print substr($0, match($0, /:/) + 2 ) }'`
		song_name=`cat "$info_file" | awk '/title/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_number=`cat "$info_file" | awk '/track/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_year=`cat "$info_file" | awk '/year/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_genre=`cat "$info_file" | awk '/genre/ { print substr($0, match($0, /:/) + 2 ) }'`
		track_comment=`cat "$info_file" | awk '/comment/ { print substr($0, match($0, /:/) + 2 ) }'`
		if test_fields_set
		then
			nokiatagger  "$1" > "$info_file" 2>&1 
			artist_name=`cat "$info_file" | awk '/Author/ { print substr($0, match($0, /:/) + 3 ) }'`
			album_name=`cat "$info_file" | awk '/Album/ { print substr($0, match($0, /:/) + 3 ) }'`
			song_name=`cat "$info_file" | awk '/Title/ { print substr($0, match($0, /:/) + 3 ) }'`
			#track_number=`cat "$info_file" | awk '/track/ { print substr($0, match($0, /:/) + 3 ) }'`
			track_year=`cat "$info_file" | awk '/Year/ { print substr($0, match($0, /:/) + 3 ) }'`
			track_genre=`cat "$info_file" | awk '/Genre/ { print substr($0, match($0, /:/) + 3 ) }'`
			track_comment=`cat "$info_file" | awk '/Comment/ { print substr($0, match($0, /:/) + 3 ) }'`
		fi
	else
		artist_name=
		album_name=
		song_name=
		track_number=
		track_year=
		track_genre=
		track_comment=
	fi
	if [ -f $info_file ]
	then
		rm $info_file
	fi
}

mp3_parse_fields ()
{
	mp3_fields=()
        if [ "$artist_name" ]
        then
                mp3_fields=("${mp3_fields[@]}" -a"$artist_name")
        fi
        if [ "$album_name" ]
        then
                mp3_fields=("${mp3_fields[@]}" -A"$album_name")
        fi
        if [ "$song_name" ]
        then
                mp3_fields=("${mp3_fields[@]}" -s"$song_name")
        fi
        if [ "$track_number" ]
        then
                mp3_fields=("${mp3_fields[@]}" -t"$track_number")
        fi
        if [ "$track_year" ]
        then
                mp3_fields=("${mp3_fields[@]}" -y"$track_year")
        fi
        if [ "$track_genre" ]
        then
                mp3_fields=("${mp3_fields[@]}" -g"$track_genre")
        fi
        if [ "$track_comment" ]
        then
                mp3_fields=("${mp3_fields[@]}" -c"$track_comment")
        fi
        if [ "$track_desc" ]
        then
                mp3_fields=("${mp3_fields[@]}" -d"$track_desc")
        fi
        if [ "$track_totaltracks" ]
        then
                mp3_fields=("${mp3_fields[@]}" -t"$track_totaltracks")
        fi
}

ogg_parse_fields ()
{
	ogg_fields=()
	if [ "$artist_name" ]
	then
		ogg_fields=("${ogg_fields[@]}" -a "$artist_name")
	fi
	if [ "$album_name" ]
	then
		ogg_fields=("${ogg_fields[@]}" -l "$album_name")
	fi
	if [ "$song_name" ]
	then
		ogg_fields=("${ogg_fields[@]}" -t "$song_name")
	fi
	if [ "$track_number" ]
	then
		ogg_fields=("${ogg_fields[@]}" -N "$track_number")
	fi
	if [ "$track_year" ]
	then
		ogg_fields=("${ogg_fields[@]}" -d "$track_year")
	fi
	if [ "$track_genre" ]
	then
		ogg_fields=("${ogg_fields[@]}" -G "$track_genre")
	fi
	if [ "$track_comment" ]
	then
		ogg_fields=("${ogg_fields[@]}" -c "$track_comment")
	fi
}

flac_set_tags ()
{
	if [ $pass_metatags -eq 0 ] || [ $fields -eq 0 ]
        then
		if [ "$artist_name" ]
		then
			metaflac --set-tag=ARTIST="$artist_name" "$1"
		fi
		if [ "$album_name" ]
		then
			metaflac --set-tag=ALBUM="$album_name" "$1"
		fi
		if [ "$song_name" ]
		then
			metaflac --set-tag=TITLE="$song_name" "$1"
		fi
		if [ "$track_number" ]
		then
			metaflac --set-tag=TRACKNUMBER="$track_number" "$1"
		fi
		if [ "$track_year" ]
		then
			metaflac --set-tag=DATE="$track_year" "$1"
		fi
		if [ "$track_genre" ]
		then
			metaflac --set-tag=GENRE="$track_genre" "$1"
		fi
		if [ "$track_comment" ]
		then
			metaflac --set-tag=COMMENT="$track_comment" "$1"
		fi
        fi
}

naac_parse_fields ()
{
	count=0
	naac_fields=()
        if [ "$artist_name" ]
        then
		#naac_fields=("${naac_fields[@]}" -1 "$artist_name")
		naac_fields[$count]=-a
		((count++))
		naac_fields[$count]="$artist_name"
		((count++))
        fi
        if [ "$album_name" ]
        then
		naac_fields[$count]=-A
		((count++))
		naac_fields[$count]="$album_name"
		((count++))
        fi
        if [ "$song_name" ]
        then
		naac_fields[$count]=-t
		((count++))
		naac_fields[$count]="$song_name"
		((count++))
        fi
        #if [ "$track_number" ]
        #then
	#	naac_fields[$count]=-c
	#	((count++))
	#	naac_fields[$count]="$track_number"
	#	((count++))
        #fi
        if [ "$track_year" ]
        then
		naac_fields[$count]=-y
		((count++))
		naac_fields[$count]="$track_year"
		((count++))
        fi
        if [ "$track_genre" ]
        then
		naac_fields[$count]=-g
		((count++))
		naac_fields[$count]="$track_genre"
		((count++))
        fi
        if [ "$track_comment" ]
        then
		naac_fields[$count]=-c
		((count++))
		naac_fields[$count]="$track_comment"
		((count++))
        fi
}

aac_parse_fields ()
{
	aac_fields=()
        if [ "$artist_name" ]
        then
                aac_fields=("${aac_fields[@]}" --artist "$artist_name")
        fi
        if [ "$album_name" ]
        then
                aac_fields=("${aac_fields[@]}" --album "$album_name")
        fi
        if [ "$song_name" ]
        then
                aac_fields=("${aac_fields[@]}" --title "$song_name")
        fi
        if [ "$track_number" ]
        then
                aac_fields=("${aac_fields[@]}" --track "$track_number")
        fi
        if [ "$track_year" ]
        then
                aac_fields=("${aac_fields[@]}" --year  "$track_year")
        fi
        if [ "$track_genre" ]
        then
                aac_fields=("${aac_fields[@]}" --genre "$track_genre")
        fi
        if [ "$track_comment" ]
        then
                aac_fields=("${aac_fields[@]}" --comment "$track_comment")
        fi
}

is_mp3 ()
{
	file -b "$1" | grep 'MP3' >/dev/null || echo $1 | grep -i '\.mp3$' >/dev/null
}

is_ogg()
{
	file -b "$1" | grep 'Vorbis' >/dev/null || echo $1 | grep -i '\.ogg$' >/dev/null
}

is_mpc()
{
	file -b "$1" | grep 'Musepack' >/dev/null || echo $1 | grep -i '\.mpc$' >/dev/null
}

is_flac()
{
	file -b "$1" | grep 'FLAC' >/dev/null || echo $1 | grep -i '\.flac$' >/dev/null
}

is_mac()
{
	file -b "$1" | grep 'data' >/dev/null && echo $1 | grep -i '\.ape$' >/dev/null
}

is_aac()
{
	file -b "$1" | grep 'AAC' >/dev/null || echo $1 | grep -i '\.aac$' >/dev/null
}

is_wav()
{
	file -b "$1" | grep 'WAVE' >/dev/null || echo $1 | grep -i '\.wav$' >/dev/null
}

is_m4a()
{
	file -b "$1" | grep 'MPEG v4 system' >/dev/null || echo $1 | grep -i '\.(m4a|m4b|mp4)$' >/dev/null
}

is_wma()
{
	file -b "$1" | grep 'Microsoft' >/dev/null || echo $1 | grep -i '\.wma$' >/dev/null
}

is_vqf()
{
	file -b "$1" | grep 'VQF' >/dev/null || echo $1 | grep -i '\.vqf$' >/dev/null
}

test_supported_input_file()
{
	((is_mp3 "$1") || (is_ogg "$1") || (is_mpc "$1") || (is_flac "$1") || (is_mac "$1") || \
		(is_aac "$1") || (is_wav "$1") || (is_wma "$1") || (is_vqf "$1") || (is_m4a "$1"))
}
SetupRedirect ()
{
	if [ $ReducePopups -gt 0 ]
	then
		Redirect=
	else
		Redirect="$1"
	fi

}

mp3_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>3){gsub(/[()%|]/," ");print $2; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'

	echo lame -m auto --preset $quality "\"$2"\" "\"$3"\"
	eval lame -m auto --preset $quality "\"$2"\" "\"$3"\"  $Redirect
	handle_abort $? "$3"
}

ogg_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $2; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'

	if [ $fields -eq 0 ] || [ $pass_metatags -eq 0 ]
	then
		ogg_parse_fields
		echo oggenc "\"$2"\" "\"\${ogg_fields[@]}"\" -q $quality -o "\"$3"\"
		eval oggenc "\"$2"\" "\"\${ogg_fields[@]}"\" -q $quality -o "\"$3"\" $Redirect
	else
		echo oggenc "\"$2"\" -q $quality -o "\"$3"\"
		eval oggenc "\"$2"\" -q $quality -o "\"$3"\" $Redirect
	fi
	handle_abort $? "$3"
}

mpc_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''!/^$/{if (NR>5) print $1; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'
	
	echo mppenc --$quality "\"$2"\" "\"$3"\"
	eval mppenc --$quality "\"$2"\" "\"$3"\"  $Redirect
	handle_abort $? "$3"
}

flac_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' -F'\'':'\'' '\''!/wrote/{gsub(/ /,"");if(NR>1)print $2; fflush();}'\'' | awk -F'\''%'\'' '\''{print $1; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'
	
	echo flac --compression-level-$quality "\"$2\"" -o "\"$3\""
	eval flac --compression-level-$quality "\"$2\"" -o "\"$3\"" $Redirect
	handle_abort $? "$3"
}

mac_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $2; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'
	
	echo mac "\"$2"\" "\"$3"\" -c$quality
	eval mac "\"$2"\" "\"$3"\" -c$quality  $Redirect
	handle_abort $? "$3"
}

faac_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $3; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'
	
	if [ $fields -eq 0 ] || [ $pass_metatags -eq 0 ]
        then
		aac_parse_fields
		echo faac -w "\"\${aac_fields[@]}"\" -q $quality -o "\"$3"\" "\"$2"\"
		eval faac -w "\"\${aac_fields[@]}"\" -q $quality -o "\"$3"\" "\"$2"\"   $Redirect
	else
		echo faac -q $quality -o "\"$3"\" "\"$2"\
		eval faac -q $quality -o "\"$3"\" "\"$2"\"  $Redirect
	fi
	handle_abort $? "$3"
}
Naac_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $3; fflush();}'\'' | zenity --progress --title="$title" --text="$conversion $1" --auto-close'
	
	echo neroAacEnc -q 1 -of "\"$3"\" -if "\"$2"\"
	eval neroAacEnc -q 1 -of "\"$3"\" -if "\"$2"\"  $Redirect

	if [ $fields -eq 0 ] || [ $pass_metatags -eq 0 ]
        then
		aac_parse_fields
	fi

	handle_abort $? "$3"
}

naac_encode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>2){gsub(/[%[]/," ");print $1; fflush();}'\''| zenity --progress --title="$title" --text="$conversion $1" --auto-close'
	
	echo aacplusenc "\"$2"\" "\"$3"\" $quality
	eval aacplusenc "\"$2"\" "\"$3"\" $quality   $Redirect
	if [ $? -gt 0 ] ; then
		if [ $faac_cmd -gt 0 ] ; then
			Naac_encode "$1" "$2" "$3"
		else
			local quality=
			faac_encode "$1" "$2" "$3"
		fi
	else
		if [ $fields -eq 0 ] || [ $pass_metatags -eq 0 ] ; then
			naac_parse_fields
			nokiatagger "${naac_fields[@]}" "$3" 
		fi
	fi
}
aac_encode()
{
	if [ $UseAccPlus -gt  0 ] ; then
		naac_encode "$1" "$2" "$3"
	elif [ $faac_cmd -gt 0 ] ; then
		Naac_encode "$1" "$2" "$3"
	else
		if [ "$faac_quality" ] ; then 
		  faac_quality="$(get_faac_quality)"
		fi
		local quality=$faac_quality
		faac_encode "$1" "$2" "$3"
	fi
}

mp3_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' -F'\''[ /]+'\'' '\''(NR>2){if((100*$2/$3)<=100)print 100*$2/$3; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo lame --decode \'"$1"\' \'"$temp_file"\'   
	eval lame --decode \'"$1"\' \'"$temp_file"\'   $Redirect
	handle_abort $? "$temp_file"
}

ogg_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $2; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo oggdec "\"$1"\" -o "\"$temp_file"\" 
	eval oggdec "\"$1"\" -o "\"$temp_file"\"   $Redirect
	handle_abort $? "$temp_file"
}

mpc_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' -F'\''[ (]+'\'' '\''!/s/{gsub(/(%)/," ");if(NR>5)print $5; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo mppdec "\"$1"\" "\"$temp_file"\"
	eval mppdec "\"$1"\" "\"$temp_file"\"   $Redirect
	handle_abort $? "$temp_file"
}

flac_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' -F'\'':'\'' '\''!/done/{gsub(/ /,"");gsub(/% complete/,"");if(NR>1)print $2; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo flac -d "\"$1"\" -o "\"$temp_file"\"
	eval flac -d "\"$1"\" -o "\"$temp_file"\"   $Redirect
	handle_abort $? "$temp_file"
}

mac_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $2; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo mac "\"$1"\" "\"$temp_file"\" -d 
	eval mac "\"$1"\" "\"$temp_file"\" -d   $Redirect
	handle_abort $? "$temp_file"
}

aac_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print $1; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo faad -o "\"$temp_file"\" "\"$1"\"   
	eval faad -o "\"$temp_file"\" "\"$1"\"   $Redirect
	handle_abort $? "$temp_file"
}

wma_decode ()
{
	SetupRedirect '2>&1 | awk -vRS='\''\r'\'' '\''(NR>1){gsub(/%/," ");print 100-$5; fflush();}'\'' | zenity --progress --title="$title" --text="$2 $1" --auto-close'
	
	temp_file=`mktemp | sed 's/$/'.wav'/'`
	echo mplayer -ao pcm:file="\"$temp_file"\" "\"$1"\" 
	eval mplayer -ao pcm:file="\"$temp_file"\" "\"$1"\"   $Redirect
	handle_abort $? "$temp_file"
}

ask_for_fields ()
{
	questions=("${questions[@]}" FALSE "$ask_fields")
}

ask_for_confirmation ()
{
	questions=("${questions[@]}" FALSE "$ask_confirmation_question")
}

ask_to_pass_metatags ()
{
	questions=(TRUE "$ask_to_pass")
}
ask_to_recursive ()
{
	questions=("${questions[@]}" TRUE "$ask_to_recursive_question")
}
ask_progress_popups ()
{
	questions=("${questions[@]}" FALSE "$ask_progress_popups_question")
}

question_list ()
{
	if [ "$formatout" == "mp3" ] || [ "$formatout" == "ogg" ] || [ "$formatout" == "flac" ] || \
		 [ "$formatout" == "aac" ]
	then
					#pass_metatags=1

		if (is_mp3 "$1") || (is_ogg "$1") || (is_flac "$1") || (is_aac "$1") || (is_m4a "$1") || [ -d "$1"  ]
		then
						ask_to_pass_metatags    # ask if user wants metatags to be passed on
		fi

		ask_for_fields  # ask if user wants to edit metatags
		ask_to_recursive
		ask_progress_popups
	fi
	if [ "$2" -gt 1 ] || [ -d "$1"  ]
	then
		ask_for_confirmation    # ask if user wants a confirmation question for each file
	#else
        #	confirmation_question=1
	fi
}

ask_questions ()
{
	repeat=1

	while [ $repeat -eq 1 ]
	do
		answers=`zenity --list  --width=500 --height=310 --checklist --column "" --column "$options" "${questions[@]}"`
		handle_abort $?
		
		if (echo "$answers" | grep -i "$ask_to_pass" >/dev/null 2>&1) && \
			 (echo "$answers" | grep -i "$ask_fields" >/dev/null 2>&1)
		then
			zenity --error --title="$warning" --text="$options_conflict"
			repeat=1
			continue
		fi

		repeat=0
	done
}
			
ask_overwrite_policy ()
{
	answers=`zenity --title="$title" --width=300 --height=250 --list --radiolist --column="" --column="$action_for_duplicates_message" TRUE "$overwite_all_existig_option" FALSE "$skip_all_existig_option" FALSE "$ask_in_each_case_option"`
	handle_abort $?
	if (echo "$answers" | grep -i "$overwite_all_existig_option") >/dev/null 2>&1
	then
		ReplaceFiles=2
	elif (echo "$answers" | grep -i "$skip_all_existig_option") >/dev/null 2>&1
	then
		ReplaceFiles=1
	elif (echo "$answers" | grep -i "$ask_in_each_case_option") >/dev/null 2>&1
	then
		ReplaceFiles=0
	else
		ReplaceFiles=0
	fi
}
parse_questions ()
{
	if (echo "$answers" | grep -i "$ask_to_pass") >/dev/null 2>&1
	then
		pass_metatags=0
	else
		pass_metatags=1
	fi

	if (echo "$answers" | grep -i "$ask_fields") >/dev/null 2>&1
	then
		fields=0
	else
		fields=1
	fi

	if (echo "$answers" | grep -i "$ask_confirmation_question") >/dev/null 2>&1
	then
		confirmation_question=0
	else
		confirmation_question=1
	fi

	if (echo "$answers" | grep -i "$ask_to_recursive_question") >/dev/null 2>&1
	then
		recurse_question=1
	else
		recurse_question=0
	fi
	if (echo "$answers" | grep -i "$ask_progress_popups_question") >/dev/null 2>&1
	then
		ReducePopups=0
	else
		ReducePopups=1
	fi
}


completed_message ()
{
	zenity --info --title "$title" --text="$completed"
}

caf () # fonction "convert audio file"
{
	# 
	# Decode File
	#
        if (is_mp3 "$1")
        then
		mp3_decode "$1" "$decoding"
        elif (is_ogg "$1")
        then
		ogg_decode "$1" "$decoding"
        elif (is_mpc "$1")
        then
		mpc_decode "$1" "$decoding"
	elif (is_flac "$1")
	then
		flac_decode "$1" "$decoding"
	elif (is_mac "$1")
	then
		mac_decode "$1" "$decoding"
	elif (is_aac "$1") || (is_m4a "$1")
        then
		aac_decode "$1" "$decoding"
        elif (is_wav "$1")
        then
		echo a
        elif (is_wma "$1") || (is_vqf "$1")
        then
		wma_decode "$1" "$decoding"
	else
		break
	fi

	if [ -f "$temp_file" ]
	then
		# 
		# Get Metadata
		#
		if [ $pass_metatags -eq 0 ]
		then
			get_metatags    "$1"
		fi
		if [ $fields -eq 0 ]
		then
			get_field_names "$1"
		fi


		# 
		# Encode File
		#
		if [ "$3" = "mp3" ]
		then
			mp3_encode "$1" "$temp_file" "$2"
			if test_fields_set
			then
				mp3_parse_fields
				id3tag "${mp3_fields[@]}" "$2"
			fi
		elif [ "$3" = "wav" ]
		then
			mv  "$temp_file" "$2"
			break
		elif [ "$3" = "ogg" ]
		then
			ogg_encode "$1" "$temp_file" "$2"
		elif [ "$3" = "mpc" ]
		then
			mpc_encode "$1" "$temp_file" "$2"
		elif [ "$3" = "flac" ]
		then
			flac_encode "$1" "$temp_file" "$2"
			flac_set_tags "$2"
		elif [ "$3" = "ape" ]
		then
			mac_encode "$1" "$temp_file" "$2"
		elif [ "$3" = "aac" ]
		then
			aac_encode "$1" "$temp_file" "$2"
		fi
		# 
		# Remove Tmp File
		#
		rm "$temp_file"
	fi
}
detect_supported_format()
{
	depformat=""
	if which lame  1>/dev/null 2>&1
	then
		if !(is_mp3 "$1")	# if we have lame, and the file to convert is not an mp3,
		then			# add mp3 to the list of formats to convert to
			depformat="mp3"
		fi
	else	# if we don't have lame, check if the file to convert is an mp3
		if (is_mp3 "$1")
		then
			zenity --error --title="$warning" --text="$no_codec lame"
			exit 1
		fi
	fi
	if which oggenc 1>/dev/null 2>&1
	then
		if !(is_ogg "$1")	# if we have vorbis-tools, and the file to convert is not an
		then			# ogg, add ogg to the list of formats to convert to
			depformat="$depformat ogg"
		fi
	else    # if we don't have vorbis-tools, check if the file to convert is an ogg
		if (is_ogg "$1")
		then
			zenity --error --title="$warning" --text="$no_codec vorbis-tools"
			exit 1
		fi
	fi
	if which mppenc 1>/dev/null 2>&1
	then
		if !(is_mpc "$1")	# if we have musepack-tools, and the file to convert is not
		then			# an mpc, add mpc to the list of formats to convert to
			depformat="$depformat mpc"
		fi
	fi
	if !(which mppdec 1>/dev/null) 2>&1
	then    # if we don't have musepack-tools, check if the file to convert is an mpc
		if (is_mpc "$1")
		then
			zenity --error --title="$warning" --text="$no_codec musepack-tools"
			exit 1
		fi
	fi
	if which flac 1>/dev/null 2>&1
	then
		if !(is_flac "$1")	# if we have flac, and the file to convert is not a
		then			# flac, add flac to the list of formats to convert to
			depformat="$depformat flac"
		fi
	else    # if we don't have flac, check if the file to convert is a flac
		if (is_flac "$1")
		then
			zenity --error --title="$warning" --text="$no_codec flac"
			exit 1
		fi
	fi
	if which mac 1>/dev/null 2>&1
	then
		if !(is_mac "$1")	# if we have mac, and the file to convert is not an ape,
		then			# add ape to the list of formats to convert to
			depformat="$depformat ape"
		fi
	else    # if we don't have mac, check if the file to convert is an ape
		if (is_mac "$1")
		then
			zenity --error --title="$warning" --text="$no_codec mac"
			exit 1
		fi
	fi
	if which neroAacEnc 1>/dev/null 2>&1
	then
		faac_cmd=1
		if !(is_aac "$1")	# if we have faac, and the file to convert to is not an aac,
		then			# add aac to the list of formats to convert to
			depformat="$depformat aac"
		fi
	elif which faac 1>/dev/null 2>&1
	then
		faac_cmd=0
		if !(is_aac "$1")	# if we have faac, and the file to convert to is not an aac,
		then			# add aac to the list of formats to convert to
			depformat="$depformat aac"
		fi
	fi
	if !(which faad 1>/dev/null 2>&1)	# if we don't have faad, check if the file to convert to is an aac
	then
		if (is_aac "$1") || (is_m4a "$1")
		then
			zenity --error --title="$warning" --text="$no_codec faad"
			exit 1
		fi
	fi
	if !(which mplayer 1>/dev/null 2>&1) # if we don't have mplayer, check if the file to convert is a wma
	then
		if (is_wma "$1") || (is_vqf "$1")
		then
			zenity --error --title="$warning" --text="$no_codec mplayer"
			exit 1
		fi
	fi
	if !(is_wav "$1")	# if the file to convert is not a wav, add wav to the list of
	then			# formats to convert to
		depformat="$depformat wav"
	fi
}
ask_destination_format()
{
	######## Fen√™tre principale ########
	while [ ! "$formatout" ] # R√©afficher la fen√™tre tant que l'utilisateur n'a pas fait de choix
	do
		formatout=`zenity --title "$title"  --width=200 --height=250  --list --column="Format" $depformat --text "$choix"`
		handle_abort $?
		###### Choix -> Sortie boucle ######
		if  [ $? != 0 ]; then
			exit 1
		fi
		[ $? -ne 0 ] && exit 2 # Annulation
	done
}
compile_file_list()
{
	local in_file
	if [ -z "$1" ]
	then
		in_file=$2
	else
		in_file=$1/$2
	fi
	shift

	if [ -d  "$in_file" ]
	then
		
		if [ $recurse_question -gt 0 ]
		then 
			pushd "$in_file" > /dev/null
			Files=(*)
			popd > /dev/null
			for file in "${Files[@]}"
			do
				compile_file_list "$in_file" "$file"
			done
		fi
		
	elif (test_supported_input_file "$in_file") 
	then
		file_array[$file_cnt]="$in_file"
		let TFileSize+=$(stat --printf="%s" "$in_file")
		((file_cnt++))
	#else
	#	echo Unsupported filetype $in_file
	fi
}

ConvertFileLst () # fonction "convert audio file"
{
	file_number=$#
	while [ $# -gt 0 ]; do
		in_file=$1
		out_file=`echo "$in_file" | sed 's/\.\w*$/'.$formatout'/'`
		eval out_file\="\"$FolderPreamble$(dirname "$out_file")/$FilePreamble$(basename "$out_file")\""
		mkdir -p "$(dirname "$out_file")"

		#echo "# $conversion $in_file"
		while `true`; do
			echo [$compteur/$file_number]\($progress.$progressmb$progresslb\%\) $in_file >&2
			########## Le fichier de sortie existe d√©j√| , l'√©craser ? ##########
			if [ $ReplaceFiles -ne 2 ] && [ -f "$out_file" ] ; then
				if [ $ReplaceFiles -eq 1 ] ; then
					break
				elif (`zenity --question --title="$warning" --text="$out_file $proceed" --ok-label="$skip_option" --cancel-label="$replace_option"`) ; then
					break
				fi
			fi
			if [ "$file_number" -gt 1 ] && [ "$confirmation_question" -eq 0 ] ; then
				zenity --question --text="$confirmation $in_file in $out_file?"
				if [ $? -eq 1 ]
				then
					break
				fi
			fi
			caf "$in_file" "$out_file" "$formatout" >>$Logfile 2>&1
			break
		done
		######### Progression ########
		eval let \"CFileSize += $(stat --printf="%s" "$in_file")\"
		let "compteur += 1"
		if [ 0 -gt 0 ] ; then
		    let "progresslb = compteur*10000/$file_number"
		else
		    let "progresslb = CFileSize*10000/$TFileSize"
		fi
		let "progress   = progresslb/100"
		let "progressmb = progresslb/10%10"
		let "progresslb = compteur%10"
		echo $progress.$progressmb$progresslb
		shift
	done
	
}


#################################################
#       PROGRAMME

echo \# > $Logfile
echo \# $title >> $Logfile
echo \# >> $Logfile

FolderPreamble=\$formatout/
FilePreamble=

#### Pas de fichiers s√©lectionn√© ###
if [ $# -eq 0 ]; then
        zenity --error --title="$warning" --text="$noselec"
        exit 1
fi
######## make a list of available formats, and check if we can decode the file #######
if !(test_supported_input_file "$1") && ! [ -d "$1" ]
then
	zenity --error --title="$warning" --text="$not_supported"
        exit 1
fi

detect_supported_format "$1"
ask_destination_format
########## Conversion ############
CFileSize=0;
compteur=0;
question_list "$1" "$#"	# prepare all of the various conversion questions
ask_questions		# ask all of the various conversion questions
parse_questions		# parse all of the various conversion questions
ask_overwrite_policy

get_quality "$formatout"	# ask for quality of compression
file_cnt=0

while [ $# -gt 0 ]; do
	compile_file_list "" "$1"
	shift
done


Redirect='| zenity --progress --title="$title" --text="Number of files to convert ${#file_array[@]}" --auto-close'
eval ConvertFileLst "\"\${file_array[@]}\"" $Redirect
handle_abort $?

completed_message
