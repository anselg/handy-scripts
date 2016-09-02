#! /bin/bash

LICENSE="LICENSE"
for dir in *; do 
	if [ -d "$dir" ]; then
		DIFF=$(diff $LICENSE "$dir"/LICENSE)
		if [ "$DIFF" != "" ]; then
			echo "$dir"
			echo "$DIFF"
			echo ""
		fi
	fi
done
