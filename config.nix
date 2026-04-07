{ config, lib, ... }:

with lib;
let
  cfg = config.minima;

  displayType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        default = "";
        description = "Output name. Empty string means all outputs (hyprland) or '*' (sway).";
        example = "DP-1";
      };
      res = mkOption {
        type = types.str;
        default = "preferred";
        description = "Resolution string, e.g. '1920x1080'. Use 'preferred' to let the compositor decide.";
      };
      hz = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Refresh rate in Hz. null means auto.";
        example = 144;
      };
      position = {
        x = mkOption { type = types.int; default = 0; };
        y = mkOption { type = types.int; default = 0; };
      };
      scale = mkOption {
        type = types.float;
        default = 1.0;
      };
    };
  };

  workspaceOutputType = types.submodule {
    options = {
      workspace = mkOption {
        type = types.str;
        description = "Workspace number or name";
        example = "1";
      };
      output = mkOption {
        type = types.str;
        example = "DP-1";
      };
    };
  };

  specialWorkspaceType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Workspace name, used as both the variable and the workspace identifier.";
        example = "discord";
      };
      key = mkOption {
        type = types.str;
        description = "Key to bind (combined with modifier) for moving this workspace to the current output.";
        example = "m";
      };
      rule = mkOption {
        type = types.str;
        description = "Sway assign/for_window criteria string, e.g. 'app_id=\"discord\"'.";
        example = ''app_id="discord|WebCord"'';
      };
      autostart = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to autostart this app.";
      };
      startCommand = mkOption {
        type = types.str;
        default = "";
        description = "Command to run on autostart. Only used when autostart = true.";
        example = "flatpak run com.discordapp.Discord";
      };
    };
  };

  hyprMonitorLine = d:
    let
      resHz = if d.hz != null
        then "${d.res}@${toString d.hz}"
        else d.res;
      pos = if d.res == "preferred"
        then "auto"
        else "${toString d.position.x}x${toString d.position.y}";
    in
      "monitor = ${d.name},${resHz},${pos},${toString d.scale}";

  swayOutputBlock = d:
    let
      outputName = if d.name == "" then "*" else d.name;
    in ''
      output ${outputName} {
        res ${d.res}
        position ${toString d.position.x} ${toString d.position.y}
        scale ${toString d.scale}
      }'';

  swaySpecialWs = ws: ''
    set $ws_${ws.name} "${ws.name}"
    ${optionalString ws.autostart "exec ${ws.startCommand}"}
    assign [${ws.rule}] workspace $ws_${ws.name}
    for_window [${ws.rule}] set_size h 1.0
    bindsym ${cfg.modifier}+${ws.key} [workspace=$ws_${ws.name}] move workspace to output current, workspace $ws_${ws.name}
  '';

  boolStr = b: if b then "true" else "false";

in {
  options.minima = {
    modifier = mkOption {
      type = types.str;
      default = "Mod4";
      description = "Main modifier key (Mod4 = Super/Windows).";
    };

    apps = {
      fileManager = mkOption {
        type = types.str;
        default = "dolphin";
      };
      browser = mkOption {
        type = types.str;
        default = "zen-browser";
      };
    };

    hypr.layout = mkOption {
      type = types.enum [ "dwindle" "master" ];
      default = "dwindle";
    };

    displays = mkOption {
      type = types.listOf displayType;
      default = [];
      description = "Monitor/output configurations shared between compositors.";
      example = literalExpression ''
        [
          {
            name = "DP-1";
            res = "1920x1080";
            position = { x = 0; y = 0; };
            scale = 1.0;
          }
          {
            name = "HDMI-A-1";
            res = "1920x1080";
            position = { x = -1920; y = 0; };
            scale = 1.0;
          }
        ]
      '';
    };

    workspaceOutputs = mkOption {
      type = types.listOf workspaceOutputType;
      default = [];
      description = "Assigns workspaces to specific outputs.";
      example = literalExpression ''
        [
          { workspace = "1"; output = "DP-1"; }
          { workspace = "10"; output = "HDMI-A-1"; }
        ]
      '';
    };

    autostart = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Commands to run on compositor startup (exec/exec-once).";
      example = [ "spotify" "flatpak run com.discordapp.Discord" ];
    };

    specialWorkspaces = mkOption {
      type = types.listOf specialWorkspaceType;
      default = [];
      description = "Named workspaces with optional autostart and keybinds.";
      example = literalExpression ''
        [
          {
            name = "discord";
            key = "m";
            rule = "app_id=\"discord|WebCord\"";
            autostart = true;
            startCommand = "flatpak run com.discordapp.Discord";
          }
        ]
      '';
    };

    minimaConfig = {
      darkTheme = mkOption {
        type = types.bool;
        default = true;
      };

      panel = {
        enable = mkOption { type = types.bool; default = true; };
        alwaysVisible = mkOption { type = types.bool; default = true; };
      };

      launcher = {
        enable = mkOption { type = types.bool; default = true; };
        mathEnabled = mkOption { type = types.bool; default = true; };
        mathjsPath = mkOption { type = types.str; default = "mathjs"; };
      };

      clipboard = {
        enable = mkOption { type = types.bool; default = true; };
      };

      wallpaper = {
        enable = mkOption { type = types.bool; default = true; };
        engineEnabled = mkOption { type = types.bool; default = false; };
        enginePath = mkOption {
          type = types.str;
          default = "/home/${config.home.username}/.nix-profile/bin/linux-wallpaperengine";
        };
        workshopPath = mkOption {
          type = types.str;
          default = "~/.steam/steam/steamapps/workshop/content/431960/";
        };
        fps = mkOption { type = types.int; default = 25; };
        fill = mkOption { type = types.bool; default = true; };
        matureContent = mkOption { type = types.bool; default = false; };
      };
    };
  };

  config = mkIf cfg.enable {

    home.file.".config/minima/hypr.conf" = mkIf (cfg.wm == "hyprland") {
      text = ''
        $mainMod = ${cfg.modifier}
        $terminal = ${cfg.terminal.name}
        $fileManager = ${cfg.apps.fileManager}
        $browser = ${cfg.apps.browser}
        $layout = ${cfg.hypr.layout}

        ${concatMapStringsSep "\n" hyprMonitorLine cfg.displays}
      '';
    };

    home.file.".config/minima/sway.conf" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx" || cfg.wm == "scroll") {
      text = ''
        set $mod ${cfg.modifier}
        set $fileManager ${cfg.apps.fileManager}
        set $browser ${cfg.apps.browser}

        # display definitions
        ${concatMapStringsSep "\n" swayOutputBlock cfg.displays}

        # workspace → output assignments
        ${concatMapStringsSep "\n" (w: "workspace ${w.workspace} output ${w.output}") cfg.workspaceOutputs}

        # autostart
        ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

        # special workspaces
        ${concatMapStringsSep "\n" swaySpecialWs cfg.specialWorkspaces}
      '';
    };

    home.file.".config/minima/config.ini" = {
      text = ''
        [Theme]
        darkTheme = ${boolStr cfg.minimaConfig.darkTheme}

        [Panel]
        enabled = ${boolStr cfg.minimaConfig.panel.enable}
        panelAlwaysVisible = ${boolStr cfg.minimaConfig.panel.alwaysVisible}

        [Launcher]
        enabled = ${boolStr cfg.minimaConfig.launcher.enable}
        mathEnabled = ${boolStr cfg.minimaConfig.launcher.mathEnabled}
        mathjsPath = ${cfg.minimaConfig.launcher.mathjsPath}

        [Clipboard]
        enabled = ${boolStr cfg.minimaConfig.clipboard.enable}

        [Wallpaper]
        enabled = ${boolStr cfg.minimaConfig.wallpaper.enable}
        engineEnabled = ${boolStr cfg.minimaConfig.wallpaper.engineEnabled}
        enginePath = ${cfg.minimaConfig.wallpaper.enginePath}
        workshopPath = ${cfg.minimaConfig.wallpaper.workshopPath}
        fps = ${toString cfg.minimaConfig.wallpaper.fps}
        fill = ${boolStr cfg.minimaConfig.wallpaper.fill}
        matureContent = ${boolStr cfg.minimaConfig.wallpaper.matureContent}
      '';
    };

  };
}
