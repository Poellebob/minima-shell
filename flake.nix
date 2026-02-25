{
  description = "minima-shell - userspace shell + Hyprland config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

outputs = { self, nixpkgs, flake-utils, home-manager }:
  let
    lib = nixpkgs.lib;
  in
  {
    packages = flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        minima-shell = pkgs.stdenv.mkDerivation {
          pname = "minima-shell";
          version = "0.1.0";

          src = ./config;

          installPhase = ''
            mkdir -p $out
            cp -r * $out/
          '';

          meta = with pkgs.lib; {
            description = "Minima-shell: userspace shell and config";
            license = licenses.mit;
          };
        };
      }
    );

    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      name = "minima-shell-dev";

      buildInputs = with pkgs; [
        wireplumber
        libgtop
        bluez
        bluez-tools
        btop
        networkmanager
        jemalloc
        dart-sass
        wl-clipboard
        brightnessctl
        swww
        python3
        upower
        neovim
        power-profiles-daemon
        gvfs
        cliphist
        hyprlock
        hypridle
        kitty
        qt5.qtwayland
        qt6.qtwayland
        nerd-fonts.jetbrains-mono
        grim
        slurp
        swappy
        jq
        bc
        fzf
        zoxide
        git
        zsh
        neofetch
        polkit
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xdg-utils
      ];

      shellHook = ''
        echo "minima-shell dev shell"
      '';
    };

    homeConfigurations = {
      "minima" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./home-manager.nix
        ];
      };
    };
  };
}
