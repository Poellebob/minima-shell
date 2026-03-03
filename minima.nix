{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cfg.minima;
in
{
  options.cfg.minima = {
    enable = mkEnableOption "Minima shell";

    colorScheme = mkOption {
      type = types.str;
      default = "BreezeDark";
      description = "KDE color scheme name";
      example = "BreezeLight";
    };

    colorSchemePath = mkOption {
      type = types.str;
      default = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
      description = "Path to KDE color scheme file";
      example = "\${pkgs.kdePackages.breeze}/share/color-schemes/BreezeLight.colors";
    };

    iconTheme = mkOption {
      type = types.str;
      default = "Papirus-Dark";
      description = "Icon theme name (used by both Qt and GTK)";
      example = "breeze-dark";
    };

    style = mkOption {
      type = types.str;
      default = "Breeze";
      description = "Qt widget style";
      example = "kvantum";
    };

    lookAndFeel = mkOption {
      type = types.str;
      default = "org.kde.breezedark.desktop";
      description = "KDE look and feel package";
      example = "org.kde.breezetwilight.desktop";
    };

    fonts = {
      general = mkOption {
        type = types.str;
        default = "Sans Serif,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        description = "General font configuration string (Qt format)";
      };

      fixed = mkOption {
        type = types.str;
        default = "monospace,9,-1,2,400,0,0,0,0,0,0,0,0,0,0,1";
        description = "Fixed-width font configuration string (Qt format)";
      };
    };

    terminal = {
      package = mkOption {
        type = types.package;
        default = pkgs.kitty;
        description = "Terminal package to install";
        example = literalExpression "pkgs.alacritty";
      };

      application = mkOption {
        type = types.str;
        default = "kitty";
        description = "Default terminal application name";
      };

      service = mkOption {
        type = types.str;
        default = "kitty.desktop";
        description = "Terminal desktop service file";
      };
    };

    gtk = {
      enable = mkEnableOption "GTK theming" // { default = true; };

      themeName = mkOption {
        type = types.str;
        default = "Breeze-dark";
        description = "GTK theme name";
        example = "Adwaita-dark";
      };

      colorScheme = mkOption {
        type = types.enum [ "default" "prefer-dark" "prefer-light" ];
        default = "prefer-dark";
        description = "GTK color scheme preference";
      };

      cursorTheme = {
        name = mkOption {
          type = types.str;
          default = "breeze_cursors";
          description = "Cursor theme name";
          example = "BreezeX-RosePine-Linux";
        };

        size = mkOption {
          type = types.int;
          default = 24;
          description = "Cursor size in pixels";
        };
      };
    };

    wayland = {
      enable = mkEnableOption "Wayland-specific settings" // { default = true; };

      disableWindowDecoration = mkEnableOption "Disable Qt Wayland window decoration" // { default = true; };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install for theming";
      example = literalExpression "[ pkgs.libsForQt5.qtstyleplugin-kvantum ]";
    };
  };

  config = mkIf cfg.enable {
    # Install required theming packages
    home.packages = with pkgs; [
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.breeze
      papirus-icon-theme
    ] ++ cfg.extraPackages;

    # Environment variables for Qt and toolkit backends
    home.sessionVariables = mkMerge [
      {
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
      }
      (mkIf cfg.wayland.enable {
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
      })
      (mkIf cfg.wayland.disableWindowDecoration {
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      })
    ];

    # GTK 3 and GTK 4 configuration
    gtk = mkIf cfg.gtk.enable {
      enable = true;
      theme.name = cfg.gtk.themeName;
      
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = cfg.gtk.colorScheme == "prefer-dark";
      };
      
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = cfg.gtk.colorScheme == "prefer-dark";
      };
      
      cursorTheme = {
        name = cfg.gtk.cursorTheme.name;
        size = cfg.gtk.cursorTheme.size;
      };
      
      iconTheme.name = cfg.iconTheme;
    };

    # Qt configuration via qt5ct and qt6ct
    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = toLower cfg.style;

      # Qt5ct configuration
      qt5ctSettings = {
        Appearance = {
          style = cfg.style;
          color_scheme_path = cfg.colorSchemePath;
          custom_palette = true;
          icon_theme = cfg.iconTheme;
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          fixed = ''"${cfg.fonts.fixed}"'';
          general = ''"${cfg.fonts.general}"'';
        };
      };

      # Qt6ct configuration
      qt6ctSettings = {
        Appearance = {
          style = cfg.style;
          color_scheme_path = cfg.colorSchemePath;
          custom_palette = true;
          icon_theme = cfg.iconTheme;
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          fixed = ''"${cfg.fonts.fixed}"'';
          general = ''"${cfg.fonts.general}"'';
        };
      };
    };

    # KDE globals configuration for KDE/Qt apps
    home.file.".config/kdeglobals".text = ''
      [ColorScheme]
      ColorScheme=${cfg.colorScheme}

      [General]
      ColorScheme=${cfg.colorScheme}
      Name=${cfg.colorScheme}
      TerminalApplication=${cfg.terminal.application}
      TerminalService=${cfg.terminal.service}

      [Icons]
      Theme=${cfg.iconTheme}

      [KDE]
      LookAndFeelPackage=${cfg.lookAndFeel}
      widgetStyle=${toLower cfg.style}
    '';
  };
}
