import Quickshell
import qs

PanelWindow {
  anchors {
    left: true
    right: true
    top: Global.config.panel.top
    bottom: !Global.config.panel.top
  }

  height: Global.format.panel_height
  exclusiveZone: Global.format.panel_height

  color: Global.colors.background
}
