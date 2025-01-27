{...}: {
  programs.ssh = {
    enable = true;
    includes = ["config.d/*"];
    forwardAgent = true;
    controlPath = "~/.ssh/master-%C";
  };

  launchd.agents."com.openssh.ssh-add-keys" = {

    config = {
      Label = "ssh-add-keys";
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

  home.file.".ssh" = {
    source = ./ssh.d;
    recursive = true;
  };

}
