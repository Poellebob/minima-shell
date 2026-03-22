{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./nixvim.nix
    ./kdeglobals.nix
  ];

  options.minima = {
    enable = mkEnableOption "Minima shell";
    theming.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardcoded Minima styling (Breeze/Papirus/Rose-Pine)";
    };

    wm = mkOption {
      type = types.str;
      default = "sway";
      description = ''
        Window manager to use with minima shell.
        Can be: "sway", "swayfx", "scroll", "hyprland"
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

    terminal = {
      name = mkOption {
        type = types.str;
        default = "kitty";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.${cfg.terminal.name};
      };
    };

    shell.enable = mkOption {
      type = types.bool;
      default = true;
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      matugen wiremix bluetui hyprlock bluez bluez-tools upower
      grim slurp swappy swww xdg-utils cliphist wl-clipboard quickshell
      wireplumber jq bc power-profiles-daemon brightnessctl
      nerd-fonts.jetbrains-mono lazygit papirus-icon-theme
      rose-pine-cursor qt5.qtwayland qt6.qtwayland kdePackages.qt6ct 
      linux-wallpaperengine
      cfg.terminal.package
    ]
    ++ optionals cfg.shell.enable [ fzf zoxide git afetch ]
    ++ cfg.extraPackages;

    # stylix = {
    #   enable = true;
    #   autoEnable = true;
    #   polarity = "dark";
    #   base16Scheme = {
    #     variant = "dark";
    #     base00 = "1b1e20"; base01 = "232629"; base02 = "31363b"; base03 = "6a737d";
    #     base04 = "bdc3c7"; base05 = "eff0f1"; base06 = "f5f6f7"; base07 = "ffffff";
    #     base08 = "da4453"; base09 = "f67400"; base0A = "fdbc4b"; base0B = "27ae60";
    #     base0C = "16a085"; base0D = "3daee9"; base0E = "8e44ad"; base0F = "c0392b";
    #   };
    #   targets = {
    #     kitty.enable = false;
    #     nixvim.enable = false;
    #     qt = {
    #       platform = "qtct";
    #       standardDialogs = "xdgdesktopportal";
    #     };
    #     kde = {
    #       applicationStyle = "BreezeDark";
    #     };
    #   };
    # };
    
    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "breeze";
      style.package = pkgs.kdePackages.breeze;
      # qt6ctSettings = {
      #   Appearance = {
      #     style = "BreezeDark";
      #     icon_theme = "Papirus-Dark";
      #     standard_dialogs = "xdgdesktopportal";
      #     color_scheme_path = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
      #     custom_palette = "true";
      #   };
      # };
      # qt5ctSettings = {
      #   Appearance = {
      #     style = "BreezeDark";
      #     icon_theme = "Papirus-Dark";
      #     standard_dialogs = "xdgdesktopportal";
      #     color_scheme_path = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
      #     custom_palette = "true";
      #   };
      # };
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

    #programs.zellij = mkIf (cfg.shell.enable) {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

    programs.zsh = mkIf (cfg.shell.enable) {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        eval "$(starship init zsh)"
        zv() { local prev="$PWD"; z "$1" || return; nvim .; cd "$prev"; }
        ziv() { local prev="$PWD"; zi || return; nvim .; cd "$prev"; }
        alias lock='hyprlock'
        alias hibernate='systemctl hibernate'
        alias suspend='systemctl suspend'
        alias reboot='systemctl reboot'
        alias poweroff='systemctl poweroff'
        alias logout='loginctl terminate-session "$XDG_SESSION_ID"'

        alias cd=z
        alias grep='rg'
        alias find='fd'
        alias ls='eza'
        alias ll='eza -lh --git'
        alias la='eza -lah --git'
        alias tree='eza --tree'
        alias cat='bat'
        alias du='dust'
        alias df='duf'
        alias top='btop'
      '';
    };

    programs.starship = mkIf cfg.shell.enable {
      enable = true;
      settings = {
        add_newline = true;
        directory.style = "cyan";
        character = { success_symbol = "[❯](green)"; error_symbol = "[❯](red)"; };
        git_branch = { style = "purple"; symbol = "󰘬 "; };
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

    programs.kitty = mkIf (cfg.terminal.name == "kitty") {
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
        #QT_QPA_PLATFORMTHEME = "qt6ct";
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        WM = cfg.wm;
        PYTHONPATH = "${pkgs.sagetex}/lib/python/site-packages:$PYTHONPATH";
      }
      (mkIf cfg.theming.enable {
        XCURSOR_THEME = "BreezeX-RosePine-Linux";
        XCURSOR_SIZE = "24";
      })
      (mkIf cfg.enableBranding { XDG_CURRENT_DESKTOP = "minima"; })
      (mkIf cfg.enableNvidia {
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      })
      ( mkIf cfg.vim.enable { EDITOR = "nvim"; })
    ];

    xdg.configFile."kdeglobals" = mkIf cfg.theming.enable {
      text = cfg.kdeglobals;
    };

    # --- Symlinks ---
    home.file.".config/sway/set-xft-dpi.sh" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/set-xft-dpi.sh; executable = true; };
    home.file.".config/sway/config" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config; };
    home.file.".config/sway/config.d/keybinds" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/keybinds; };
    home.file.".config/sway/config.d/workspace" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/workspace; };
    home.file.".config/sway/config.d/application-behavior" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/application-behavior; };
    home.file.".config/sway/config.d/env" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/env; };
    home.file.".config/sway/config.d/input" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/input; };
    home.file.".config/sway/config.d/application-style" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/application-style; };
    home.file.".config/sway/config.d/terminal" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { text = "set $terminal ${cfg.terminal.name}"; };
    home.file.".config/sway/config.d/fx" = mkIf (cfg.wm == "swayfx") {
      text = ''
        corner_radius 8
        shadows enable
        blur enable
        for_window [app_id=".*"] blur enable
      '';
    };

    home.file.".config/scroll/set-xft-dpi.sh" = mkIf (cfg.wm == "scroll") { source = ./config/sway/set-xft-dpi.sh; executable = true; };
    home.file.".config/scroll/config" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config; };
    home.file.".config/scroll/config.d/keybinds" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/keybinds; };
    home.file.".config/scroll/config.d/workspace" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/workspace; };
    home.file.".config/scroll/config.d/application-behavior" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/application-behavior; };
    home.file.".config/scroll/config.d/env" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/env; };
    home.file.".config/scroll/config.d/input" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/input; };
    home.file.".config/scroll/config.d/application-style" = mkIf (cfg.wm == "scroll") { source = ./config/sway/config.d/application-style; };
    home.file.".config/scroll/config.d/terminal" = mkIf (cfg.wm == "scroll") { text = "set $terminal ${cfg.terminal.name}"; };

    home.file.".config/hypr/suspend.sh" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/suspend.sh; executable = true; };
    home.file.".config/hypr/hyprland.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/hyprland.conf; };
    home.file.".config/hypr/hypridle.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/hypridle.conf; };
    home.file.".config/hypr/hyprlock.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/hyprlock.conf; };
    home.file.".config/hypr/set-xft-dpi.sh" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/set-xft-dpi.sh; executable = true; };
    home.file.".config/hypr/getkeys.sh" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/getkeys.sh; executable = true; };
    home.file.".config/hypr/components/input.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/input.conf; };
    home.file.".config/hypr/components/env.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/env.conf; };
    home.file.".config/hypr/components/workspace.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/workspace.conf; };
    home.file.".config/hypr/components/application-behavior.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/application-behavior.conf; };
    home.file.".config/hypr/components/application-style.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/application-style.conf; };
    home.file.".config/hypr/components/keybinds.conf" = mkIf (cfg.wm == "hyprland") { source = ./config/hypr/components/keybinds.conf; };
    home.file.".config/hypr/terminal.conf" = mkIf (cfg.wm == "hyprland") { text = "$terminal = ${cfg.terminal.name}"; };

    home.file.".config/quickshell/".source = ./config/quickshell;
    home.file.".config/quickshell/scripts/sysfetch.sh" = { source = ./config/quickshell/scripts/sysfetch.sh; executable = true; };

    home.activation.minimaBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dir="$HOME/.config/minima"
      mkdir -p "$dir" $HOME/.config/matugen
      cp -n ${./config/matugen/config.toml} $HOME/.config/matugen/config.toml
      cp -n ${./config/matugen/quickshell.template.json} $HOME/.config/matugen/quickshell.template.json
      cp -n ${./defaults/quickshell.json} $HOME/.config/matugen/quickshell.json
      cp -n ${./defaults/config.ini} $dir/config.ini
      cp -n ${./defaults/hypr.conf} $dir/hypr.conf
      cp -n ${./defaults/sway.conf} $dir/sway.conf
    '';
  };
}
