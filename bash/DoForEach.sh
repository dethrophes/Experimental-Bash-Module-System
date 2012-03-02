#!/bin/bash +x
find -L "$1" | grep -P $2 | while read line ; do eval $3 \""\$line"\" $4 ; done
