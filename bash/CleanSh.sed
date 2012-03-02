/awk/! { 
s/\$(\w+)/\${$1}/
s/\${\(Revision\|Rev\|HeadURL\|Author\|Date\|Id\)}:/\$$1:/
}
