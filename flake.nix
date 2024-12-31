# This can be built with nixos-rebuild --flake .#myhost build
#  git clone https://github.com/htn332805/playground.git && cd playground && nixos-rebuild -v --flake .#pi4test switch
{
  description = "the simplest flake for nixos-rebuild";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    jeezyvim.url = "github:LGUG2Z/JeezyVim";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  }; # end of inputs definition

  # Outputs can be anything, but the wiki + some commands define their own
  # specific keys. Wiki page: https://nixos.wiki/wiki/Flakes#Output_schema
  outputs = inputs: 
    with inputs; let

      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
      forEachPkgs = f: forEachSystem (sys: (f nixpkgs.legacyPackages.${sys}));

      nixpkgsWithOverlays = system: (import nixpkgs rec {
        inherit system;

        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # FIXME:: add any insecure packages you absolutely need here
          ];
        }; #end of config

        overlays = [
          nur.overlays.default
          jeezyvim.overlays.default

          (_final: prev: {
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
          }) #end of final: prev:
        ]; #end of overlays list
      }); #end of nixpkgsWithOverlays

      configurationDefaults = args: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      }; #end of configurationDefault

      argDefaults = {
        inherit secrets inputs self nix-index-database;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      }; #end of argDefaults

      mkNixosConfiguration = {
        system ? "x86_64-linux",
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
        }; #end of nixpkgs.lib.nixosSystem
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    # nixosConfigurations is the key that nixos-rebuild looks for.
    lib = import ./lib inputs;
    devShells = self.lib.mkInstallerShells self.nixosConfigurations;
    formatter = forEachPkgs (pkgs: pkgs.nixpkgs-fmt);

    nixosConfigurations = {
      #FIXME by change xxxmyhostxxx = nixpkgs.lib.nixosSystem 
      pi4test =  mkNixosConfiguration {
        system = "aarch64-linux";
        hostname = "pi4test";
        username = "nixos"; # FIXME: replace with your own username!
        # Import our old system configuration.nix
        modules = [
          ./pi4_host.nix
          nixos-hardware.nixosModules.raspberry-pi-4
          #disko.nixosModules.disko
          #./disko_partition.nix
        ]; #end of pi4test modules
      }; #end of pi4test target
    }; # end of nixosconfiguration
  }; #closing of ouputs
}# bottom and last closing bracket
