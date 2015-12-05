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
	sed -i "s/\`\`/\"/g" "$FILENAME"

	# convert \textbf{`` ... "} to <code>...</code>
	sed -i "s:\\texttt{\"\([^}]*\)\"}:<b>\1</b>:g" "$FILENAME"
	sed -i "s:\\textbf{\"\([^}]*\)\"}:<b>\1</b>:g" "$FILENAME"

	# convert \texttt{ ... } to <code>...</code>
	sed -i "s:\\texttt{\([^}]*\)}:<code>\1</code>:g" "$FILENAME"
 
   # remove \ref{ ... }\\
 	sed -i "s/\\ref{[^}]*}//g" "$FILENAME"
#	sed -i "s#\\ref{\([^}]*\)}##" "$FILENAME"

	# remove \marginlabel{ ... }
	sed -i "s/\\marginlabel{[^}]*}//g" "$FILENAME"
#  sed -i "s#\\marginlabel{\([^}]*\)}##" "$FILENAME"
 
   # remove \index{ ... }
 	sed -i "s/\\index{[^}]*}//g" "$FILENAME"
#  sed -i "s#\\index{\([^}]*\)}##" "$FILENAME"
 
   # remove \seealso{ ... }
 	sed -i "s/\\seealso{[^}]*}//g" "$FILENAME"
#  sed -i "s#\\seealso{\([^}]*\)}##" "$FILENAME"
 
   # remove \begin{ ... }
 	sed -i "s/\\begin{[^}]*}//g" "$FILENAME"
#  sed -i "s#\\begin{\([^}]*\)}##" "$FILENAME"
 
   # remove \end{ ... }
 	sed -i "s/\\end{[^}]*}//g" "$FILENAME"
#  sed -i "s#\\end{\([^}]*\)}##" "$FILENAME"

else
	echo "give me a file"
	exit 1
fi
