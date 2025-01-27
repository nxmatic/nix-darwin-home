{ lib, pkgs, config, ... }:
let
  profile = {
    name = "committed";
    user = {
      name = "nxmatic";
      email = "stephane.lacoin@gmail.com";
      description = "Stephane Lacoin (aka nxmatic)";
      home = builtins.toPath "/Users/nxmatic";
      shell = pkgs.zsh;
    };
  };
in {
  inherit profile;

  imports = [ ./common.nix ];
}