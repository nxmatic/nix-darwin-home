{ config, ...}: {
  imports = [
    ../common.nix
    ./preferences.nix
    ./security.nix
    ./brew.nix
    ./core.nix
    ./lorri.nix
    ./emacs.nix
    ./tailscale.nix
    ./syncthing.nix
    #./display-manager.nix
  ];


}
