{...}:
builtins.traceVerbose "Evaluating darwin/default.nix" {
  imports = builtins.map (module: builtins.traceVerbose "Importing ${module}" (import module)) [
    ../common
    ./preferences.nix
    ./security.nix
    ./core.nix
    ./emacs.nix
    ./raycast.nix
    ./socket_vmnet.nix
    ./syncthing.nix
    ./tailscale.nix
    ./homebrew.nix
  ];
}
