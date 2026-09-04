{ wm, pkgs, modifier }:
let
  msgCmd = if wm == "scroll" then "scrollmsg" else "swaymsg";
  logoutTarget = if wm == "scroll" then "minimaLogout" else "minimaHome";
in ''
  # Main binds
  bindsym ${modifier}+q kill
  bindsym ${modifier}+space floating toggle
  bindsym ${modifier}+f fullscreen toggle
  bindsym ${modifier}+Shift+s sticky toggle
  bindsym ${modifier}+Mod1+Delete exec swaylock
  bindsym ${modifier}+Shift+c exec ${msgCmd} reload
  bindsym ${modifier}+v exec qs -c $qs_path ipc call clipboard open
  bindsym ${modifier}+d exec qs -c $qs_path ipc call launcher open

  ${if wm == "scroll" then ''
  bindsym ${modifier}+Mod1+l set_size h 1.0
  bindsym ${modifier}+Mod1+h set_size h 0.5
  bindsym ${modifier}+Mod1+j move left nomode after
  bindsym ${modifier}+Mod1+k move right nomode after
  bindsym --no-repeat ${modifier}+tab scale_workspace overview
  '' else ""}

  # Screenshots
  bindsym Print exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -o -d)" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.wl-clipboard}/bin/wl-copy
  bindsym Shift+Print exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
  bindsym ${modifier}+Print exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -o -d)" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.swappy}/bin/swappy -f -
  bindsym ${modifier}+Shift+Print exec ${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -

  # Focus movement
  bindsym ${modifier}+h focus left
  bindsym ${modifier}+l focus right
  bindsym ${modifier}+k focus up
  bindsym ${modifier}+j focus down

  # Move windows
  bindsym ${modifier}+Control+h move left
  bindsym ${modifier}+Control+l move right
  bindsym ${modifier}+Control+k move up
  bindsym ${modifier}+Control+j move down

  # Resize windows
  bindsym ${modifier}+Shift+h resize shrink width 100px
  bindsym ${modifier}+Shift+l resize grow width 100px
  bindsym ${modifier}+Shift+k resize shrink height 100px
  bindsym ${modifier}+Shift+j resize grow height 100px

  ${if wm == "sway" || wm == "swayfx" then ''
  # Layout & Splitting
  bindsym ${modifier}+a split toggle
  bindsym ${modifier}+Mod1+j split v
  bindsym ${modifier}+Mod1+k split h

  bindsym ${modifier}+Mod1+h layout stacking
  bindsym ${modifier}+Mod1+l layout tabbed
  bindsym ${modifier}+Escape layout default

  bindsym ${modifier}+Control+a focus child
  bindsym ${modifier}+Shift+a focus parent
  '' else ""}

  ${if wm == "scroll" then ''
  # Direction
  bindsym ${modifier}+a set_mode toggle
  '' else ""}

  # Scratchpad
  bindsym ${modifier}+Shift+minus move scratchpad
  bindsym ${modifier}+minus scratchpad show

  # Logout
  bindsym XF86PowerOff exec qs -c $qs_path ipc call ${logoutTarget} open

  # Multimedia keys
  bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
  bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
  bindsym XF86MonBrightnessUp exec brightnessctl s 10%+
  bindsym XF86MonBrightnessDown exec brightnessctl s 10%-

  # Media player controls
  bindsym XF86AudioNext exec playerctl next
  bindsym XF86AudioPause exec playerctl play-pause
  bindsym XF86AudioPlay exec playerctl play-pause
  bindsym XF86AudioPrev exec playerctl previous

  # Mouse bindings
  floating_modifier ${modifier} normal
  bindsym --whole-window ${modifier}+button2 kill
''
