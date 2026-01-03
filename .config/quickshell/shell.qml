//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.bar
import qs.launcher

ShellRoot {
  id: root

  readonly property bool darkTheme: true
  readonly property bool bar: true

  LazyLoader { active: bar; component: Bar{} }
  LazyLoader { active: true; component: Launcher{} }
}
