//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.bar

ShellRoot {
  id: root

  readonly property bool darkTheme: true
  readonly property bool bar: true

  LazyLoader {active: bar; component: Bar {}}
}
