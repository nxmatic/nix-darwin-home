# filepath: /Volumes/GitHub/nxmatic/nix-darwin-home/modules/home-manager/profiles/common.nix
{ lib, pkgs, config, ... }: let
  cfg = config.profile;
in
{
  options = {
    profile = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "The name of the profile";
            default = "jdoe";
          };
          user = lib.mkOption {
            type = lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "The name of the primary user";
                  default = "jdoe";
                };
                description = lib.mkOption {
                  type = lib.types.str;
                  description = "A description of the primary user";
                  default = "Default User";
                };
                email = lib.mkOption {
                  type = lib.types.str;
                  description = "The email of the primary user";
                  default = "jdoe@example.com";
                };
                home = lib.mkOption {
                  type = lib.types.str;
                  description = "The home directory of the primary user";
                  default = ""; #${if pkgs.stdenvNoCC.isDarwin then "/Users" else "/home"}/jdoe"; #${cfg.user.name}";
                };
                shell = lib.mkOption {
                  type = lib.types.package;
                  description = "The shell of the primary user";
                  default = pkgs.zsh;
                };
              };
            };
            description = "User-specific attributes";
          };
        };
      };
      description = "Profile currently evaluated";
    };

    hm = lib.mkOption {
      type = lib.types.attrs;
      description = "Home Manager configuration";
      default = lib.mkDefault { };
    };
  };

  # config = {
  #   hm = {
  #     programs.git = {
  #       enable = true;
  #       userEmail = cfg.user.email;  # Reference cfg instead of config.profile
  #       userName = cfg.user.name;    # Reference cfg instead of config.profile
  #       signing = {
  #         key = cfg.user.email;      # Reference cfg instead of config.profile
  #       };
  #     };
  #   };
  # };

}