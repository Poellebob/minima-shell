{ wm }:
let
  cfgDir = if wm == "scroll" then "~/.config/scroll" else "~/.config/sway";
  msgCmd = if wm == "scroll" then "scrollmsg" else "swaymsg";
in ''
  include ~/.config/minima/sway.conf
  include ${cfgDir}/config.d/*

  # Autostart applications
  exec awww-daemon
  exec ~/.local/bin/minima &
  exec sh -c "~/.config/hypr/getkeys.sh"
  exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  exec /usr/lib/polkit-kde-authentication-agent-1
  exec wl-paste --watch cliphist store
  exec_always --no-startup-id sh -c '${msgCmd} input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'
  exec sh -c "${cfgDir}/set-xft-dpi"
''
