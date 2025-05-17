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

#!/bin/bash

# Directory containing your compiled binaries
BIN_DIR="./bin"
# Directory to store collected dylibs
LIB_DIR="./libs"

mkdir -p "$LIB_DIR"

# Loop over all binaries in BIN_DIR
find "$BIN_DIR" -type f -perm +111 | while read -r binary; do
    echo "Processing: $binary"
    
    # Get list of dynamic libraries used by the binary
    otool -L "$binary" | tail -n +2 | awk '{print $1}' | while read -r lib; do
        # Skip system libraries
        if [[ "$lib" == /usr/lib/* || "$lib" == /System/Library/* ]]; then
            continue
        fi

        libname=$(basename "$lib")
        dest="$LIB_DIR/$libname"

        # Copy the .dylib if we haven't already
        if [ ! -f "$dest" ]; then
            echo "  Copying: $lib -> $dest"
            cp "$lib" "$dest"
        fi

        # Update binary to use local lib path
        echo "  Rewriting install_name: $lib -> @executable_path/../libs/$libname"
        install_name_tool -change "$lib" "@executable_path/../libs/$libname" "$binary"
    done
done
