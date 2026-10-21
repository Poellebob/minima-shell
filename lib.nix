{ lib, pkgs, ... }:

with lib;
let
  displayType = types.submodule {
    options = {
      res = mkOption {
        type = types.str;
        default = "preferred";
      };
      hz = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      position = {
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
      };
      scale = mkOption {
        type = types.float;
        default = 1.0;
      };
      workspace = mkOption {
        type = types.nullOr (types.either types.int types.str);
        default = null;
        description = "Default workspace for this display";
      };
      workspaces = mkOption {
        type = types.nullOr (types.listOf (types.either types.int types.str));
        default = null;
        description = "List of workspace numbers or ranges (e.g. [1 2 3 \"4-8\"]) to bind to this display";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Mark this display as the primary monitor (mouse spawns here)";
      };
    };
  };

  specialWorkspaceType = types.submodule {
    options = {
      keybind = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      rule = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = { };
      };
      autostart = mkOption {
        type = types.bool;
        default = false;
      };
      startCommand = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  keybindType = types.submodule {
    options = {
      exec = mkOption { type = types.str; };
      bind = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      type = mkOption {
        type = types.str;
        default = "bindsym";
        description = "Bind command type (only used by sway/scroll)";
      };
      raw = mkOption {
        type = types.bool;
        default = false;
        description = "Emit exec verbatim: raw Lua for hyprland, raw sway command for sway/scroll (skips exec_cmd / exec wrapping)";
      };
    };
  };

  keybindOption = default: description: mkOption {
    type = types.listOf types.str;
    inherit default description;
  };
in
{
  options.minima = {
    enable = mkEnableOption "Minima shell";

    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Hyprland as the window manager. Automatically disabled when sway or scroll is enabled, unless set explicitly.";
      };
      modifier = mkOption {
        type = types.str;
        default = "SUPER";
        description = "Hyprland modifier key";
      };
      layout = mkOption {
        type = types.enum [ "dwindle" "master" "scrolling" "hy3" ];
        default = "dwindle";
        description = "Hyprland layout";
      };
      extraLua = mkOption {
        type = types.lines;
        default = "";
        description = "Extra Lua appended to the generated Hyprland config";
      };
      plugins = mkOption {
        type = types.listOf (types.either types.package (types.strMatching "/.*"));
        default = [ ];
        description = "Hyprland plugins (packages or absolute paths)";
      };
    };

    sway = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Sway as the window manager";
      };
      modifier = mkOption {
        type = types.str;
        default = "Mod4";
        description = "Sway modifier key";
      };
      fx = mkOption {
        type = types.bool;
        default = false;
        description = "Use swayfx (blur, shadows)";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra sway config appended to the generated config";
      };
    };

    scroll = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Scroll as the window manager";
      };
      modifier = mkOption {
        type = types.str;
        default = "Mod4";
        description = "Scroll modifier key";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra scroll config appended to the generated config";
      };
    };

    osModule = mkOption {
      type = types.bool;
      default = false;
      internal = true;
    };

    minimaConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    swayConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    scrollConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    quickshellStoreDir = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    quickshellConfigName = mkOption {
      type = types.str;
      default = "minima";
      internal = true;
      description = ''
        Stable name the QuickShell config is registered under
        (`~/.config/quickshell/<name>`), used by the session service and by
        the keybinds to address the running shell.
      '';
    };

    hyprlandLua = mkOption {
      type = types.nullOr types.str;
      default = null;
      internal = true;
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
      internal = true;
    };
    keybinds = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Minima's built-in keybindings";
      };
      custom = mkOption {
        type = types.listOf keybindType;
        default = [ ];
        description = "Custom keybindings using common modifier names (Main, Shift, Ctrl, Alt)";
      };

      terminal = keybindOption [ "Main" "Return" ] "Open Kitty";
      window = {
        close = keybindOption [ "Main" "q" ] "Close the focused window";
        floating = keybindOption [ "Main" "space" ] "Toggle floating for the focused window";
        fullscreen = keybindOption [ "Main" "f" ] "Toggle fullscreen for the focused window";
        sticky = keybindOption [ "Main" "Shift" "s" ] "Toggle pin or sticky state for the focused window";
      };
      session = {
        lock = keybindOption [ "Main" "Alt" "Delete" ] "Open the lock screen";
        reload = keybindOption [ "Main" "Shift" "c" ] "Reload the compositor configuration";
        clipboard = keybindOption [ "Main" "v" ] "Open the clipboard manager";
        launcher = keybindOption [ "Main" "d" ] "Open the application launcher";
        logout = keybindOption [ "XF86PowerOff" ] "Open the logout menu";
      };
      focus = {
        left = keybindOption [ "Main" "h" ] "Focus the window to the left";
        right = keybindOption [ "Main" "l" ] "Focus the window to the right";
        up = keybindOption [ "Main" "k" ] "Focus the window above";
        down = keybindOption [ "Main" "j" ] "Focus the window below";
      };
      move = {
        left = keybindOption [ "Main" "Ctrl" "h" ] "Move the focused window left";
        right = keybindOption [ "Main" "Ctrl" "l" ] "Move the focused window right";
        up = keybindOption [ "Main" "Ctrl" "k" ] "Move the focused window up";
        down = keybindOption [ "Main" "Ctrl" "j" ] "Move the focused window down";
      };
      resize = {
        shrinkWidth = keybindOption [ "Main" "Shift" "h" ] "Shrink the focused window's width";
        growWidth = keybindOption [ "Main" "Shift" "l" ] "Grow the focused window's width";
        shrinkHeight = keybindOption [ "Main" "Shift" "k" ] "Shrink the focused window's height";
        growHeight = keybindOption [ "Main" "Shift" "j" ] "Grow the focused window's height";
      };
      layout = {
        toggleSplit = keybindOption [ "Main" "Shift" "a" ] "Toggle split or group orientation";
        vertical = keybindOption [ "Main" "Alt" "j" ] "Create a vertical split or group";
        horizontal = keybindOption [ "Main" "Alt" "k" ] "Create a horizontal split or group";
        stacking = keybindOption [ "Main" "Alt" "h" ] "Select stacking or tab grouping";
        tabbed = keybindOption [ "Main" "Alt" "l" ] "Select tabbed or tab grouping";
        default = keybindOption [ "Main" "Escape" ] "Restore the default layout";
      };
      tree = {
        parent = keybindOption [ "Main" "a" ] "Focus the parent container or group";
        child = keybindOption [ "Main" "Ctrl" "a" ] "Focus the child container or group";
      };
      hy3 = {
        nextTab = keybindOption [ "Main" "Tab" ] "Focus the next hy3 tab";
        previousTab = keybindOption [ "Main" "Shift" "Tab" ] "Focus the previous hy3 tab";
        equalize = keybindOption [ "Main" "Shift" "e" ] "Equalize the hy3 group";
        expand = keybindOption [ "Main" "o" ] "Expand the hy3 group";
        shrink = keybindOption [ "Main" "i" ] "Shrink the hy3 group";
        resetExpansion = keybindOption [ "Main" "p" ] "Reset hy3 group expansion";
      };
      scroll = {
        fullHeight = keybindOption [ "Main" "Alt" "l" ] "Set Scroll window height to 100 percent";
        halfHeight = keybindOption [ "Main" "Alt" "h" ] "Set Scroll window height to 50 percent";
        columnLeft = keybindOption [ "Main" "Alt" "j" ] "Move the window into the left Scroll column";
        columnRight = keybindOption [ "Main" "Alt" "k" ] "Move the window into the right Scroll column";
        overview = keybindOption [ "Main" "Tab" ] "Open the Scroll workspace overview";
        toggleDirection = keybindOption [ "Main" "Shift" "a" ] "Toggle Scroll direction mode";
      };
      scratchpad = {
        send = keybindOption [ "Main" "Shift" "minus" ] "Send the focused window to the scratchpad";
        toggle = keybindOption [ "Main" "minus" ] "Show or toggle the scratchpad";
      };
      screenshot = {
        selection = keybindOption [ "Print" ] "Capture a selected area to the clipboard";
        fullscreen = keybindOption [ "Shift" "Print" ] "Capture the full screen to the clipboard";
        editSelection = keybindOption [ "Main" "Print" ] "Capture a selected area for editing";
        editFullscreen = keybindOption [ "Main" "Shift" "Print" ] "Capture the full screen for editing";
      };
      audio = {
        volumeUp = keybindOption [ "XF86AudioRaiseVolume" ] "Raise audio volume";
        volumeDown = keybindOption [ "XF86AudioLowerVolume" ] "Lower audio volume";
        mute = keybindOption [ "XF86AudioMute" ] "Toggle audio mute";
        microphoneMute = keybindOption [ "XF86AudioMicMute" ] "Toggle microphone mute";
      };
      brightness = {
        up = keybindOption [ "XF86MonBrightnessUp" ] "Raise display brightness";
        down = keybindOption [ "XF86MonBrightnessDown" ] "Lower display brightness";
      };
      media = {
        next = keybindOption [ "XF86AudioNext" ] "Play the next media item";
        previous = keybindOption [ "XF86AudioPrev" ] "Play the previous media item";
        play = keybindOption [ "XF86AudioPlay" ] "Toggle media playback";
        pause = keybindOption [ "XF86AudioPause" ] "Toggle media playback";
      };
      mouse.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Minima's static mouse move, resize, and close bindings";
      };
    };

    terminal = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Kitty terminal";
      };
      fontSize = mkOption {
        type = types.float;
        default = 13.0;
        description = "Kitty font size";
      };
      backgroundOpacity = mkOption {
        type = types.float;
        default = 0.8;
        description = "Kitty background opacity";
      };
      shellIntegration = mkOption {
        type = types.enum [ "enabled" "disabled" "no-cursor" ];
        default = "enabled";
        description = "Kitty shell integration mode";
      };
    };

    displays = mkOption {
      type = types.attrsOf displayType;
      default = { };
      internal = true;
    };
    autostart = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    specialWorkspaces = mkOption {
      type = types.attrsOf specialWorkspaceType;
      default = { };
    };

    theming.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardcoded Minima styling (Breeze/Papirus/Rose-Pine)";
    };

    shell.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh, fzf, starship, etc.";
    };

    session = {
      systemd = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Run the Minima session (QuickShell panel and helper daemons) as
            systemd user units, started by the window manager config at
            compositor startup (right after the session environment is
            imported, so the units see a live IPC socket). Rebuilds then
            restart the shell automatically, so new config is picked up
            without relogging. When false, the window manager config execs
            the daemons directly instead.
          '';
        };
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };

    desktop = {
      xdgPortal = mkOption {
        type = types.bool;
        default = true;
        description = "Enable XDG desktop portals (kde + gtk)";
      };
    };

    tex = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable texlive";
      };
      scheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Texlive scheme name, e.g. \"scheme-full\"";
      };
      packages = mkOption {
        type = types.nullOr (types.attrsOf types.anything);
        default = null;
        description = "Extra texlive packages as an attrset";
      };
      spell = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of language codes for neovim spellfiles";
      };
    };

    darkTheme = mkOption {
      type = types.bool;
      default = true;
    };

    panel = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      alwaysVisible = mkOption {
        type = types.bool;
        default = true;
      };
    };

    calendar = {
      weekStart = mkOption {
        type = types.enum [
          "monday"
          "sunday"
        ];
        default = "monday";
        description = "First day of the week in the calendar popup";
      };
    };

    launcher = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      qalcPath = mkOption {
        type = types.str;
        default = "${pkgs.libqalculate}/bin/qalc";
      };
    };

    clipboard.enable = mkOption {
      type = types.bool;
      default = true;
    };

    wallpaper = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      engineEnabled = mkOption {
        description = "Enable wallpaper engine support";
        type = types.bool;
        default = false;
      };
      workshopPath = mkOption {
        type = types.str;
        default = "~/.steam/steam/steamapps/workshop/content/431960/";
      };
      fps = mkOption {
        type = types.int;
        default = 25;
      };
      fill = mkOption {
        type = types.bool;
        default = true;
      };
      matureContent = mkOption {
        type = types.bool;
        default = false;
      };
      volume = mkOption {
        type = types.int;
        default = 50;
      };
    };

    matugenConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    matugen = {
      sourceColor = mkOption {
        type = types.str;
        default = "#6750A4";
        description = "Seed color for matugen";
      };
      scheme = mkOption {
        type = types.str;
        default = "content";
        description = "Matugen color scheme type";
      };
      mode = mkOption {
        type = types.str;
        default = "color";
        description = "Matugen mode (color/image)";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.matugen;
        description = "Matugen package";
      };
    };
  };
}
