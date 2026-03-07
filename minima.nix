{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./nixvim.nix
  ];

  options.minima = {
    enable = mkEnableOption "Minima shell";

    wm = mkOption {
      type = types.str;
      default = "sway";
      description = ''
        Window mamager to use with minima shell.

        Can be: 
          "sway"
          "swayfx"
          "scroll"
          "hyprland"
      '';
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

    iconTheme = mkOption {
      type = types.str;
      default = "Papirus-Dark";
      description = "Icon theme name (used by Qt, GTK, and KDE globals)";
    };

    theme = {
      name = mkOption {
        type = types.str;
        default = "Breeze";
        description = "Widget/theme style name used by both Qt and GTK (e.g. Breeze, Adwaita).";
      };

      dark = mkOption {
        type = types.bool;
        default = true;
        description = "Use dark variant. Sets prefer-dark for GTK and BreezeDark color scheme for Qt.";
      };

      colorSchemePath = mkOption {
        type = types.str;
        default = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
        description = "Color scheme file used by both qt5ct and qt6ct.";
      };

      customPalette = mkOption {
        type = types.bool;
        default = true;
        description = "Enable custom palette in qt5ct/qt6ct.";
      };
    };

    qt = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Qt theming";
      };

      lookAndFeel = mkOption {
        type = types.str;
        default = "org.kde.breezedark.desktop";
      };

      accentColor = mkOption {
        type = types.str;
        default = "232,203,45";
        description = "KDE accent color as R,G,B string";
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
      name = mkOption {
        type = types.str;
        default = "kitty";
        description = "Terminal emulator name (used to derive package and desktop service).";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.${cfg.terminal.name};
        description = "Terminal emulator package. Defaults to pkgs.<name>.";
      };

      settings = mkOption {
        type = types.attrs;
        default = {
          shell_integration      = "enabled";
          tab_title_template     = "{cwd}";
          background_opacity     = "0.8";
          font_family            = "JetBrainsMono Nerd Font";
          font_size              = "13.0";
        };
        description = "Kitty settings. Only applied when terminal name is kitty.";
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

        initContent = mkOption {
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

            character = {
              success_symbol = "[](green)";
              error_symbol = "[](red)";
            };

            git_branch = {
              style = "purple";
              symbol = "󰘬 ";
            };

            git_status.style = "purple";
            cmd_duration.disabled = false;

            aws.symbol            = "󰸏 ";
            bun.symbol            = "󰟓 ";
            c.symbol              = "󰙱 ";
            conda.symbol          = "󱔎 ";
            dart.symbol           = "󰔶 ";
            docker_context.symbol = "󰡨 ";
            elixir.symbol         = "󰘉 ";
            elm.symbol            = "󰏚 ";
            golang.symbol         = "󰟓 ";
            haskell.symbol        = "󰲒 ";
            java.symbol           = "󰬷 ";
            julia.symbol          = "󱌞 ";
            kotlin.symbol         = "󱈙 ";
            lua.symbol            = "󰢱 ";
            memory_usage.symbol   = "󰍛 ";
            nim.symbol            = "󰆥 ";
            nix_shell.symbol      = "󱄅 ";
            nodejs.symbol         = "󰎙 ";
            package.symbol        = "󰏗 ";
            php.symbol            = "󰌟 ";
            python.symbol         = "󰌠 ";
            ruby.symbol           = "󰴭 ";
            rust.symbol           = "󱘗 ";
            scala.symbol          = " ";
            swift.symbol          = "󰛥 ";
            zig.symbol            = "󱐋 ";
          };
        };
      };    
    };

    gtk = {
      enable = mkOption { type = types.bool; default = true; };
      cursorTheme = {
        name = mkOption { type = types.str; default = "BreezeX-RosePine-Linux"; };
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
      matugen
      wiremix
      bluetui
      hyprlock
      bluez
      bluez-tools
      upower
      grim
      slurp
      swappy
      xdg-utils
      cliphist
      wl-clipboard
      quickshell
      wireplumber
      jq
      bc
      power-profiles-daemon
      brightnessctl
      nerd-fonts.jetbrains-mono
      lazygit
      papirus-icon-theme
      rose-pine-cursor
      cfg.terminal.package
    ]
    ++ optionals cfg.shell.enable [ fzf zoxide git afetch ]
    ++ cfg.extraPackages;

    programs.zsh = mkIf (cfg.shell.enable && cfg.shell.zsh.enable) {
      enable = true;
      enableCompletion = cfg.shell.zsh.enableCompletion;
      autosuggestion.enable = cfg.shell.zsh.autosuggestion.enable;
      syntaxHighlighting.enable = cfg.shell.zsh.syntaxHighlighting.enable;
      initContent = ''
        eval "$(fzf --zsh)"
        eval "$(zoxide init zsh)"
        eval "$(starship init zsh)"
        ${cfg.shell.sharedShell}
        ${cfg.shell.zsh.initContent}
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

    programs.kitty = mkIf (cfg.terminal.name == "kitty") {
      enable = true;
      settings = cfg.terminal.settings;
    };

    dconf.settings = mkIf cfg.gtk.enable {
      "org/gnome/desktop/interface" = {
        color-scheme = if cfg.theme.dark then "prefer-dark" else "prefer-light";
        gtk-theme = cfg.theme.name;
        icon-theme = cfg.iconTheme;
        cursor-theme = cfg.gtk.cursorTheme.name;
        cursor-size = cfg.gtk.cursorTheme.size;
      };
    };

    home.sessionVariables = mkMerge [
      {
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        XCURSOR_THEME = cfg.gtk.cursorTheme.name;
        XCURSOR_SIZE = toString cfg.gtk.cursorTheme.size;
      }
      (mkIf cfg.enableBranding { XDG_CURRENT_DESKTOP = "minima"; })
      (mkIf cfg.enableNvidia {
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      })
      (mkIf cfg.vim.enable { EDITOR = "nvim"; })
    ];

    gtk = mkIf cfg.gtk.enable {
      enable = true;
      theme.name = cfg.theme.name;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = cfg.theme.dark;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = cfg.theme.dark;
      cursorTheme = {
        name = cfg.gtk.cursorTheme.name;
        size = cfg.gtk.cursorTheme.size;
      };
      iconTheme.name = cfg.iconTheme;
    };

    qt = mkIf cfg.qt.enable {
      enable = true;
      platformTheme.name = "qt6ct";
      style.name = toLower cfg.theme.name;
      qt6ctSettings = {
        Appearance = {
          style = cfg.theme.name;
          icon_theme = cfg.iconTheme;
          standard_dialogs = "xdgdesktopportal";
          color_scheme_path = cfg.theme.colorSchemePath;
          custom_palette = cfg.theme.customPalette;
        };
      };
      qt5ctSettings = {
        Appearance = {
          style = cfg.theme.name;
          icon_theme = cfg.iconTheme;
          standard_dialogs = "xdgdesktopportal";
          color_scheme_path = cfg.theme.colorSchemePath;
          custom_palette = cfg.theme.customPalette;
        };
      };
    };

    home.file.".config/kdeglobals".text = ''
      [General]
      AccentColor=${cfg.qt.accentColor}
      TerminalApplication=${cfg.terminal.name}
      TerminalService=${cfg.terminal.name}.desktop
      UseSystemBell=true

      [Icons]
      Theme=${cfg.iconTheme}

      [KDE]
      LookAndFeelPackage=${cfg.qt.lookAndFeel}
      widgetStyle=qt6ct-style

      [Sounds]
      Enable=false
    '';

    home.file.".config/sway/set-xft-dpi.sh" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/set-xft-dpi.sh; };
    home.file.".config/sway/config" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config; };
    home.file.".config/sway/config.d/keybinds" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/keybinds; };
    home.file.".config/sway/config.d/workspace" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/workspace; };
    home.file.".config/sway/config.d/application-behavior" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/application-behavior; };
    home.file.".config/sway/config.d/env" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/env; };
    home.file.".config/sway/config.d/input" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/input; };
    home.file.".config/sway/config.d/application-style" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/application-style; };
    home.file.".config/sway/config.d/terminal" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") {
      text = ''
        set $terminal ${cfg.terminal.name}
      '';
    };
    home.file.".config/sway/config.d/fx" = mkIf (cfg.wm == "swayfx") {
      text = ''
        # corner rounding
        corner_radius 8
        # window shadows
        shadows enable
        shadow_blur_radius 4
        shadow_color #1a1a1aee
        shadow_offset 0 2
        # blur
        blur enable
        blur_radius 4
        blur_passes 2
        for_window [app_id=".*"] blur enable
        for_window [class=".*"] blur enable
      '';
    };
    home.file.".config/scroll/set-xft-dpi.sh" = mkIf (cfg.wm == "scroll") { source = ./config/sway/set-xft-dpi.sh; };
    home.file.".config/scroll/config" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config; };
    home.file.".config/scroll/config.d/keybinds" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/keybinds; };
    home.file.".config/scroll/config.d/workspace" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/workspace; };
    home.file.".config/scroll/config.d/application-behavior" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/application-behavior; };
    home.file.".config/scroll/config.d/env" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/env; };
    home.file.".config/scroll/config.d/input" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/input; };
    home.file.".config/scroll/config.d/application-style" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/application-style; };
    home.file.".config/scroll/config.d/terminal" = mkIf (cfg.wm == "scroll") {
      text = ''
        set $terminal ${cfg.terminal.name}
      '';
    };

    home.file.".config/hypr/suspend.sh" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/suspend.sh; };
    home.file.".config/hypr/hyprland.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/hyprland.conf; };
    home.file.".config/hypr/hypridle.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/hypridle.conf; };
    home.file.".config/hypr/hyprlock.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/hyprlock.conf; };
    home.file.".config/hypr/set-xft-dpi.sh" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/set-xft-dpi.sh; };
    home.file.".config/hypr/getkeys.sh" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/getkeys.sh; };
    home.file.".config/hypr/components/input.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/input.conf; };
    home.file.".config/hypr/components/env.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/env.conf; };
    home.file.".config/hypr/components/workspace.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/workspace.conf; };
    home.file.".config/hypr/components/application-behavior.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/application-behavior.conf; };
    home.file.".config/hypr/components/application-style.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/application-style.conf; };
    home.file.".config/hypr/components/keybinds.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/keybinds.conf; };
    home.file.".config/hypr/terminal.conf" = mkIf (cfg.wm == "hyprland") {
      text = ''
        $terminal = ${cfg.terminal.name}
      '';
    };

    home.file.".config/quickshell/".source = ./config/quickshell;

    home.activation.minimaBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dir="$HOME/.config/minima"
      mkdir -p "$dir"
      mkdir -p $HOME/.config/matugen

      cp -n ${./config/matugen/config.toml} \
        $HOME/.config/matugen/config.toml

      cp -n ${./config/matugen/quickshell.template.json} \
        $HOME/.config/matugen/quickshell.template.json

      cp -n ${./defaults/quickshell.json} \
        $HOME/.config/matugen/quickshell.json

      cp -n ${./defaults/config.ini} $dir/config.ini
      cp -n ${./defaults/hypr.conf} $dir/hypr.conf
      cp -n ${./defaults/sway.conf} $dir/sway.conf

      chmod +x $HOME/.config/quickshell/scripts/sysfetch.sh

      if [ "${cfg.wm}" = "sway" ] || [ "${cfg.wm}" = "swayfx" ]; then
        chmod +x $HOME/.config/sway/set-xft-dpi.sh
      fi

      if [ "${cfg.wm}" = "scroll" ]; then
        chmod +x $HOME/.config/scroll/set-xft-dpi.sh
      fi

      if [ "${cfg.wm}" = "hyprland" ]; then
        chmod +x $HOME/.config/hypr/set-xft-dpi.sh
        chmod +x $HOME/.config/hypr/getkeys.sh
        chmod +x $HOME/.config/hypr/suspend.sh
      fi
    '';
  };
}
