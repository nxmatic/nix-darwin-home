{
  self,
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./primaryUser.nix
    ./nixpkgs.nix
    ./dnsmasq.nix
    ./qemu.nix
  ];

  # Enable and configure Zsh
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
    };
  };

  # User configuration
  user = {
    description = "Stephane Lacoin";
    home = "${
      if pkgs.stdenvNoCC.isDarwin
      then "/Users"
      else "/home"
    }/${config.user.name}";
    shell = pkgs.zsh;
  };

  # Home-manager configuration
  home-manager = {
    extraSpecialArgs = {inherit self inputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    backupFileExtension = "nix-backup";
  };

  # Environment setup
  environment = {
    variables = {
      XDG_RUNTIME_DIR = "${config.user.home}/.xdg";
    };

    systemPackages = import ./system-packages.nix {
      inherit pkgs inputs config;
    };

    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${inputs.nixpkgs}";
    };

    # List of acceptable shells in /etc/shells
    shells = with pkgs; [bash zsh fish];
  };

  # Tailscale service configuration
  services.tailscale = {
    enable = true;
  };

  # Fonts configuration
  fonts = {
    packages = with pkgs; [powerline-fonts];
  };
}
