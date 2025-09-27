//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.bar
import qs.colors
import qs.widgets

ShellRoot {
  id: root

  readonly property bool darkTheme: true
  readonly property bool bar: true

  LazyLoader {active: bar; component: Bar{ isDarkTheme: darkTheme }}
}
