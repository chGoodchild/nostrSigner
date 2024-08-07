#!/bin/bash

# Define the output JSON file
CHECKSUM_FILE="checksums.json"

# Function to find binaries (files without extensions) in the current directory
function find_binaries() {
    echo "Finding binaries in the current directory..."
    binaries=$(ls -p | grep -v / | grep -v '\.')
    if [ -z "$binaries" ]; then
        echo "No binaries found in the current directory."
        exit 1
    fi
}

# Function to generate checksums and file sizes, and save them in a JSON file
function generate_checksums() {
    echo "Generating checksums and file sizes..."
    checksums="{"
    for binary in $binaries; do
        if [ -f "$binary" ]; then
            checksum=$(sha256sum "$binary" | awk '{print $1}')
            size=$(stat --format="%s" "$binary")
            checksums+="\"${binary}_checksum\": \"$checksum\","
            checksums+="\"${binary}_size\": \"$size\","
        fi
    done
    # Remove the last comma and add the closing brace
    checksums=$(echo "$checksums" | sed 's/,$//')
    checksums="${checksums}}"

    # Format the JSON using jq
    echo "$checksums" | jq . > $CHECKSUM_FILE
    echo "Checksums and file sizes saved to $CHECKSUM_FILE"
}

# Main execution flow
find_binaries
generate_checksums

