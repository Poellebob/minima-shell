{
  description = "minima home-manager module";

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
  };

  outputs = { self, nixpkgs, home-manager, nixvim, stylix, ... }: {
    homeModules.minima = { ... }: {
      imports = [
        stylix.homeModules.stylix
        nixvim.homeModules.nixvim
        (import ./minima.nix)
      ];
    };
    homeModules.default = self.homeModules.minima;
  };
}
