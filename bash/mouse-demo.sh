#!/bin/bash
# Mon Jan  5 10:59:00 EST 2004
# NAME: mouse-demo
# Copyright 2004, Chris F.A. Johnson
# Released under the terms of the GNU General Public License

about() #== Information about mouse-demo
{
    cat <<EOF
          ${B}mouse-demo${U}
 
              A bash script that can be controlled entirely with the
              mouse.
 
          Requires: bash 2.0x or greater, ANSI/xterm window
 
          Author: Chris F.A. Johnson
 
          Date: 5 January 2004
 
          Copyright 2004 Chris F.A. Johnson
          This program may be copied under the terms of the
          GNU General Public License, Version 2.
EOF
}

clear_body()
{
    printat $(( $bar_line + 2 )) 1 "${NA}${cles}"
}

help()
{
    local n=0
    clear_body
    while [ $n -lt ${#button_cmd[@]} ]
    do
      printat $(( $n + $bar_line + 2 )) 1
      printf "%15.15s %-10.10s - %s"  ${button_keys[$n]} "(${button_cmd[$n]})" "${help_strings[$n]}"
      n=$(( n + 1 ))
    done
}

now()
{
    local n=3
    local DATE YEAR MONTH DAY TIME HOUR MINUTE SECOND
    eval `date "+DATE=\"%c\" YEAR=%Y MONTH=%B DOW=%A DAY=%d TIME=%H:%M:%S HOUR=%H MINUTE=%M SECOND=%S"`
    printat $((n += 1)) 20 "       DATE: $DATE"
    printat $((n += 2)) 20 "       YEAR: $YEAR"
    printat $((n += 1)) 20 "      MONTH: $MONTH"
    printat $((n += 1)) 20 "        DAY: $DAY"
    printat $((n += 1)) 20 "Day of week: $DOW"
    printat $((n += 1)) 20 "       HOUR: $HOUR"
    printat $((n += 1)) 20 "     MINUTE: $MINUTE"
    printat $((n += 1)) 20 "     SECOND: $SECOND"
}

d2c () #== convert a decimal number to the corresponding ASCII character
{
    x=`printf "%x" $1`
    printf "%b" "\x$x"
}

set_chars() #== load string of all 255 chars from file (create if necessary)
{
    charfile=$HOME/.chars
    if ! [ -s $charfile ]
    then
      for c in `seq 1 255`; do
	[ $c -eq 127 ] && c=9  ## 0x7f causes problems
	d2c $c
      done > $charfile
    fi
    chars=$(< $charfile)
}

cls() #== clear screen
{
    printf "${CLS:=`clear`}"
}

printat() #== print arguments 3-... at Y=$1 X=$2
{
    [ $# -lt 2 ] && return 1
    local y=$1
    local x=$2
    shift 2
    local msg="$*"
    printf "${CSI}%d;%dH%b" ${y//[!0-9]} ${x//[!0-9]} "$msg"
}

index() #== index return position of STR2 in STR1
{
    local idx
    case $1 in
        *$2*)
            idx=${1%%"${2}"*};
            _INDEX=$(( ${#idx} + 1 ))
	    ;;
        *)
            _INDEX=0
	    ;;
    esac
}

mouse_info() #== print mouse press information
{
    local frmt="%16s %3d"
    clear_body
    xx=$(( $COLUMNS / 3 ))
    yy=3 ##$(( $LINES - 25 ))
    printat $((yy++)) $xx
    printf "$frmt" Button: $mouse_b
    printat $((yy++)) $xx
    printf "$frmt" Column: $mouse_x
    printat $((yy++)) $xx
    printf "$frmt" Row: $mouse_y
    printat $((yy++)) $xx
    printf "$frmt" "Mouse modifier:" $mouse_m
    printat $((yy++)) $xx "$cle"
    printf "Var. Length: B=%d X=%d Y=%d " ${#_MOUSE1} ${#_MOUSE2} ${#_MOUSE3}
    printat $((yy++)) $xx "$cle"
    printf "MOUSE1=%s MOUSE2=%s MOUSE3=%s " `ascii "$_MOUSE1$_MOUSE2$_MOUSE3"`
}

mouse_pos() #== convert character to mouse position
{
    local MOUSE=$1
    if [ "$MOUSE" = $'\x7f' ]
    then
      _MOUSE_POS=95
    elif [ "$MOUSE" = "\\" ]
    then
      _MOUSE_POS=60
    else
      index "$mouse_val_str" "$MOUSE"
      _MOUSE_POS=$_INDEX
    fi
}

read_mouse() #== decode mouse press information
{
    IFS= read -r -d '' -sn1 -t1 _MOUSE1 || break 2
    IFS= read -r -d '' -sn1 -t1 _MOUSE2 || break 2
    IFS= read -r -d '' -sn1 -t1 _MOUSE3 || break 2
    index "$mouse_val_str" "$_MOUSE1"
    mouse_b=$(( ($_INDEX & 3) + 1 ))
    mouse_m=$(( $_INDEX & (4 | 8 | 16) ))
    mouse_pos "$_MOUSE2"
    mouse_x=$_MOUSE_POS
    mouse_pos "$_MOUSE3"
    mouse_y=$_MOUSE_POS
}

get_key() #== store keypress from list of permissible characters
{
    local OKchars=${1:-"$allkeys"}
    local k
    local error=0
    local gk_tmo=${getkey_time:-${DFLT_TIME_OUT:-600}}
    local ESC_END=[a-zA-NP-Z~^$]
    mouse_x=0 mouse_y=0 mouse_b=0 mouse_line=0
    printf "$mouse_on"
    stty -echo
    while :; do
      IFS= read -r -d '' -sn1 -t$gk_tmo _GET_KEY </dev/tty 2>&1 || break
      index "$OKchars" "$_GET_KEY"
      if [ "$_INDEX" -gt 0 ]
      then
	case $_GET_KEY in
	    ${ESC})
		while :; do
		  IFS= read -rst1 -d '' -n1 k </dev/tty || break 2
		  _GET_KEY=$_GET_KEY$k
 		  case $k in
		      $ESC_END)
			  [ "$_GET_KEY" = "$MSI" ] && { read_mouse; }
			  break 2
			  ;;
		  esac
		done
		;;
	     *) break;;
	esac
      fi
    done
    printf "$mouse_off"
    return $error
}

button_widths() #== initialize width of buttons
{
    [ $verbose -gt 0 ] && {
	yy=6
	printat  $(( yy++ )) 1  " Configuring button widths:"
	printat  $(( yy++ )) 1  "     COLUMNS=$COLUMNS"
    }
    bnum=${#buttons[@]}
    bwidth=${buttons_width:=$(( $COLUMNS - 1 ))}
    button_width=$(( ($bwidth - $bnum) / $bnum ))
    button_junk=$(( $buttons_width - ( ($button_width + 1 ) * $bnum) + 1))
    local n=0
    while [ $n -lt $bnum ]; do
	pad=${spaces:0:$(( ($button_width - ${#buttons[$n]}) / 2 ))}
	[ ${#pad} -lt 0 ] && { printf ":$pad:\n"; break; }
	buttons[$n]=${pad}${buttons[$n]}${pad}
	[ ${#buttons[$n]} -lt $button_width ] && buttons[$n]="${buttons[$n]} "
	n=$(( $n + 1 ))
    done
    bk_list=${button_keys[@]}
    bk_list=${bk_list// /}
    [ $verbose -gt 0 ] && {
	printat  $(( yy++ )) 1  "     button_width=$button_width"
	printat  $(( yy++ )) 1  "     button_junk=$button_junk"
	printat  $(( yy++ )) 1  "     bk_list=$bk_list"
	printat  $(( yy += 2 )) 1  "     PRESS ANY KEY"
	read -sn1
    }
}

button_bar() #== print buttons
{
    button_width2=$(( $button_width + 1 ))
    cmd=99
    printat $bar_line ${buttons_left:-1} "$bar_attr$NA"
    printf "$bar_attr%${button_width}.${button_width}b$NA " "${buttons[@]}"
    printf "$cle"
}

highlight_button()
{
    local num=${1:-$cmd}
    good_button || return
    printat $bar_line $(( ($num % ${#buttons[@]}) * $button_width2 + $buttons_left ))
    printf "${highbar_attr}%${button_width}.${button_width}s${NA}" "${buttons[$num]}"
}

button_pressed() #== check whether press was in the button area
{
    [ ${mouse_x:-0} -ge ${buttons_left} ] &&
    [ ${mouse_y:-0} -eq $bar_line ] &&
    [ ${mouse_x:-0} -le $(( $buttons_left + $buttons_width )) ]
}

do_button()
{
    local cmd=${1:-$cmd}
    highlight_button $cmd
    printat $body_line 1 "${NA}${cles}"
    printat $body_line 1
    good_button || return
    case ${button_cmd[$cmd]} in
	exit) confirm_exit && exit ;;
	*) body_lines=$(( ${LINES:=24} - 4 ))
	    ${button_cmd[$cmd]} | head -${body_lines#-}
    esac
    _DO_BUTTON=$cmd
}

good_button()
{
    local num=${1:-$cmd}
    [ $num -ge 0 ] && [ $num -lt ${#buttons[@]} ]
}

next_button()
{
    local num=${1:-$_DO_BUTTON}
    cmd=$(( (${num:-0} + 1) % ${#buttons[@]} ))
}

prev_button()
{
    local num=${1:-$_DO_BUTTON}
    cmd=$(( (${num:-0} + ${#buttons[@]} - 1) % ${#buttons[@]} ))
#    [ $cmd -lt  ] && cmd=1
}

confirm_exit()
{
    local _LAST_KEY=$_GET_KEY
    _DO_BUTTON=${cmd}
    clear_body
    printat $(( $bar_line + 2 )) 10 "${B}Exit [y/N]?${NA}${CVIS}\a "
    get_key "$alphanumeric" #"yYnNqQ$ESC$LF$RT$TAB"
    case $_GET_KEY in
	y|Y|q|Q) return 0 ;;
	$LF) prev_button ;;
	$RT) next_button ;;
    esac
    clear_body;printf "$CINV"
    _GET_KEY=$_LAST_KEY
    false
}

action()
{
    button_bar
    if button_pressed
    then
      cmd=$(( ($mouse_x - $buttons_left) / $button_width2 ))
    else
      case "$_GET_KEY" in
	  $NL) printf "\a" ;;
	  $MSI ) mouse_info; cmd=-1 ;;
	  $TAB|$RT ) next_button ;;
	  $LF) prev_button ;;
	  [$bk_list]) index $bk_list $_GET_KEY
	     [ $_INDEX -gt 0 ] && [ $_INDEX -le ${#buttons[@]} ] && {
		 cmd=$(( $_INDEX - 1 ))
	     }
	     ;;
	  e|q|x) confirm_exit && exit ;;
      esac
    fi
    highlight_button ##$cmd
    [ $cmd -lt 0 -a $cmd -ge ${#buttons[@]} ] && return
    [ "${button_cmd[$cmd]:-c}" = exit ] && confirm_exit && exit || do_button
}

cleanup() #== restore terminal
{
    trap 0
    button_bar
    stty $stty_orig
#    stty sane
    printf "%s${NL}${NL}${NL}${NL}" "$CVIS"
#    tput reset
    exit
}

trap "COLUMNS=`tput cols`;LINES=`tput lines`; cls;button_widths; button_bar" SIGWINCH

[ $verbose -gt 0 ] && printat 10 10 COLUMNS=$COLUMNS
verbose=0
COLUMNS=${COLUMNS:-`tput cols`}
LINE=${LINES:-`tput lines`}

case $1 in
    -v) verbose=1;;
esac

bra='['
ket=']'
ESC=$'\e'
NL=$'\n'
TAB=$'\t'
CSI=${ESC}${bra}
cle=${CSI}K
cles=${CSI}J
CVIS="${CSI}?25h"
CINV="${CSI}0;8m"
MSI=${CSI}M
NA=${CSI}0m
B=${CSI}1m
U=${CSI}0m
UP=${CSI}A
DN=${CSI}B
RT=${CSI}C
LF=${CSI}D
mouse_type[0]=${CSI}?9h     ## report mouse button press
mouse_type[1]=${CSI}?1000h  ## report mouse button press and release
mouse_on=${mouse_type[0]}
mouse_off=${CSI}?9l${CSI}?1000l
upper=ABCDEFGHIJKLMNOPQRSTUVWXYZ
lower=abcdefghijklmnopqrstuvwxyz
numeric=0123456789
alphanumeric=$upper$lower$numeric
spaces='                                                                   '
spaces=$spaces$spaces$spaces
CVIS=${CSI}?25h
CINV=${CSI}?25l
allkeys=$chars

trap "cleanup" 0
set_chars
mouse_val_str=${chars:32}
mouse_on=${mouse_type[0]}
cls

## commands to be placed in buttons
button_cmd=( cal df uptime who ps "ls -l" now help about exit )

## labels for button (customize if different from commands
buttons=( "${button_cmd[@]}" )

## keys for each button
button_keys=( c d u w p l n h a q )

## info to show with help command
help_strings=(
    "Display amount of free and used memory in the system"
    "Report filesystem disk space usage"
    "Tell how long the system has been running"
    "Show who is logged on"
    "Report process status"
    "Long listing of as many files as will fit on screen"
    "Display date and time information"
    "Help!"
    "About this script"
    "Exit"
)

bar_attr="${CSI}1;41;37m"
highbar_attr="${CSI}1;37;40m"

bar_line=1
body_line=$(( $bar_line + 2 ))
buttons_left=1
printf "$CINV"
button_widths
button_bar

stty_orig=`stty -g`
while :; do
  get_key "xe$bk_list$ESC$TAB$LF$RT"
  case $_GET_KEY in
#      $LF) printat 10 10 KEY=left;;
#      $RT) printat 10 10 KEY=right;;
#      q|exit) break ;;
      \?) help;;
  esac
  action
done
cleanup
