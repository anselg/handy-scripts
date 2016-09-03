#! /bin/bash

if ! [ -f ${HOME}/.clang-format ]; then 
   clang-format -style=mozilla -dump-config > .clang-format
fi

find . -type f \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) -exec sed -i "s/\/\/\t*\(.*\)$/\/\/\1/g" {} +
find . -type f \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) -exec sed -i "s/\t/  /g" {} +
find . -type f \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) -exec clang-format -i {} +
