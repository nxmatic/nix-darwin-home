#!/bin/bash

# Function to check if .sops.yaml exists
sops:check_sops_yaml() {
    if [[ ! -f .sops.yaml ]]; then
        echo ".sops.yaml not found!"
        exit 1
    fi
}

# Function to extract file patterns from .sops.yaml
sops:extract_file_patterns() {
    local filePatterns
    filePatterns=$(grep -oP '(?<=path_regex: ).*' .sops.yaml)
    
    # Create an array to hold matched files
    matchedFiles=()
    
    # Loop through each pattern and find matching files
    for pattern in $filePatterns; do
        while IFS= read -r -d '' file; do
            matchedFiles+=("$file")
        done < <(find . -type f -regex "$pattern" -print0)
    done
    
    # Return the matched files array
    echo "${matchedFiles[@]}"
}

# Function to generate the encrypted filename
sops:generate_encrypted_filename() {
    local originFile="$1"
    local filename="${originFile%%.*}"
    local ext="${originFile#*.}"
    echo "$filename.enc.$ext"
}

# Function to decrypt the file if it doesn't exist
sops:decrypt_file_if_missing() {
    local originFile="$1"
    local encryptedFilename="$2"
    
    if [[ ! -e $originFile ]]; then
        sops -d --output "$originFile" "$encryptedFilename"
        echo "$originFile has been created from $encryptedFilename."
    fi
}

# Function to check for changes and print diffs
sops:check_for_changes() {
    local originFile="$1"
    local encryptedFilename="$2"

    fileChanged=$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD -- "$encryptedFilename")
    
    if [[ ! -z $fileChanged ]]; then
        echo -e "\n========================================================================="
        echo "$originFile has been changed. Please review"
        echo "-------------------------------------------------------------------------"
        sops -d "$encryptedFilename" | diff -u --color --ignore-trailing-space "$originFile" -
        echo "========================================================================="
        echo -e "\n"
    fi
}
