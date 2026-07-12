import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
  id: expandedPanel

  property alias content: contentContainer.children

  color: Global.colors.surface_container
  radius: Global.format.radius_medium
  clip: true

  default property alias data: contentContainer.data

  ColumnLayout {
    id: contentContainer
    anchors.fill: parent
    anchors.margins: Global.format.spacing_medium
    spacing: Global.format.spacing_small
  }

  Behavior on implicitHeight {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }
}
