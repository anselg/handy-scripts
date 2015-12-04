#! /bin/bash

FILENAME="$1"

if [[ -n "$FILENAME" ]]; then
	echo "$1"
else 
	echo "input file error"
	exit 1
fi

if [ -f "$FILENAME" ]; then
	# convert `` to "
	sed -i "s/``/\"/g" "$FILENAME"

	# convert \textbf{`` ... "} to <code>...</code>
	sed -i "s/\\textbf{\"/<code>/g" "$FILENAME"
	sed -i "s/\"}/<\/code>/g" "$FILENAME"

	# convert \texttt{ ... } to <code>...</code>

	# remove \marginlabel{ ... }

	# remove \index{ ... }

	# remove \seealso{ ... }

	# remove \ref{ ... }\\

else
	echo "give me a file"
	exit 1
fi
