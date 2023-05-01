{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./bat.nix
    ./direnv.nix
    ./dotfiles
    ./fzf.nix
    ./git.nix
    ./gh.nix
    ./kitty.nix
    ./password-store.nix
    ./nushell.nix
#    ./nvim
    ./shell.nix
    ./ssh.nix
    ./tldr.nix
    ./tmux.nix
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
      VISUAL = "code";
      CLICOLOR = 1;
      LSCOLORS = "ExFxBxDxCxegedabagacad";
#      KAGGLE_CONFIG_DIR = "${config.xdg.configHome}/kaggle";
      # HOMEBREW_NO_AUTO_UPDATE = 1;
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
      google-cloud-sdk
      helm-docs
      helmfile
      httpie
      unstable.jdk11
      k9s
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
      stylua
      sysdo
      terraform
      tig
      tree
      treefmt
      trivy
      vagrant
      yarn
      yq
    ];
  };

  #targets.genericLinux.enable = true;

  programs = {
    home-manager = {
      enable = true;
      path = "${config.home.homeDirectory}/.nixpkgs/modules/home-manager";
    };
    dircolors.enable = true;
    go.enable = true;
    gpg.enable = true;
    password-store.enable = true;
    git.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    man.enable = true;
    nix-index.enable = true;
    pandoc.enable = true;
    starship.enable = true;
    yt-dlp.enable = true;
    zathura.enable = true;
    zoxide.enable = true;
  };
}
