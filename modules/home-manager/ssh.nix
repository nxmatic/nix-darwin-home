{ config, pkgs, ... }: builtins.traceVerbose "Loading ssh configuration" ( let

  username = "${config.profile.user.name}";
  homeDir = "${config.home.homeDirectory}";
  dataDir = "${homeDir}/.local/var/ssh";
  logPrefix = "${homeDir}/Library/Logs/ssh";

in {

  home.file.".ssh" = {
    source = ./ssh.d;
    recursive = true;
  };

  programs.ssh = {
    enable = true;
    includes = [ "config.d/*" ];
    forwardAgent = true;
    controlPath = "~/.ssh/master-%C";
  };

  launchd.agents."com.openssh.ssh-add-keys" = {

    config = {

      EnvironmentVariables = {
        SSH_AUTH_SOCK = "${homeDir}/Library/Containers/com.apple.sshd/ssh-agent.socket";
      };

      ProgramArguments = [
        "${pkgs.openssh}/bin/ssh-add"
        "-q"
        "${homeDir}/.ssh/keys.d/*"
      ];

      RunAtLoad = true;
      KeepAlive = false;
      StandardErrorPath = "${logPrefix}/ssh-add-keys.err";
      StandardOutPath = "${logPrefix}/ssh-add-keys.out";
    };

  };

}
