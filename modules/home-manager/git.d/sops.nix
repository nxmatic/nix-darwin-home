# The git sops clean/smudge filter, sourced from the shared `git-sops-filter` package
# (./git-sops-filter.nix) so the operator's git and the in-cluster flox render env
# consume ONE derivation — the SSOT. The package bakes its own store path as
# `sopsConfigHome`, so a single global include wires the filter + diff commands with no
# per-file xdg copies (the previous inline derivation + eleven `xdg.configFile` entries
# collapsed into this one include of the package's own `sops` file).
{
  pkgs,
  ...
}:
let
  gitSopsFilter = pkgs.callPackage ./git-sops-filter.nix { };
in
{
  programs.git.includes = [ { path = "${gitSopsFilter}/sops"; } ];
}
