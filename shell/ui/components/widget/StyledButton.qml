import QtQuick
import QtQuick.Controls
import qs

Button {
  id: root

  property color colorDefault:  Global.colors.surface
  property color colorHovered:  Global.colors.surface_container_high
  property color colorPressed:  Global.colors.surface_container_highest
  property color colorDisabled: Global.colors.surface_container_low
  property color colorText:     Global.colors.on_surface_variant

  implicitHeight: 39
  implicitWidth: contentItem.implicitWidth + Global.format.spacing_large * 2
  opacity: enabled ? 1.0 : 0.5

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }

  background: Rectangle {
    radius: Global.format.radius_large
    color: {
      if (!root.enabled) return root.colorDisabled
      if (root.pressed) return root.colorPressed
      if (root.hovered) return root.colorHovered
      return root.colorDefault
    }
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
  }

  contentItem: Text {
    text: root.text
    font.pixelSize: Global.format.text_size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: root.colorText
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
  }
}
