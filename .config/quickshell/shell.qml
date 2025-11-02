//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.components
import qs.bar

ShellRoot {
  LazyLoader { active: true; component: Panel {}}
}
