{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  
  user = config.profile.user;
  userName = user.name;
  userHome = user.home;

  cfg = config.services.tailscale;
  logPrefix = "${userHome}/Library/Logs/tailscale";
in {
  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.tailscale];
    launchd.user.agents.tailscale = {
      command = "${lib.getExe pkgs.tailscale}";
      serviceConfig = {
        Label = "net.tailscale.tailscale";
        KeepAlive = true;
        LowPriorityIO = true;
        ProcessType = "Background";
        StandardOutPath = "${logPrefix}-out.log";
        StandardErrorPath = "${logPrefix}-error.log";
        EnvironmentVariables = {
          NIX_PATH = "nixpkgs=" + toString pkgs.path;
          STNORESTART = "1";
        };
      };
    };
  };
}