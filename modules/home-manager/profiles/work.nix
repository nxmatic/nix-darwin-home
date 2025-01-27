{ lib, pkgs, config, ... }:
let
  profile = {
    name = "work";
    user = {
      email = "stephane.lacoin@hyland.com";
      name = "stephane.lacoin";
      description = "Stephane Lacoin (aka nxmatic)";
      home = /. + builtins.toPath "/Users/stephane.lacoin";
      shell = pkgs.zsh;
    };
  };
in {

  inherit profile;

  imports = [  ./common.nix ];

}

