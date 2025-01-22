#!/usr/bin/env -S bash -euo pipefail
# -*- mode: sh -*-

test -n "${GIT_TRACE:-}" && set -x

# Exit if the operation and file names were not given
test $# -ge 1

# Do not run if no .sops.yaml in repository
test -r .sops.yaml || {
  echo >&2 "You do not have configured sops for that repository. You're missing $( pwd )/.sops.yaml.";
  exit 1;
}

git::sops:input:yq:format() {
  case "${META[fileExt]}" in
    "yml"|"yaml")
      echo "yaml";;
    "json")
      echo "json";;
    "xml")
      echo "xml";;
    "env|dotenv|props|properties")
      echo "properties";;
    "csv")
      echo "csv";;
    "tsv")
      echo "tsv";;
    "base64"|"b64")
      echo "base64";;
    "uri")
      echo "uri";;
    "toml")
      echo "toml";;
    "lua")
      echo "lua";;
    *)
      echo "unsupported";;
  esac
}


git::sops:show() {
  printf "%s\n" "${@}"
}

# Append or strip the git sops trailer
GIT_SOPS_TRAILER="git::sops:trailer"

git::sops:input:trailer:concat() {
  cat <<!
  ${1:-$( cat /dev/stdin )}
  ${GIT_SOPS_TRAILER}
!
}

git::sops:input:trailer:strip() {
  echo "${1%${GIT_SOPS_TRAILER}}"
}

# Wrapper
git::sops() {
  local operation="$1"
  case $operation in
    show)
      git::sops:show "${@:2}"
      ;;
    decrypt|encrypt)
      local filecontent="$( cat /dev/stdin )"
      
      [[ -z "${filecontent}" ]] &&
	return

      local operation="${1}"

      git::sops::${operation} <<<"${filecontent}"
      ;;
  esac
}

declare -A SCRIPT

SCRIPT[name]="$( basename $0 )"
SCRIPT[dir]="$( dirname $0 )"

if [[ -h "${0}" ]]; then
  OP=${SCRIPT[name]##*-}       # Extract operation from script name
  FORMAT=${SCRIPT[name]%%[-]*} # Extract format from script name
  FILE="$1"                    # First argument as file

  case "$OP" in
    "textconv")
      exec <"${FILE}"
      ;;
    *)
      ;;
  esac
  
  exec "$( realpath $0 )" $OP $FORMAT "${@}"
fi

# Exit if no stdin available.
# stdin is used to fed sops with the content to encrypt / decrypt.
test ! -t 0

# First arg passed to script.
# clean is meant to call sops encrypt
# smudge is meant to call sops decrypt
OP="${1}"
FORMAT="${2}"
FILE="${3}"

# Second arg passed to script
# The file name is fed to sops --filename-override so that sops can apply the creation_rules
# based on .sops.yaml file in the root of the repo.
declare -A META=(
  [filePath]="${FILE}"
  [fileName]="$( basename "${FILE}" )"
  [fileExt]="${FILE##*.}"
  [fileFormat]="${FORMAT}"
)

# Third arg passed to script
if [[ -n "${META[fileFormat]}" && "${META[fileFormat]}" != "binary" ]]; then
  git::sops::encrypt() {
    yq -o yaml eval . /dev/stdin |
      sops --encrypt --input-type yaml --filename-override "${META[fileName]}" /dev/stdin
  }
  git::sops::decrypt() {
      sops --decrypt --input-type yaml --filename-override "${META[fileName]}" /dev/stdin |
    yq --input-format=yaml --output-format=${META[fileFormat]} eval . /dev/stdin
  }
else
  git::sops::encrypt() {
    sops --encrypt --input-type=binary --filename-override "${META[fileName]}" /dev/stdin
  }
  git::sops::decrypt() {
    sops --decrypt --input-type=binary --filename-override "${META[fileName]}" /dev/stdin
  }
fi

case "${OP}" in
  "smudge")
    # Just decrypt the stdin contents.
    TMP=$(mktemp)
    DECRYPTED=$( git::sops decrypt </dev/stdin 2> "$TMP" )
    err=$(cat "$TMP")
    rm "$TMP"
    wrong_key_error_message="age: no identity matched any of the recipients"
    if [[ $err == *"${wrong_key_error_message}"* ]]; then
      :
    else
      git::sops show "${DECRYPTED}"
    fi
    ;;
  "textconv"|"clean")
    # Either the file was not committed yet, or the existing decrypted content is different
    # from the input, in which case we output the new encrypted input.
    # If the file was commited and its decrypted content is the same as the new input,
    # output the old encrypted content.
    ENCRYPTED_HEAD_CONTENTS="$( git cat-file -p "HEAD:${META[filePath]}" 2>/dev/null || true )"
    DECRYPTED_HEAD_CONTENTS="$( git::sops decrypt <<<"${ENCRYPTED_HEAD_CONTENTS}" )"
    
    INPUT="$( cat /dev/stdin )"

    if [[ -z "${ENCRYPTED_HEAD_CONTENTS}" || "${DECRYPTED_HEAD_CONTENTS}" != "${INPUT}" ]]; then
      OUTPUT="$( git::sops encrypt <<<"${INPUT}" 2>/dev/null )"
    else
      OUTPUT="${ENCRYPTED_HEAD_CONTENTS}"
    fi
    git::sops show "${OUTPUT}"
    ;;
  *)
    exit 1;;
esac

