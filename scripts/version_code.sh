#!/bin/bash
clear
ANSI_ART=$(cat <<EOF
\e[0;m          \e[48;5;160m            \e[0;m    \e[0;m
\e[0;m        \e[48;5;160m            \e[0;m      \e[0;m
\e[0;m      \e[48;5;160m            \e[0;m        \e[0;m
\e[0;m    \e[48;5;160m            \e[0;m  \e[48;5;160m  \e[0;m      \e[0;m
\e[0;m  \e[48;5;160m            \e[0;m  \e[48;5;160m      \e[0;m    \e[0;m
\e[48;5;160m            \e[0;m  \e[48;5;160m          \e[0;m  \e[0;m
\e[48;5;160m          \e[0;m    \e[48;5;160m            \e[0;m
\e[48;5;160m            \e[0;m    \e[48;5;160m          \e[0;m
\e[0;m  \e[48;5;160m          \e[0;m  \e[48;5;160m            \e[0;m
\e[0;m    \e[48;5;160m      \e[0;m  \e[48;5;160m            \e[0;m  \e[0;m
\e[0;m      \e[48;5;160m  \e[0;m  \e[48;5;160m            \e[0;m    \e[0;m
\e[0;m        \e[48;5;160m            \e[0;m      \e[0;m
\e[0;m      \e[48;5;160m            \e[0;m        \e[0;m
\e[0;m    \e[48;5;160m            \e[0;m          \e[0;m
EOF
)

printf "$ANSI_ART\n"

# Read version information from a text file (version.txt).
# Example: "12399" represents v1.2.3 build 99
version_file="version.txt"
version=$(cat "$version_file")

# Increment version information and update file (version.txt).
version=$((version + 1))
echo "$version" > "$version_file"

# Extract Major, Minor, Patch, and Build from the version number
if [[ ${#version} -eq 5 ]]; then
    major=$(echo "$version" | cut -c1)           # 1 digit Major version
    minor=$(echo "$version" | cut -c2)           # Minor version
    patch=$(echo "$version" | cut -c3)           # Patch version
    build=$(echo "$version" | cut -c4-5)         # Build number
elif [[ ${#version} -eq 6 ]]; then
    major=$(echo "$version" | cut -c1-2)         # 2 digit Major version
    minor=$(echo "$version" | cut -c3)           # Minor version
    patch=$(echo "$version" | cut -c4)           # Patch version
    build=$(echo "$version" | cut -c5-6)         # Build number
else
    echo "Invalid version format in version.txt"
    exit 1
fi

# Convert major version to a letter (1 = A, 2 = B, ..., 26 = Z, 27 = AA, etc.)
function convert_major_to_letter() {
    local num=$1
    local letter=""
    while [ $num -gt 0 ]; do
        remainder=$(( (num - 1) % 26 ))
        letter=$(printf "\x$(printf %x $((65 + remainder)))")$letter
        num=$(( (num - 1) / 26 ))
    done
    echo "$letter"
}

major_letter=$(convert_major_to_letter "$major")

# Convert patch version (0 = A, 1 = B, ..., 9 = J)
declare -a patches=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J")
patch_letter=${patches[$patch]}

# Get the current date
year=$(date "+%Y" | tail -c 3)  # Last two digits of the year
# Numeric month
month=$((10#$(date "+%m")))     # Outputs 1, 2, ... 12 (no leading zeros)
day=$((10#$(date "+%d")))  # Outputs 1, 2, ... 31 (no leading zeros)

# Map month to letters (A = Jan, B = Feb, ..., L = Dec)
declare -a months=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L")
month_letter=${months[$((month-1))]}  # Adjust for 0-based index

# Map day to alphanumeric (0-V, 1 = 0, 2 = 1, ..., 31 = U)
declare -a days=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U")
day_letter=${days[$((day-1))]}  # Adjust for 0-based index

# Generate the versioning code
version_code="${major_letter}${minor}${patch_letter}${build}-${year}${month_letter}${day_letter}"

# Output the generated version code to terminal.
echo "Version Number: $major.$minor.$patch"
echo "Version Code: $version_code"
echo "Numeric Build Number: $version"
echo "Internal Build Code: ${major_letter}${minor}${patch_letter}${build}"

# Output the generated version code to file.
echo "// The MIT License (MIT)" > version_code.h
echo "// " >> version_code.h
echo "// Copyright (c) 2023 Insoft. All rights reserved." >> version_code.h
echo "// " >> version_code.h
echo "// Permission is hereby granted, free of charge, to any person obtaining a copy" >> version_code.h
echo "// of this software and associated documentation files (the "Software"), to deal" >> version_code.h
echo "// in the Software without restriction, including without limitation the rights" >> version_code.h
echo "// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell" >> version_code.h
echo "// copies of the Software, and to permit persons to whom the Software is" >> version_code.h
echo "// furnished to do so, subject to the following conditions:" >> version_code.h
echo "// " >> version_code.h
echo "// The above copyright notice and this permission notice shall be included in all" >> version_code.h
echo "// copies or substantial portions of the Software." >> version_code.h
echo "// " >> version_code.h
echo "// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR" >> version_code.h
echo "// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY," >> version_code.h
echo "// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE" >> version_code.h
echo "// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER" >> version_code.h
echo "// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," >> version_code.h
echo "// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE" >> version_code.h
echo "// SOFTWARE." >> version_code.h
echo "" >> version_code.h

echo "#define VERSION_NUMBER        \"$major.$minor.$patch\"" >> version_code.h
echo "#define VERSION_CODE          \"$version_code\"" >> version_code.h
echo "#define NUMERIC_BUILD          $version" >> version_code.h
echo "#define INTERNAL_BUILD_CODE   \"${major_letter}${minor}${patch_letter}${build}\"" >> version_code.h
echo "#define DATE                  \"$(date +"%Y %B %d")\"" >> version_code.h
echo "#define YEAR                  \"$(date +"%Y")\"" >> version_code.h
