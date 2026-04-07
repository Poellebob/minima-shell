{
  description = "minima home-manager and nixos module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    scroll-flake = {
      url = "github:Diax170/scroll-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, stylix, scroll-flake, ... }: {
    homeModules.minima = { ... }: {
      imports = [
        stylix.homeModules.stylix
        nixvim.homeModules.nixvim
        ./home-module.nix
      ];
    };
    homeModules.default = self.homeModules.minima;

    nixosModules.minima = { ... }: {
      imports = [
        inputs.scroll-flake.nixosModules.default
        ./nixos-module.nix
      ];
    };
    nixosModules.default = self.nixosModules.minima;
  };
}
