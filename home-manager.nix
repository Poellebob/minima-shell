{ config, pkgs, lib, ... }:

{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  home.file = {
    ".config/hypr" = {
      source = ./config/hypr;
      recursive = true;
    };
    ".config/sway" = {
      source = ./config/sway;
      recursive = true;
    };
    ".config/scroll" = {
      source = ./config/scroll;
      recursive = true;
    };
    ".config/quickshell" = {
      source = ./config/quickshell;
      recursive = true;
    };
    ".config/gtk-3.0" = {
      source = ./config/gtk-3.0;
      recursive = true;
    };
    ".config/gtk-4.0" = {
      source = ./config/gtk-4.0;
      recursive = true;
    };
    ".config/rofi" = {
      source = ./config/rofi;
      recursive = true;
    };
    ".config/kitty" = {
      source = ./config/kitty;
      recursive = true;
    };
    ".config/dolphinrc" = {
      source = ./config/dolphinrc;
    };
    ".config/fastfetch" = {
      source = ./config/fastfetch;
      recursive = true;
    };
    ".config/qt5ct" = {
      source = ./config/qt5ct;
      recursive = true;
    };
    ".config/qt6ct" = {
      source = ./config/qt6ct;
      recursive = true;
    };
    ".config/nvim" = {
      source = ./config/nvim;
      recursive = true;
    };
  };

  targets.genericLinux.enable = true;
}
