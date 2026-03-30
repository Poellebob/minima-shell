{ lib, pkgs, ... }:

with lib;
{
  options.minima = {
    enable = mkEnableOption "Minima shell";
    theming.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardcoded Minima styling (Breeze/Papirus/Rose-Pine)";
    };

    enableBranding = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Minima name in fetch";
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Nvidia graphics";
    };

    terminal = {
      name = mkOption {
        type = types.str;
        default = "kitty";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.kitty;
        description = "Terminal package";
      };
    };

    shell.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell integration (zsh, fzf, starship, etc.)";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages to install";
    };

    wm = mkOption {
      type = types.enum [ "sway" "swayfx" "scroll" "hyprland" ];
      default = "sway";
      description = "Window manager to use";
    };
  };
}
