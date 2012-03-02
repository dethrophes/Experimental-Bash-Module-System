#!/bin/bash -x
# mount
version="0.1.0.1"

#################################################
#       TRADUCTIONS
        ###### Default = English #####
        title="ISO Mounter "$version""
        noselec=""$title" converts audio files. "$pleasesel""
        warning="warning"
        proceed="already exists. overwrite?"
        recur=""$title" can't convert a directory. "$pleasesel""
        conversion="converting file:"
	confirmation="do you want to convert"
	decoding="decoding file:"
	not_supported="format not supported"
	completed="conversion completed. goodbye!"
	aborted="conversion aborted. goodbye!"
	options="choose from the followin' options:"

	action_for_duplicates_message="Action for duplicates"
	overwite_all_existig_option="Overwrite All existing file"
	skip_all_existig_option="Skip All existing files"
	skip_option="Skip"
	replace_option="Replace"

case $LANG in
        ######## FranÃ§ais ########
        fr* )
		noselec=""$title" permet de convertir des fichiers audio. "$pleasesel""
		warning="Attention"
		proceed="existe deja. Ecraser ?"
		recur=""$title" ne permet pas la conversion de dossiers. "$pleasesel""
		conversion="Conversion du fichier :"
		confirmation="voulez-vous convertir"
		decoding="decodage du fichier:"
		;;
	######## italiano #########
	it* )
		noselec=""$title" converte i file audio. "$pleasesel""
		warning="attenzione"
		proceed="esiste! sovrascrivo?"
		recur=""$title" non può convertire directory. "$pleasesel""
		conversion="sto convertendo il file:"
		confirmation="vuoi convertire"
		decoding="sto decodificando il file:"
		not_supported="formato non supportato"
		completed="conversione completata. arrivederci!"
		options="scegli fra le seguenti opzioni:"
		;;
	###### Brazilian Portuguese ######
	pt-br* )
		noselec=""$title" converter arquivos de audio. "$pleasesel""
		warning="atenção"
		proceed="já existe! sobrescrever?"
		recur=""$title" não e possível converter pasta. "$pleasesel""
		conversion="convertendo arquivo:"
		confirmation="você quer converter"
		decoding="decodificando arquivo:"
		;;
	######## dutch ########
	nl* )
               noselec=""$title" converteer audio bestanden. "$pleasesel""
               warning="waarschuwing"
               proceed="bestaat al. overschrijven?"
               recur=""$title" kan geen directory converteren. "$pleasesel""
               conversion="converteren van bestand:"
		confirmation="wil je converteren"
		decoding="decoderen bestand:"
               not_supported="Formaat niet ondersteund"
               completed="Conversie compleet."
		;;
	######## german ########
	de* )
		noselec=""$title" verarbeitet Dateien. "$pleasesel"" 
		warning="Warnung" 
		proceed="existiert bereits. Überschreiben?" 
		recur=""$title" kann kein Verzeichnis konvertieren. "$pleasesel"" 
		conversion="Encodiere Datei:" 
		confirmation="Wollen Sie jetzt konvertieren?" 
		decoding="Dekodiere Datei:" 
		not_supported="Format wird nicht unterstützt" 
		completed="Konvertierung abgeschlossen." 
		options="Bitte wählen Sie eine der folgende Optionen:" 
		action_for_duplicates_message="Aktion für Duplikate"
		skip_all_existig_option="Skip Alle vorhandenen Dateien"
		skip_option="Skip"
		replace_option="Ersetzen"
		;;
	######## Spanish(Español - Castellano) ########
	es* )
               noselec=""$title" - Convierte archivos de audio."$pleasesel""
               warning="Atención"
               proceed="Ya existe, sobreescribir?"
               recur=""$title" No se puede convertir el directorio. "$pleasesel""
               conversion="Convirtiendo archivo:"
               confirmation="Convertir?"
               decoding="Decodificando archivo:"
		completed="conversión completo. Adiós!"
		not_supported="Format no es  soportado"
		;;
	######## polish ########
	pl* )
		noselec="konwersja pliku "$title". "$pleasesel""
		warning="ostrzeÅ¼enie"
		proceed="juÅ¼ istnieje. zastÄ~EpiÄ~G ?"
		recur=""$title" nie moÅ¼na konwertowaÄ~G katalogÃ³w. "$pleasesel""
		conversion="konwersja pliku:"
		confirmation="chcesz uÅ¼yÄ~G konwersji"
		decoding="dekodowany plik:"
		completed="konwersjÄ~Y zakoÅ~Dczono. Pa, pa!"
		;;
esac



if [ -z "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
	if [ -z "$1" ]; then
		exit 2
	else
		ISONAME=$1
	fi
else
	ISONAME=$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
	exec 1>/tmp/iso_mount.log 2>&1
fi
ISONAME=$(echo $ISONAME | sed s/\s*$// )


is_mounted_iso()
{
	mount  | grep "$1" | grep 'iso9660' >/dev/null
}

is_iso()
{
	file -b "$1" | grep 'ISO 9660 CD-ROM filesystem' >/dev/null
}

test_supported_input_file()
{
	(is_iso "$1") 
}


if !(test_supported_input_file "$1") && ! [ -d "$1" ]
then
	zenity --error --title="$warning" --text="$not_supported"
        exit 1
fi

gksudo -k /bin/echo "got r00t?"
if [ $? -gt 0 ]; then
		exit 3
fi

BASENAME=`basename "$ISONAME" .iso`
MOUNTPOINT="/media/$BASENAME"

sudo mkdir "$MOUNTPOINT"

zenity --info --title "$title" --text "$BASENAME e $ISONAME"


if sudo mount -o loop -t iso9660 "$ISONAME" "$MOUNTPOINT"
then
	if zenity --question --title "$title" --text "$BASENAME Successfully Mounted. Open Volume?"
	then
		nautilus "$MOUNTPOINT" --no-desktop
	fi
	exit 0
else
	sudo rmdir "$MOUNTPOINT"

	zenity --error --title "$title" --text "Cannot mount $BASENAME!"


	exit 1
fi
