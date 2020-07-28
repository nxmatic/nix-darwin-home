{ config, pkgs, ... }: {

  # environment setup
  environment = {
    systemPackages = with pkgs; [
      # editors
      neovim

      # standard toolset
      coreutils-full
      curl
      wget
      git

      # helpful shell stuff
      bat
      fzf
      ripgrep
      zsh
      yadm

      # nix stuff
      nixfmt
      niv

      # scripting languages
      python3
      ruby
    ];

    # list of acceptable shells in /etc/shells
    shells = with pkgs; [ bash zsh fish ];
  };

  nix = {
    package = pkgs.nix;
    trustedUsers = [ defaultUser "root" "@admin" "@wheel" ];
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    buildCores = 8;
    maxJobs = 8;
    readOnlyStore = true;
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
}
