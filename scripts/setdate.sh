#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2025 Insoft. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

ANSI_ART=$(cat <<EOF
          ************
        ************
      ************
    ************  **
  ************  ******
************  **********
**********    ************
************    **********
  **********  ************
    ******  ************
      **  ************
        ************
      ************
    ************
EOF
)
printf "$ANSI_ART\n"

if [ ! -f "date.txt" ]; then
    echo "Error: No date provided and date.txt not found."
    exit 1
fi

if [ -z "$1" ]; then
    new_date=$(cat "setdate.txt")
else
    new_date=$1
fi

# Validate the date format (YYYY-MM-DD) and convert to touch-compatible format
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS date validation and formatting
    if ! formatted_date=$(date -j -f "%Y-%m-%d" "$new_date" "+%Y%m%d0000.00" 2>/dev/null); then
        echo "Error: Invalid date format. Use YYYY-MM-DD."
        exit 1
    fi
else
    # Linux date validation and formatting
    if ! date -d "$new_date" &>/dev/null; then
        echo "Error: Invalid date format. Use YYYY-MM-DD."
        exit 1
    fi
    formatted_date=$(date -d "$new_date 00:00:00" "+%Y%m%d0000.00")
fi

# Use `find` to get the list of files in the current directory (recursively)
files=$(find . -type f)

# Loop through each file found by `find` and update its creation date
for file in $files; do
    if [[ -e $file ]]; then
        # Preserve the original modification date
        original_mod_date=$(stat --format='%y' "$file" 2>/dev/null || stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")

        # Update the creation/access time
        touch -t "$formatted_date" "$file"
        echo "Updated creation/access time of $file to $new_date 00:00:00."

        # Restore the original modification date
        if [[ "$(uname)" == "Darwin" ]]; then
            touch -mt "$(date -j -f "%Y-%m-%d %H:%M:%S" "$original_mod_date" "+%Y%m%d%H%M.%S")" "$file"
        else
            touch -d "$original_mod_date" "$file"
        fi
    else
        echo "Error: File $file does not exist."
    fi
done

echo "Update complete."
