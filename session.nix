{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.minima;

  qsConfigName = cfg.quickshellConfigName;

  # systemd Environment= quoting (systemd.syntax(7)).
  escapeSystemd = replaceStrings [ "\\" "\"" "%" "\n" "\r" "\t" ] [
    "\\\\"
    "\\\""
    "%%"
    "\\n"
    "\\r"
    "\\t"
  ];
  envLine = n: v: ''"${n}=${escapeSystemd (toString v)}"'';

  # MINIMA_QS_CONFIG pins the config store path into the unit so a QML rebuild
  # changes the unit definition and Home Manager restarts the service; without
  # it `qs -c minima` is stable across generations and would never trigger one.
  sessionEnv =
    [ (envLine "MINIMA_QS_CONFIG" cfg.quickshellStoreDir) ]
    ++ mapAttrsToList envLine config.home.sessionVariables;

  # User services get a minimal PATH, so give them the profile (and what apps
  # launched by the shell inherit).
  unitPath = concatStringsSep ":" (
    [
      "${config.home.profileDirectory}/bin"
    ]
    ++ config.home.sessionPath
    ++ [
      "/run/current-system/sw/bin"
      "/usr/local/sbin"
      "/usr/local/bin"
      "/usr/sbin"
      "/usr/bin"
      "/sbin"
      "/bin"
    ]
  );

  sessionUnit = description: {
    Unit = {
      Description = description;
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  sessionService = service: {
    Environment = sessionEnv ++ [ (envLine "PATH" unitPath) ];
    Restart = "on-failure";
    RestartSec = "2";
  }
  // service;

  # Only long-running daemons: autostart commands, special workspace apps and
  # the polkit agent are window manager execs, because systemd would restart
  # their daemonizing launchers into duplicates.
  services = {
    minima-shell = sessionUnit "Minima shell (QuickShell)" // {
      Service = sessionService {
        # The shell owns org.freedesktop.Notifications, so systemd can tell
        # when it is up and serialize restarts.
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${pkgs.quickshell}/bin/qs -c ${qsConfigName}";
        TimeoutStartSec = "90";
        TimeoutStopSec = "10";
        LimitNOFILE = "16384:infinity";
      };
    };

    minima-wallpaper = sessionUnit "Minima wallpaper daemon" // {
      Service = sessionService {
        Type = "simple";
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
      };
    };

    minima-cliphist = sessionUnit "Minima clipboard history watcher" // {
      Service = sessionService {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      };
    };
  };
in
{
  config = mkIf cfg.enable {
    xdg.configFile."quickshell/${qsConfigName}".source = cfg.quickshellStoreDir;

    # Needed for rebuilds to restart changed units; "suggest"/false defers
    # restarts to the user.
    systemd.user.startServices = mkDefault true;

    systemd.user.targets.minima-session = mkIf (cfg.session.systemd.enable && (cfg.sway.enable || cfg.scroll.enable)) {
      Unit = {
        Description = "Minima compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    systemd.user.services = mkIf cfg.session.systemd.enable services;

    # Apply the freshly written WM config to the running session. Reload only
    # re-reads binds/monitors/rules; startup hooks (hl.on("hyprland.start"),
    # sway `exec`) do not re-run, so autostarts and polkit are left alone.
    home.activation.minimaReloadWm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      export PATH="${config.home.profileDirectory}/bin:/run/current-system/sw/bin:''${PATH}"
      ${optionalString cfg.hyprland.enable ''
        # hyprctl cannot discover instances on its own; the signature is
        # imported into the user manager at compositor start.
        export HYPRLAND_INSTANCE_SIGNATURE="''${HYPRLAND_INSTANCE_SIGNATURE:-$(systemctl --user show-environment | sed -n 's/^HYPRLAND_INSTANCE_SIGNATURE=//p')}"
        $DRY_RUN_CMD hyprctl reload >/dev/null 2>&1 || true
      ''}
      ${optionalString (cfg.sway.enable && !cfg.scroll.enable) ''$DRY_RUN_CMD swaymsg reload >/dev/null 2>&1 || true''}
      ${optionalString cfg.scroll.enable ''$DRY_RUN_CMD scrollmsg reload >/dev/null 2>&1 || true''}
    '';
  };
}
