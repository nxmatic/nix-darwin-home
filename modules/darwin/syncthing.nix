{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.syncthing;
in {
  options = {
    services.syncthing = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Syncthing service.";
      };

    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.syncthing];
    launchd.user.agents.syncthing = {
      command = "${lib.getExe pkgs.syncthing}";
      serviceConfig = {
        Label = "net.syncthing.syncthing";
        KeepAlive = true;
        LowPriorityIO = true;
        ProcessType = "Background";
#        StandardOutPath = "~/.local/var/log/Syncthing.log"; # xdg data dir
#        StandardErrorPath = "~/.local/var/log/Syncthing-Errors.log"; # xdg data dir
        EnvironmentVariables = {
          NIX_PATH = "nixpkgs=" + toString pkgs.path;
          STNORESTART = "1";
        };
      };
    };
  };
}
