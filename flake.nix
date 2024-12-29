# This can be built with nixos-rebuild --flake .#myhost build
{
  description = "the simplest flake for nixos-rebuild";

  inputs = {
    nixpkgs = {
      # Using the nixos-unstable branch specifically, which is the
      # closest you can get to following the equivalent channel with flakes.
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware"; # this channel have the setting for the RPI hardwares
    };
    disko.url = "github:nix-community/disko";
  
  
  }; # end of inputs definition

  # Outputs can be anything, but the wiki + some commands define their own
  # specific keys. Wiki page: https://nixos.wiki/wiki/Flakes#Output_schema
  outputs = { self, nixpkgs, nixos-hardware }: {
    # nixosConfigurations is the key that nixos-rebuild looks for.
    nixosConfigurations = {
      myhost = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        # Import our old system configuration.nix
        modules = [
          ./configuration.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
    };
  };
}
