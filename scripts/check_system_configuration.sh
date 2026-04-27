#!/bin/bash

# check_system_configuration.sh

SOURCE="../cpp/check_configuration.cpp"
TARGET="../cpp/check_configuration"

# Compile only if needed
if [ ! -f "$TARGET" ] || [ "$SOURCE" -nt "$TARGET" ]; then
    echo "🔄 Compiling $SOURCE ..."
    g++ -Wall -std=c++11 -o "$TARGET" "$SOURCE"
    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed!"
        exit 1
    fi
    echo "✅ Compilation successful"
fi

# Run executable
"$TARGET"
