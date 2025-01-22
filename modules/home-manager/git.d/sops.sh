#!/usr/bin/env -S bash -euo pipefail
# -*- mode: sh -*-

: ${SOPS_CONFIG_HOME:=${XDG_CONFIG_HOME:-'~/.config'}/git/sops.d}

sops::config() {
  local fmt=${1}
  local name=sops-${fmt}
  
  cat <<EOF > sops.d/$fmt
[filter "$name"]
  clean = $SOPS_CONFIG_HOME/$fmt-clean %f
  smudge = $SOPS_CONFIG_HOME/$fmt-smudge %f
[diff "$name"]
        textconv = $SOPS_CONFIG_HOME/$fmt-textconv
EOF
}


sops::bin() {
  local fmt=$1

  ln -fs .sh sops.d/$fmt-clean
  ln -fs .sh sops.d/$fmt-smudge
  ln -fs .sh sops.d/$fmt-textconv
}

cat <<EOF > sops
[include]
$( for fmt in binary yaml json xml props csv tsv base64 uri toml lua; do
  sops::config $fmt
  sops::bin $fmt 
  echo "    path = sops.d/$fmt"
done )
EOF
