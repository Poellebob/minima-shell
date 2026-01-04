//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.bar
import qs.launcher

ShellRoot {
  id: root

  LazyLoader { active: Global.settings["Panel"]["enabled"]; component: Bar{} }
  LazyLoader { active: Global.settings["Launcher"]["enabled"]; component: Launcher{} }
  LazyLoader { active: Global.settings["Clipboard"]["enabled"]; 
    component: ClipboardManager{ 
      id: clipboardManager 
      Component.onCompleted: Global.clipboardManager = clipboardManager
    }
  }
  LazyLoader { 
    active: Global.settings["Wallpaper"]["enabled"]; 
    component: WallpaperSelector{ 
      id: wallpaperSelector 
      Component.onCompleted: Global.wallpaperSelector = wallpaperSelector
    }
  }
}
