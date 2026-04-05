//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.bar
import qs.widgets.logout
import qs.launcher

ShellRoot {
  id: root

  LazyLoader { active: Global.settings["Panel"]["enabled"]; component: Bar{} }

  Logout { id: logout }

  Instantiator {
    model: Quickshell.screens

    delegate: LauncherOpener {
      screen: modelData
      implicitWidth: 600
    }
  }
}
