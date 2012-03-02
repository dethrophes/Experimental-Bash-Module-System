:g/$\(\w\+\)/s//${\1}/
:g/${\(Revision\|Rev\|HeadURL\|Author\|Date\|Id\)}:/s//$\1:/
:g/awk\s\+\'{\s*print\s*${\(\d\)}\s*}/s//awk \'{ print $\1 }/
