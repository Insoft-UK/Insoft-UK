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

clear
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

# Function to get the file creation year (for macOS using `stat`)
get_file_creation_year() {
    local file=$1
    # Use `stat` to get the file creation time
    local creation_time=$(stat -f %B "$file")
    if [[ "$creation_time" -gt 0 ]]; then
        # Convert timestamp to year
        date -r "$creation_time" +%Y
    else
        echo "Unknown"
    fi
}

# Get the current year
current_year=$(date +%Y)

# Iterate over all matching files
find . -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) | while read -r file; do
    # Extract the year from the copyright line
    if grep -q "// Copyright (c) [0-9]\{4\} Insoft. All rights reserved." "$file"; then
        # Get the existing copyright year
        existing_year=$(grep "// Copyright (c) [0-9]\{4\} Insoft. All rights reserved." "$file" | grep -o "[0-9]\{4\}")
        
        # Update copyright line if the current year is greater than the existing copyright year
        if (( current_year > existing_year )); then
            sed -i '' "s,// Copyright (c) $existing_year Insoft. All rights reserved.,// Copyright (c) $existing_year-$current_year Insoft. All rights reserved.," "$file"
        fi

        # Get the file creation year
        creation_year=$(get_file_creation_year "$file")

        # Add "Originally created in [year]" line if the file creation year is less than the existing copyright year
        if [[ "$creation_year" != "Unknown" && "$creation_year" -lt "$existing_year" ]]; then
            # Add the line only if it doesn't already exist
            if ! grep -q "// Originally created in $creation_year" "$file"; then
                sed -i '' "/^\/\/ Copyright (c) $existing_year-$current_year Insoft. All rights reserved./a\\
// Originally created in $creation_year" "$file"
            fi
        fi
    fi
done

echo "Update complete."
