#! /bin/bash
set -e

# get clang-format version
CLANG_FORMAT=""
if type -t "clang-format" > /dev/null; then 
  CLANG_FORMAT="clang-format"
elif type -t "clang-format-3.8" > /dev/null; then
  CLANG_FORMAT="clang-format-3.8"
else 
  exit 1
fi

# generate global clang config file
if ! [ -f ${HOME}/.clang-format ]; then 
  ${CLANG_FORMAT} -style=mozilla -dump-config > ${HOME}/.clang-format
fi


find . -type f \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) \
       -exec sed -i "s/\/\/\t*\(.*\)$/\/\/\1/g" {} +
find . -type f \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) \
       -exec sed -i "s/\t/  /g" {} +
find . -type f \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) \
       -exec ${CLANG_FORMAT} -i {} +
