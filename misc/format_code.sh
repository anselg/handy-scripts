#! /bin/bash
set -e

################################################################################
# Use clang-format to format all C/C++ code in the directory this script is run. 
# You need to install clang-format (preferably v3.8).
################################################################################

# get clang-format version
CLANG_FORMAT=""
if type -t "clang-format" > /dev/null; then 
  CLANG_FORMAT="clang-format"
elif type -t "clang-format-3.8" > /dev/null; then
  CLANG_FORMAT="clang-format-3.8"
else 
  exit 1
fi

# set clang-format style (llvm, chromium, google, webkit, or mozilla)
STYLE="mozilla"

# generate global clang config file if it doesn't already exist
if ! [ -f ${HOME}/.clang-format ]; then 
  ${CLANG_FORMAT} -style=${STYLE} -dump-config > ${HOME}/.clang-format
fi

# remove tabs in comments
find . -type f \
  \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) \
  -exec sed -i "s/\/\/\t*\(.*\)$/\/\/\1/g" {} +

# replace tabs with two spaces
find . -type f \
  \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) \
  -exec sed -i "s/\t/  /g" {} +

# clang-format
find . -type f \
  \( -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' \) \
  -exec ${CLANG_FORMAT} -style=${STYLE} -i {} +
