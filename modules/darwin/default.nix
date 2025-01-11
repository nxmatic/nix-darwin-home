{ config, pkgs, inputs, ... }:
builtins.traceVerbose "Evaluating darwin/default.nix" {
  imports = builtins.map (module: builtins.traceVerbose "Importing ${module}" (import module)) [
    ../common
    ./preferences.nix
    ./security.nix
    ./core.nix
    ./environment.nix
  ];
}
