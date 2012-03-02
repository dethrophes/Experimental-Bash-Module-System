ffmpeg -i $1 -vcodec copy -acodec copy output.mkv ${1%.*}.mkv
