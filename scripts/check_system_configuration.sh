#!/bin/bash
# compile_and_run.sh
source ../cpp/check_configuration.cpp
SOURCE="check_configuration.cpp"
TARGET="check_config_file"

# Έλεγξε αν το source είναι νεότερο από το target
if [ ! -f "$TARGET" ] || [ "$SOURCE" -nt "$TARGET" ]; then
    echo "🔄 Compiling $SOURCE ..."
    g++ -Wall -std=c++11 -o "$TARGET" "$SOURCE"
    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed!"
        exit 1
    fi
    echo "✅ Compilation successful"
fi

# Εκτέλεση
./"$TARGET"
