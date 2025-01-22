{pkgs, lib, ...}: {
  home.packages = [pkgs.github-cli pkgs.git-crypt];

  programs.git = {
    enable = true;
    aliases = {
      ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
    };
    extraConfig = {
      credential.helper =
        if pkgs.stdenvNoCC.isDarwin
        then "osxkeychain"
        else "cache --timeout=1000000000";
      commit.verbose = true;
      fetch.prune = true;
      http.sslVerify = true;
      init.defaultBranch = "main";
      pull.rebase = true;
      push.followTags = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
    };
    aliases = {
      fix = "commit --amend --no-edit";
      oops = "reset HEAD~1";
      sub = "submodule update --init --recursive";
    };
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
        light = true;
      };
    };
    difftastic.enable = false;
    lfs.enable = true;
    includes = [
      { path = "dotfiles"; }
      { path = "local"; }
    ];
  };

  xdg.configFile = {
    "git" = {
      source = lib.fileset.toSource {
        root = ./git.d;
        fileset = lib.fileset.difference 
          (lib.fileset.fromSource ./git.d)
          (lib.fileset.unions [
            (./git.d/sops.d)
            (./git.d/sops.sh)
            (./git.d/sops.nix)
          ]);
      };
      recursive = true;
    };
  };

  imports = [ ./git.d/sops.nix ];

}
