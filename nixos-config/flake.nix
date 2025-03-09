{
  description = "NixOS system config but as a flake (update this description when your mental model is better)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    #home-manager = {
    #  url = "github:nix-community/home-manager/master";
    #  inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list where available
    #};

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
  }: {
    nixosConfigurations.hakurei = nixpkgs.lib.nixosSystem {
      # pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; };};
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t430
        # According to Reddit /u/Aidenn0: This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
        (_: {nix.registry.nixpkgs.flake = nixpkgs;})
      ];
    };
  };
}
