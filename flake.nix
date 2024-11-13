{
  description = "nix system configurations";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      #      "https://kclejeune.cachix.org"
      "https://cache.flox.dev"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      #      "kclejeuneachix.org-1:fOCrECygdFZKbMxHClhiTS6oowOkJ/I/dh9q9b1I4ko="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin"; #unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv.url = "github:cachix/devenv/latest";
    flox = {
      url = "github:nxmatic/flox?ref=hotfix/nix-remove-attrcursor-force-errors";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    socket-vmnet = {
      url = "github:nxmatic/nix-socket-vmnet/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "git+file:///Volumes/GitHub/nxmatic/nix-zen-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    bird = {
      url = "github:nxmatic/bird?ref=hotfix/v2.15.1-nix-darwin";
      flake = true;
    };
    maven-mvnd = {
      url = "github:nxmatic/nix-maven-mvnd/develop";
      flake = true;
    };
  };

  outputs = {
    self,
    darwin,
    devenv,
    flake-utils,
    home-manager,
    socket-vmnet,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (flake-utils.lib) eachSystemMap;
    isDarwin = system: builtins.elem system nixpkgs.lib.platforms.darwin;
    homePrefix = system:
      if isDarwin system
      then "/Users"
      else "/home";
    defaultSystems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux"];

    # Helper function to generate a set of attributes for each system
    forAllSystems = nixpkgs.lib.genAttrs defaultSystems;

    # Import nixpkgs with overlays and config for each system
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
          checkAllPackages = false;
        };
        overlays =
          builtins.map
          (
            name: let
              overlay = self.overlays.${name} inputs;
            in
              final: prev: builtins.traceVerbose "Applying overlay: ${name}" (overlay final prev)
          )
          (builtins.attrNames self.overlays);
      });

    mkDarwinConfig = {
      system ? "aarch64-darwin",
      nixpkgs ? inputs.nixpkgs,
      baseModules ? [
        #       inputs.zen-browser.darwinModule
        socket-vmnet.darwinModules.socket_vmnet
        home-manager.darwinModules.home-manager
        ./modules/darwin
      ],
      extraModules ? [],
    }: let
      debugModule = {config, ...}: {
        _file = "debugModule";
        config = {
          system.activationScripts.debug.text = builtins.traceVerbose "Defining activationScripts" ''
            echo "Debug: activationScripts is being executed"
          '';
        };
      };
    in
      builtins.traceVerbose "Starting darwinSystem evaluation" (
        inputs.darwin.lib.darwinSystem {
          inherit system;
          pkgs = nixpkgsFor.${system};
          modules = builtins.traceVerbose "Combining modules" (baseModules ++ extraModules ++ [debugModule]);
          specialArgs = builtins.traceVerbose "Setting specialArgs" {
            inherit self inputs nixpkgs;
          };
        }
      );

    mkHomeConfig = {
      username,
      system,
      nixpkgs ? inputs.nixpkgs,
      baseModules ? [
        ./modules/home-manager
        {
          home = {
            inherit username;
            homeDirectory = "${homePrefix system}/${username}";
          };
        }
      ],
      extraModules ? [],
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsFor.${system};
        modules =
          baseModules
          ++ extraModules
          ++ [
            {
              nixpkgs.config = {
                allowUnfree = true;
                allowBroken = true;
                checkAllPackages = false;
              };
            }
          ];
        extraSpecialArgs = {inherit self inputs nixpkgs;};
      };
  in {
    darwinConfigurations."work@aarch64-darwin" = mkDarwinConfig {
      system = "aarch64-darwin";
      extraModules = [./profiles/darwin/work.nix];
    };

    homeConfigurations."work@aarch64-darwin" = mkHomeConfig {
      username = "stephane.lacoin";
      system = "aarch64-darwin";
      profile = "work";
      extraModules = [./profiles/home-manager/work.nix];
    };

    devShells = eachSystemMap defaultSystems (
      system: {
        default = devenv.lib.mkShell {
          inherit inputs;
          pkgs = nixpkgsFor.${system};
          modules = [(import ./devenv.nix)];
        };
      }
    );

    packages = eachSystemMap defaultSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in {
        pyEnv = pkgs.python3.withPackages (ps: with ps; [black typer colorama shellingham]);
        sysdo = pkgs.writeScriptBin "sysdo" ''
          #! ${pkgs.python3}/bin/python3
          ${builtins.readFile ./bin/do.py}
        '';
        maven-mvnd-m39 = inputs.maven-mvnd.packages.${system}.maven-mvnd-m39;
        maven-mvnd-m40 = inputs.maven-mvnd.packages.${system}.maven-mvnd-m40;
      }
    );

    overlays = {
      channels = inputs: final: prev: {
        nixpkgs = import inputs.nixpkgs {system = prev.system;};
      };

      extraPackages = inputs: final: prev: {
        inherit (self.packages.${prev.system}) sysdo pyEnv;
        inherit (inputs.devenv.packages.${prev.system}) devenv;
        inherit (inputs.maven-mvnd.packages.${prev.system}) maven-mvnd-m39 maven-mvnd-m40;
        inherit (inputs.socket-vmnet.packages.${prev.system}) socket_vmnet;
      };

      birdOverlay = inputs: import ./overlays/bird.nix inputs;

      floxOverlay = inputs: import ./overlays/flox.nix inputs;

      # zenBrowserOverlay = inputs: import ./overlays/zen-browser.nix inputs;
    };
  };
}
