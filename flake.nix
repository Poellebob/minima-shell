
{
  description = "minima-shell - userspace shell + Hyprland config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShell = pkgs.mkShell {
        name = "minima-shell-dev";

        buildInputs = with pkgs; [
          wireplumber
          libgtop
          bluez
          bluezUtils
          btop
          networkmanager
          dart-sass
          wl-clipboard
          brightnessctl
          swww
          python310
          upower
          pacman-contrib
          power-profiles-daemon
          gvfs
          cliphist
          hyprland
          hyprlock
          hypridle
          kitty
          qt5.qtwayland
          qt6.qtwayland
          ttfJetBrainsMonoNerd
          grim
          slurp
          swappy
          jq
          bc
          fzf
          zoxide
          git
          zsh
        ];

        shellHook = ''
          echo "minima-shell" 
        '';
      };

      packages = {
        minima-shell = pkgs.stdenv.mkDerivation {
          pname = "minima-shell";
          version = "0.1.0";

          src = ./.;

          buildInputs = with pkgs; [
            git
            zsh
            kitty
          ];

          installPhase = ''
            mkdir -p $out
            cp -r * $out/
          '';

          meta = with pkgs.lib; {
            description = "Minima-shell: userspace shell and Hyprland config";
            license = licenses.mit;
            maintainers = with maintainers; [ self ];
          };
        };
      };
    }
  );
}
