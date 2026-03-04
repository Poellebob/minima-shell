{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.minima;
in
{
  options.minima = {
    enable = mkEnableOption "Minima shell";

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

    iconTheme = mkOption {
      type = types.str;
      default = "Papirus-Dark";
      description = "Icon theme name (used by both Qt and GTK)";
    };
    
    qt = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable QT theming";
      };

      colorScheme = mkOption {
        type = types.str;
        default = "BreezeDark";
      };

      colorSchemePath = mkOption {
        type = types.str;
        default = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
      };

      style = mkOption {
        type = types.str;
        default = "Breeze";
      };

      lookAndFeel = mkOption {
        type = types.str;
        default = "org.kde.breezedark.desktop";
      };

      fonts = {
        general = mkOption {
          type = types.str;
          default = "Sans Serif,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        };
        fixed = mkOption {
          type = types.str;
          default = "monospace,9,-1,2,400,0,0,0,0,0,0,0,0,0,0,1";
        };
      };
    };

    terminal = {
      package = mkOption {
        type = types.package;
        default = pkgs.kitty;
      };
      application = mkOption {
        type = types.str;
        default = "kitty";
      };
      service = mkOption {
        type = types.str;
        default = "kitty.desktop";
      };
    };

    shell = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Shell theming";
      };

      sharedShell = mkOption {
        type = types.lines;
        default = ''
          zv() {
            local prev="$PWD"
            z "$1" || return
            nvim .
            cd "$prev"
          }

          ziv() {
            local prev="$PWD"
            zi || return
            nvim .
            cd "$prev"
          }

          alias lock='hyprlock'
          alias hibernate='systemctl hibernate'
          alias suspend='systemctl suspend'
          alias reboot='systemctl reboot'
          alias poweroff='systemctl poweroff'
          alias logout='loginctl terminate-session "$XDG_SESSION_ID"'
        '';
      };

      zsh = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };

        enableCompletion = mkOption { 
          type = types.bool; 
          default = true; 
        };

        autosuggestion.enable = mkOption { 
          type = types.bool; 
          default = true; 
        };

        syntaxHighlighting.enable = mkOption { 
          type = types.bool; 
          default = true; 
        };

        initExtra = mkOption { 
          type = types.lines; 
          default = ""; 
        };
      };

      bash = {
        enable = mkOption { 
          type = types.bool; 
          default = false; 
        };

        shellAliases = mkOption {
          type = types.attrsOf types.str;
          default = {
            ls = "ls --color=auto";
            grep = "grep --color=auto";
            fgrep = "fgrep --color=auto";
            egrep = "egrep --color=auto";
          };
        };
      };

      starship = {
        enable = mkOption { type = types.bool; default = true; };
        settings = mkOption {
          type = types.attrs;
          default = {
            add_newline = true;
            directory.style = "cyan";
            character.success_symbol = "›";
            character.error_symbol = "[›](red)";
            git_branch.style = "purple";
            git_status.style = "purple";
            cmd_duration.disabled = false;
          };
        };
      };
    };

    gtk = {
      enable = mkOption { type = types.bool; default = true; };
      themeName = mkOption { type = types.str; default = "Breeze-dark"; };
      colorScheme = mkOption {
        type = types.enum [ "default" "prefer-dark" "prefer-light" ];
        default = "prefer-dark";
      };
      cursorTheme = {
        name = mkOption { type = types.str; default = "breeze_cursors"; };
        size = mkOption { type = types.int; default = 24; };
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.breeze
      papirus-icon-theme
      cfg.terminal.package
    ]
    ++ optionals cfg.shell.enable [ fzf zoxide neovim git afetch ]
    ++ cfg.extraPackages;

    # --- SHELL CONFIGURATION (This generates .zshrc and .bashrc) ---
    programs.zsh = mkIf (cfg.shell.enable && cfg.shell.zsh.enable) {
      enable = true;
      enableCompletion = cfg.shell.zsh.enableCompletion;
      autosuggestion.enable = cfg.shell.zsh.autosuggestion.enable;
      syntaxHighlighting.enable = cfg.shell.zsh.syntaxHighlighting.enable;
      initExtra = ''
        eval "$(fzf --zsh)"
        eval "$(zoxide init zsh)"
        eval "$(starship init zsh)"
        ${cfg.shell.sharedShell}
        ${cfg.shell.zsh.initExtra}
      '';
    };

    programs.bash = mkIf (cfg.shell.enable && cfg.shell.bash.enable) {
      enable = true;
      shellAliases = cfg.shell.bash.shellAliases;
      initExtra = ''
        eval "$(fzf --bash)"
        eval "$(zoxide init bash)"
        eval "$(starship init bash)"
        ${cfg.shell.sharedShell}
      '';
    };

    programs.starship = mkIf (cfg.shell.enable && cfg.shell.starship.enable) {
      enable = true;
      settings = cfg.shell.starship.settings;
    };

    # --- ENVIRONMENT VARIABLES ---
    home.sessionVariables = mkMerge [
      {
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        GTK_THEME = cfg.gtk.themeName;
        XCURSOR_THEME = cfg.gtk.cursorTheme.name;
        XCURSOR_SIZE = toString cfg.gtk.cursorTheme.size;
      }
      (mkIf cfg.enableBranding { XDG_CURRENT_DESKTOP = "minima"; })
      (mkIf cfg.enableNvidia {
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      })
    ];

    gtk = mkIf cfg.gtk.enable {
      enable = true;
      theme.name = cfg.gtk.themeName;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = cfg.gtk.colorScheme == "prefer-dark";
      gtk4.extraConfig.gtk-application-prefer-dark-theme = cfg.gtk.colorScheme == "prefer-dark";
      cursorTheme = {
        name = cfg.gtk.cursorTheme.name;
        size = cfg.gtk.cursorTheme.size;
      };
      iconTheme.name = cfg.iconTheme;
    };

    qt = mkIf cfg.qt.enable {
      enable = true;
      platformTheme.name = "qtct";
      style.name = toLower cfg.qt.style;
    };

    # qtct settings (Requires home.file or direct qtct config)
    xdg.configFile."qt5ct/qt5ct.conf".text = mkIf cfg.qt.enable (generators.toINI {} {
      Appearance = {
        style = cfg.qt.style;
        color_scheme_path = cfg.qt.colorSchemePath;
        custom_palette = true;
        icon_theme = cfg.iconTheme;
        standard_dialogs = "xdgdesktopportal";
      };
      Fonts = {
        fixed = cfg.qt.fonts.fixed;
        general = cfg.qt.fonts.general;
      };
    });

    xdg.configFile."qt6ct/qt6ct.conf".text = mkIf cfg.qt.enable (generators.toINI {} {
      Appearance = {
        style = cfg.qt.style;
        color_scheme_path = cfg.qt.colorSchemePath;
        custom_palette = true;
        icon_theme = cfg.iconTheme;
        standard_dialogs = "xdgdesktopportal";
      };
      Fonts = {
        fixed = cfg.qt.fonts.fixed;
        general = cfg.qt.fonts.general;
      };
    });

    home.file.".config/kdeglobals".text = ''
      [ColorScheme]
      ColorScheme=${cfg.qt.colorScheme}

      [General]
      ColorScheme=${cfg.qt.colorScheme}
      Name=${cfg.qt.colorScheme}
      TerminalApplication=${cfg.terminal.application}
      TerminalService=${cfg.terminal.service}

      [Icons]
      Theme=${cfg.iconTheme}

      [KDE]
      LookAndFeelPackage=${cfg.qt.lookAndFeel}
      widgetStyle=${toLower cfg.qt.style}
    '';
  };
}
