-- Environment
hl.env("XCURSOR_THEME", "BreezeX-RosePine-Linux")
hl.env("XCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment GTK_THEME QT_QPA_PLATFORMTHEME")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark")
end)
