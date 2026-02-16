import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
  id: root

  // Properties
  property string text: ""
  property bool enabled: true
  property string variant: "default" // "default" | "primary" | "destructive"

  signal clicked()

  // Sizing
  implicitHeight: 39
  implicitWidth: label.implicitWidth + Global.format.spacing_large * 2
  radius: Global.format.radius_large

  // Color logic per variant
  color: {
    if (!root.enabled) return Global.colors.surface_container_low

    if (variant === "primary") {
      if (mouseArea.pressed) return Global.colors.primary
      if (mouseArea.containsMouse) return Global.colors.primary_container
      return Global.colors.surface
    }

    if (variant === "destructive") {
      if (mouseArea.pressed) return Global.colors.error
      if (mouseArea.containsMouse) return Global.colors.error_container
      return Global.colors.surface
    }

    // default
    if (mouseArea.pressed) return Global.colors.surface_container_highest
    if (mouseArea.containsMouse) return Global.colors.surface_container_high
    return Global.colors.surface
  }

  opacity: root.enabled ? 1.0 : 0.5

  Behavior on color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    font.pixelSize: Global.format.text_size

    color: {
      if (variant === "primary") {
        return mouseArea.pressed ? Global.colors.on_primary : Global.colors.on_surface_variant
      }
      if (variant === "destructive") {
        return mouseArea.pressed ? Global.colors.on_error : Global.colors.on_error_container
      }
      return Global.colors.on_surface_variant
    }

    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: root.clicked()
  }
}
