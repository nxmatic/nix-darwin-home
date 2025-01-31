{
  inputs,
  config,
  pkgs,
  ...
}: let

  user = config.profile.user;
  userName = user.name;
  userDescription = user.description;
  userHome = user.home;
  userShell = user.shell;

  gcScript = pkgs.writeScript "nix-gc-script" ''
    #!${pkgs.bash}/bin/bash
    ${config.nix.package}/bin/nix-collect-garbage --delete-older-than 7d
    ${config.nix.package}/bin/nix store optimise
  '';

in {
  environment = {
    etc = {darwin.source = "${inputs.darwin}";};
    # packages installed in system profile (more in ../common/default.nix)
    # systemPackages = [ ];
  };

  # auto manage nixbld users with nix darwin
  nix = {
    configureBuildUsers = true;
    nixPath = ["darwin=/etc/${config.environment.etc.darwin.target}"];

    # Additional garbage collection triggers
    extraOptions = ''
      accept-flake-config = true
      extra-platforms = x86_64-darwin aarch64-darwin
      min-free = ${toString (10 * 1024 * 1024 * 1024)}  # 10 GB
      max-free = ${toString (20 * 1024 * 1024 * 1024)}  # 20 GB
    '';

    # Optimize the store
    optimise.automatic = true;
  };

  launchd.user.agents.nix-gc = {
    serviceConfig = {
      ProgramArguments = ["${gcScript}"];
      KeepAlive = false;
      RunAtLoad = false;
      StartInterval = 43200; # 12 hours in seconds
    };
  };

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
    checkAllPackages = false;
  };

  # nixpkgs.overlays = [
  #   (self: super: {
  #     # Disable checks for all packages
  #     all = super.all.overrideAttrs (oldAttrs: {
  #       doCheck = false;
  #       doInstallCheck = false;
  #     });
  #   })
  # ];

  launchd.user.envVariables = {
    XDG_RUNTIME_DIR = "${userHome}/.xdg";
    XDG_RUNTIME_DIR = "${userHome}/.xdg";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  users.users.${userName} = {
    home = userHome;
    description = userDescription;
    shell = userShell;
  };

  users.users.${userName} = {
    home = userHome;
    description = userDescription;
    shell = userShell;
  };
}
