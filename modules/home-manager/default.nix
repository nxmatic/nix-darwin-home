{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./bat.nix
    ./dircolors.nix
    ./direnv.nix
    ./dotfiles
    ./emacs.nix
    ./fzf.nix
    ./git.nix
#    ./gh.nix
    ./java.nix
    ./keychain.nix
    ./kitty.nix
    ./nvim
    ./nushell.nix
    ./password-store.nix
    ./shell
    ./ssh.nix
    ./tldr.nix
    ./tmux.nix
    ./vscode
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.05";

    sessionVariables = {
      GPG_TTY = "/dev/ttys000";
      EDITOR = "emacs";
      VISUAL = "emacs";
      CLICOLOR = 1;
      LSCOLORS = "ExFxBxDxCxegedabagacad";
#      KAGGLE_CONFIG_DIR = "${config.xdg.configHome}/kaggle";
      HOMEBREW_NO_AUTO_UPDATE = 1;
      XDG_RUNTIME_DIR  = "$HOME/.xdg";
      XDG_BIN_HOME    = "$HOME/.local/bin";
      ZDOTDIR         = "${config.xdg.configHome}/zsh";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.rd/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

    # define package definitions for current user environment
    packages = with pkgs; [
      # awscli2
      age
      alejandra
      cachix
      cb
      cirrus-cli
      comma
      coreutils-full
      curl
      diffutils
      fd
      ffmpeg
      findutils
      flyctl
      gawk
      gh
      gnugrep
      gnupg
      gnused
      (
        google-cloud-sdk.withExtraComponents(
          [ google-cloud-sdk.components.gke-gcloud-auth-plugin ]
        )
      )
      helm-docs
      helmfile
      httpie
      jdk
      k9s
      krew
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      luajit
      mmv
      ncdu
      neofetch
      nix
      nixfmt
      nixpkgs-fmt
      nodejs_latest
      parallel
      passExtensions.pass-otp
      #passExtensions.pass-tomb incompatible with darwin
      passExtensions.pass-audit
      passExtensions.pass-update
      passExtensions.pass-import
      passExtensions.pass-checkup
      passExtensions.pass-genphrase
      poetry
      pre-commit
      # python with default packages
      (python3.withPackages
        (ps:
          with ps; [
            numpy
            scipy
            matplotlib
            networkx
          ]))
      ranger
      rclone
      ripgrep
      rsync
      (ruby.withPackages (ps: with ps; [rufo solargraph]))
      shellcheck
      sops
      stylua
      sysdo
      terraform
      tig
      tree
      treefmt
      trivy
      vagrant
      yarn
      yamllint
      unstable.yq-go
    ];
  };

  #targets.genericLinux.enable = true;

  programs = {
    home-manager = {
      enable = true;
      path = "${config.home.homeDirectory}/.nixpkgs/modules/home-manager";
    };
  };

}
