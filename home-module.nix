{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib.nix
    ./nixvim.nix
    ./kdeglobals.nix
    ./config.nix
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      matugen wiremix bluetui hyprlock bluez bluez-tools upower
      grim slurp swappy swww xdg-utils cliphist wl-clipboard quickshell
      wireplumber jq bc power-profiles-daemon brightnessctl libnotify inotify-tools
      nerd-fonts.jetbrains-mono lazygit papirus-icon-theme
      rose-pine-cursor qt5.qtwayland qt6.qtwayland kdePackages.qt6ct 
      linux-wallpaperengine libqalculate
      kdePackages.breeze
      kdePackages.breeze-gtk
      kdePackages.breeze-icons
      cfg.programs.terminal.package
      cfg.programs.fileManager.package
      cfg.programs.browser.package
    ]
    ++ optionals (cfg.programs.fileManager.package == pkgs.kdePackages.dolphin) [
        kdePackages.ark
        kdePackages.plasma-workspace
        kdePackages.kio
        kdePackages.kdf
        kdePackages.kio-fuse
        kdePackages.kio-extras
        kdePackages.kio-admin
        kdePackages.qtwayland
        kdePackages.plasma-integration
        kdePackages.kdegraphics-thumbnailers
        kdePackages.breeze-icons
        kdePackages.qtsvg
        kdePackages.kservice
      ]
    ++ optionals cfg.shell.enable [ fzf zoxide git afetch ]
    ++ cfg.extraPackages
    ++ optionals cfg.tex.enable [
      (pkgs.texlive.combine (
        { ${config.minima.tex.scheme} = pkgs.texlive.${config.minima.tex.scheme}; }
          // lib.optionalAttrs (config.minima.tex.packages != null) config.minima.tex.packages
      ))
    ];

    xdg.mime.enable = true;
    xdg.portal = mkIf cfg.desktop.xdgPortal {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
      config.common.default = [ "kde" "gtk" ];
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
      # gtk3.extraConfig = {
      #   gtk-application-prefer-dark-theme = 1;
      # };
      # gtk4.extraConfig = {
      #   gtk-application-prefer-dark-theme = 1;
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

    programs.zsh = mkIf (cfg.shell.enable) {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        if [[ -o interactive ]]; then
          eval "$(starship init zsh)"
        else
          git_prompt() {
            git rev-parse --is-inside-work-tree &>/dev/null || return

            local b s
            b=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
            s=$(git status --porcelain 2>/dev/null)

            printf " %%{\e[35m%%}%s%s%%{\e[0m%%}" "$b" "$( [ -n "$s" ] && printf "*" )"
          }

          PS1='%{$( [ $? -ne 0 ] && printf "\e[31m%d\e[0m " $? )%}%{\e[36m%}%~%{\e[0m%}$(git_prompt) %{\e[90m%}›%{\e[0m%} '
        fi

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
        alias lg=lazygit
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

    programs.kitty = mkIf (cfg.programs.terminal.name == "kitty") {
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
        GDK_BACKEND = "wayland,x11";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        XDG_SESSION_TYPE = "wayland";
        WM = cfg.wm;
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
    ];

    xdg.configFile."kdeglobals" = mkIf cfg.theming.enable {
      text = cfg.kdeglobals;
    };

    home.file.".config/sway/set-xft-dpi.sh" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/set-xft-dpi.sh; executable = true; };
    home.file.".config/sway/config" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config; };
    home.file.".config/sway/config.d/keybinds" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/keybinds; };
    home.file.".config/sway/config.d/workspace" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/workspace; };
    home.file.".config/sway/config.d/application-behavior" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/application-behavior; };
    home.file.".config/sway/config.d/env" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/env; };
    home.file.".config/sway/config.d/input" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/input; };
    home.file.".config/sway/config.d/application-style" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { source = ./config/sway/config.d/application-style; };
    home.file.".config/sway/config.d/terminal" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") { text = "set $terminal ${cfg.programs.terminal.name}"; };
    home.file.".config/sway/config.d/fx" = mkIf (cfg.wm == "swayfx") {
      text = ''
        corner_radius 8
        shadows enable
        blur enable
        for_window [app_id=".*"] blur enable
      '';
    };

    home.file.".config/scroll/set-xft-dpi.sh" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/set-xft-dpi.sh; executable = true; };
    home.file.".config/scroll/config" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config; };
    home.file.".config/scroll/config.d/keybinds" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config.d/keybinds; };
    home.file.".config/scroll/config.d/workspace" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config.d/workspace; };
    home.file.".config/scroll/config.d/application-behavior" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config.d/application-behavior; };
    home.file.".config/scroll/config.d/env" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config.d/env; };
    home.file.".config/scroll/config.d/input" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config.d/input; };
    home.file.".config/scroll/config.d/application-style" = mkIf (cfg.wm == "scroll") { source = ./config/scroll/config.d/application-style; };
    home.file.".config/scroll/config.d/terminal" = mkIf (cfg.wm == "scroll") { text = "set $terminal ${cfg.programs.terminal.name}"; };

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
    home.file.".config/hypr/terminal.conf" = mkIf (cfg.wm == "hyprland") { text = "$terminal = ${cfg.programs.terminal.name}"; };

    home.file.".config/quickshell/".source = ./config/quickshell;
    home.file.".config/quickshell/scripts/sysfetch.sh" = { 
      source = ./config/quickshell/scripts/sysfetch.sh; 
      executable = true; 
    };

    home.file.".local/bin/minima" = mkIf (cfg.wm != null) {
      source = ./shell/minima;
      executable = true;
    };

    home.file.".config/qalculate/qalc.cfg".source = ./config/qalculate/qalc.cfg;

    home.activation.minimaBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/.config/minima/colors
      cp -f ${./config/matugen/config.toml} $HOME/.config/minima/colors/config.toml
      cp -f ${./config/matugen/quickshell.template.json} $HOME/.config/minima/colors/quickshell.template.json
      cp -n ${./quickshell.json} $HOME/.config/minima/colors/quickshell.json
      chmod 644 $HOME/.config/minima/colors/quickshell.json
    '';
  };
}
