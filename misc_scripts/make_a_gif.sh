#! /bin/bash

if [ $# != 5 ]; then
	echo "Usage: make_a_gif.sh infile outfile start duration dimensions"
	exit
fi

ffmpeg -ss $3 -i $1 -t $4 -s $5 -f gif $2 && \
gifsicle -O3 < $2 > $2
