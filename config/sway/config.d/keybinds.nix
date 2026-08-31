{ wm, pkgs }:
let
  msgCmd = if wm == "scroll" then "scrollmsg" else "swaymsg";
  logoutTarget = if wm == "scroll" then "minimaLogout" else "minimaHome";
in ''
  # Main binds
  bindsym $mod+Return exec $terminal
  bindsym $mod+b exec $browser
  bindsym $mod+e exec $fileManager
  bindsym $mod+q kill
  bindsym $mod+space floating toggle
  bindsym $mod+f fullscreen toggle
  bindsym $mod+Shift+s sticky toggle
  bindsym $mod+Mod1+Delete exec swaylock
  bindsym $mod+Shift+c exec ${msgCmd} reload
  bindsym $mod+v exec qs -c $qs_path ipc call clipboard open
  bindsym $mod+d exec qs -c $qs_path ipc call launcher open

  ${if wm == "scroll" then ''
  bindsym $mod+Mod1+l set_size h 1.0
  bindsym $mod+Mod1+h set_size h 0.5
  bindsym $mod+Mod1+j move left nomode after
  bindsym $mod+Mod1+k move right nomode after
  bindsym --no-repeat $mod+tab scale_workspace overview
  '' else ""}

  # Screenshots
  bindsym Print exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -o -d)" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.wl-clipboard}/bin/wl-copy
  bindsym Shift+Print exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
  bindsym $mod+Print exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -o -d)" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.swappy}/bin/swappy -f -
  bindsym $mod+Shift+Print exec ${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -

  # Focus movement
  bindsym $mod+h focus left
  bindsym $mod+l focus right
  bindsym $mod+k focus up
  bindsym $mod+j focus down

  # Move windows
  bindsym $mod+Control+h move left
  bindsym $mod+Control+l move right
  bindsym $mod+Control+k move up
  bindsym $mod+Control+j move down

  # Resize windows
  bindsym $mod+Shift+h resize shrink width 100px
  bindsym $mod+Shift+l resize grow width 100px
  bindsym $mod+Shift+k resize shrink height 100px
  bindsym $mod+Shift+j resize grow height 100px

  ${if wm == "sway" || wm == "swayfx" then ''
  # Layout & Splitting
  bindsym $mod+a split toggle
  bindsym $mod+Mod1+j split v
  bindsym $mod+Mod1+k split h

  bindsym $mod+Mod1+h layout stacking
  bindsym $mod+Mod1+l layout tabbed
  bindsym $mod+Escape layout default

  bindsym $mod+Control+a focus child
  bindsym $mod+Shift+a focus parent
  '' else ""}

  ${if wm == "scroll" then ''
  # Direction
  bindsym $mod+a set_mode toggle
  '' else ""}

  # Scratchpad
  bindsym $mod+Shift+minus move scratchpad
  bindsym $mod+minus scratchpad show

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
  floating_modifier $mod normal
  bindsym --whole-window $mod+button2 kill
''
