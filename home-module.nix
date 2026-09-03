{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.minima;
in
{
  imports = [
    ./lib.nix
    ./nixvim.nix
    ./kdeglobals.nix
    ./config.nix
  ];

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = length (filter id [
          cfg.hyprland.enable
          cfg.sway.enable
          cfg.scroll.enable
        ]) <= 1;
        message = "minima: only one window manager (hyprland, sway, scroll) can be enabled at a time";
      }
    ];

    home.packages =
      with pkgs;
      [
        matugen
        wiremix
        bluetui
        swaylock
        bluez
        bluez-tools
        upower
        curl
        grim
        slurp
        swappy
        awww
        xdg-utils
        cliphist
        wl-clipboard
        quickshell
        wireplumber
        jq
        bc
        fzf
        power-profiles-daemon
        brightnessctl
        libnotify
        nerd-fonts.jetbrains-mono
        lazygit
        papirus-icon-theme
        playerctl
        rose-pine-cursor
        qt5.qtwayland
        qt6.qtwayland
        kdePackages.qt6ct
        linux-wallpaperengine
        libqalculate
        killall
        openssh
        kdePackages.breeze
        kdePackages.breeze-gtk
        kdePackages.breeze-icons
      ]
      ++ optionals cfg.shell.enable [
        zoxide
        git
        afetch
      ]
      ++ optionals cfg.hyprland.enable [
        aquamarine
      ]
      ++ cfg.extraPackages
      ++ optionals cfg.tex.enable [
        (pkgs.texlive.combine (
          {
            ${cfg.tex.scheme} = pkgs.texlive.${cfg.tex.scheme};
          }
          // lib.optionalAttrs (cfg.tex.packages != null) cfg.tex.packages
        ))
      ];

    xdg.portal = mkIf cfg.desktop.xdgPortal {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.kdePackages.xdg-desktop-portal-kde
      ]
      ++ optionals (cfg.sway.enable || cfg.scroll.enable) [
        pkgs.xdg-desktop-portal-wlr
      ];
      config = {
        common.default = [
          "kde"
          "gtk"
        ];
      }
      // lib.optionalAttrs (cfg.sway.enable || cfg.scroll.enable) {
        minima = {
          ScreenCast = [ "wlr" ];
        };
      }
      // lib.optionalAttrs cfg.hyprland.enable {
        minima = {
          ScreenCast = [ "hyprland" ];
        };
      };
    };

    qt = mkIf cfg.theming.enable {
      enable = true;
      platformTheme.name = "kde";
      style.name = "breeze";
      style.package = pkgs.kdePackages.breeze;
    };

    gtk = mkIf cfg.theming.enable {
      enable = true;
      theme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "BreezeX-RosePine-Linux";
        package = pkgs.rose-pine-cursor;
        size = 24;
      };
    };

    programs.bat = mkIf (cfg.shell.enable) {
      enable = true;
      config = {
        pager = "never";
      };
    };

    programs.fzf = mkIf (cfg.shell.enable) {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
      defaultOptions = [ "--preview 'bat --color=always {}'" ];
    };

    programs.fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git"
        "*.bak"
      ];
    };

    programs.zoxide = mkIf (cfg.shell.enable) {
      enable = true;
      enableZshIntegration = true;
    };

    programs.ripgrep = mkIf (cfg.shell.enable) {
      enable = true;
    };

    programs.eza = mkIf (cfg.shell.enable) {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    services.ssh-agent = {
      enable = true;
    };

    programs.zsh = mkIf (cfg.shell.enable) {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        git_prompt() {
          git rev-parse --is-inside-work-tree &>/dev/null || return

          local b s
          b=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
          s=$(git status --porcelain 2>/dev/null)

          printf " %%{\e[35m%%}%s%s%%{\e[0m%%}" "$b" "$( [ -n "$s" ] && printf "*" )"
        }

        PS1='%{$( [ $? -ne 0 ] && printf "\e[31m%d\e[0m " $? )%}%{\e[36m%}%~%{\e[0m%}$(git_prompt) %{\e[90m%}›%{\e[0m%} '

        zv() { local prev="$PWD"; z "$1" || return; nvim .; cd "$prev"; }
        ziv() { local prev="$PWD"; zi || return; nvim .; cd "$prev"; }
        alias lock='swaylock'
        alias hibernate='systemctl hibernate'
        alias suspend='systemctl suspend'
        alias reboot='systemctl reboot'
        alias poweroff='systemctl poweroff'
        alias logout='loginctl terminate-session "$XDG_SESSION_ID"'

        alias cd=z
        alias ls='eza'
        alias ll='eza -lh --git'
        alias la='eza -lah --git'
        alias tree='eza --tree'
        alias du='dust'
        alias df='duf'
        alias top='btop'
        alias lg=lazygit
      '';
    };

    programs.starship = mkIf cfg.shell.enable {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        directory.style = "cyan";
        character = {
          success_symbol = "[❯](green)";
          error_symbol = "[❯](red)";
        };
        git_branch = {
          style = "purple";
          symbol = "󰘬 ";
        };
        git_status.style = "purple";
        cmd_duration.disabled = false;
        aws.symbol = "󰸏 ";
        bun.symbol = "󰟓 ";
        c.symbol = "󰙱 ";
        conda.symbol = "󱔎 ";
        dart.symbol = "󰔶 ";
        docker_context.symbol = "󰡨 ";
        elixir.symbol = "󰘉 ";
        elm.symbol = "󰏚 ";
        golang.symbol = "󰟓 ";
        haskell.symbol = "󰲒 ";
        java.symbol = "󰬷 ";
        julia.symbol = "󱌞 ";
        kotlin.symbol = "󱈙 ";
        lua.symbol = "󰢱 ";
        memory_usage.symbol = "󰍛 ";
        nim.symbol = "󰆥 ";
        nix_shell.symbol = "󱄅 ";
        nodejs.symbol = "󰎙 ";
        package.symbol = "󰏗 ";
        php.symbol = "󰌟 ";
        python.symbol = "󰌠 ";
        ruby.symbol = "󰴭 ";
        rust.symbol = "󱘗 ";
        scala.symbol = " ";
        swift.symbol = "󰛥 ";
        zig.symbol = "󱐋 ";
      };
    };

    programs.kitty = mkIf cfg.kitty.enable {
      enable = true;
      settings = {
        clear_all_shortcuts = true;
        shell_integration = "enabled";
        background_opacity = "0.8";
        font_family = "JetBrainsMono Nerd Font";
        font_size = "13.0";
      };
      keybindings = {
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
      };
    };

    home.sessionVariables = mkMerge [
      {
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland,x11";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
      }
      (mkIf cfg.theming.enable {
        XCURSOR_THEME = "BreezeX-RosePine-Linux";
        XCURSOR_SIZE = "24";
      })
      (mkIf cfg.enableNvidia {
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      })
      {
        MINIMA_CONFIG = cfg.minimaConfigFile;
        MATUGEN_CONFIG = cfg.matugenConfigFile;
      }
      (mkIf (cfg.sway.enable || cfg.scroll.enable || cfg.hyprland.enable) {
        XDG_CURRENT_DESKTOP =
          if cfg.scroll.enable then "minima:KDE:Scroll"
          else if cfg.sway.enable then
            (if cfg.sway.fx then "minima:KDE:SwayFX" else "minima:KDE:Sway")
          else "minima:KDE:Hyprland";
      })
    ];

    xdg.configFile."kdeglobals" = mkIf cfg.theming.enable {
      text = cfg.kdeglobals;
    };

    home.file.".config/sway/config" = mkIf cfg.sway.enable {
      text = "include ${cfg.swayConfigFile}";
    };

    home.file.".config/scroll/config" = mkIf cfg.scroll.enable {
      text = "include ${cfg.scrollConfigFile}";
    };

    wayland.windowManager.hyprland = mkIf cfg.hyprland.enable {
      enable = true;
      package = mkIf cfg.osModule null;
      configType = "lua";
      extraConfig = cfg.hyprlandLua;
      plugins = cfg.hyprland.plugins;
    };

    home.file.".config/qalculate/qalc.cfg".source = ./config/qalculate/qalc.cfg;

    home.activation.minimaBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.config/minima
      cp -n ${./colors.json} $HOME/.config/minima/colors.json
      chmod 644 $HOME/.config/minima/colors.json
    '';

    home.activation.downloadVimSpellfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.optionalString (cfg.tex.spell != [ ]) ''
        mkdir -p $HOME/.local/share/nvim/site/spell
        cd $HOME/.local/share/nvim/site/spell || exit 1
        ${lib.concatMapStringsSep "\n" (lang: ''
          if [[ ! -f "${lang}.utf-8.spl" ]]; then
            ${pkgs.curl}/bin/curl -fsSL -O "https://ftp.nluug.nl/pub/vim/runtime/spell/${lang}.utf-8.spl"
            ${pkgs.curl}/bin/curl -fsSL -O "https://ftp.nluug.nl/pub/vim/runtime/spell/${lang}.utf-8.sug"
          fi
        '') cfg.tex.spell}
      ''
    );
  };
}
