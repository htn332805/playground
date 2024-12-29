{
  description = "Hai NixOS configuration on https://github.com/htn332805/playground.git";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.home-manager.url = "github:nix-community/home-manager/release-24.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nur.url = "github:nix-community/NUR";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-index-database.url = "github:Mic92/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.jeezyvim.url = "github:LGUG2Z/JeezyVim";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:
    with inputs; let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = system: (import nixpkgs rec {
        inherit system;

        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # FIXME:: add any insecure packages you absolutely need here
          ];
        };

        overlays = [
          nur.overlays.default
          jeezyvim.overlays.default

          (_final: prev: {
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
          })
        ];
      });

      configurationDefaults = args: {
        nixpkgs = nixpkgsWithOverlays;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      argDefaults = {
        inherit secrets inputs self nix-index-database;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      };

      mkNixosConfiguration = {
        #system ? "x86_64-linux",
        system ? "aarch64-linux",
        hostname,
        username,
        args ? {},
        modules,
      }: let
        specialArgs = argDefaults // {inherit hostname username;} // args;
      in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          pkgs = nixpkgsWithOverlays system;
          modules =
            [
              (configurationDefaults specialArgs)
              home-manager.nixosModules.home-manager
            ]
            ++ modules;
        };
    in {
      #formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      nixosConfigurations.wsl = mkNixosConfiguration {
        hostname = "wsl";
        username = "nixos"; # FIXME: replace with your own username!
        modules = [
          nixos-wsl.nixosModules.wsl
          ./wsl.nix
        ];
      }; #end of wsl configuration

      nixosConfigurations.pi4 = mkNixosConfiguration {
        hostname = "pi4";
        username = "nixos"; # FIXME: replace with your own username!
        modules = [
          disko.nixosModules.disko
          ./linux.nix
          ./pi4.nix
        ];
      };

    };
}