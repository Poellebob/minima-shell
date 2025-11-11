import QtQuick
import QtQuick.Layouts
import qs
import Quickshell
import Quickshell.Widgets
import qs.components.text

Rectangle {
  id: tabRoot

  property bool isSelected: false
  property string iconSource: ""
  property string text: ""

  signal clicked() 

  implicitHeight: Global.format.big_icon_size + Global.format.radius_small
  Layout.fillWidth: true
  radius: Global.format.radius_large
  color: isSelected ? Global.colors.surface : (mouseArea.containsMouse ? Global.colors.surface : Global.colors.surface_variant)

  Behavior on color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }

  Item {
    anchors.centerIn: parent
    width: text ? implicitWidth : Global.format.big_icon_size
    height: text ? implicitHeight : Global.format.big_icon_size

    IconImage {
      id: icon
      anchors.centerIn: parent
      width: Global.format.big_icon_size
      height: Global.format.big_icon_size
      source: tabRoot.iconSource
      visible: tabRoot.iconSource !== ""
    }

    StyledText {
        visible: tabRoot.text !== ""
        anchors.fill: parent
        color: Global.colors.on_background
        text: tabRoot.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
  }


  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true

    onClicked: {
      tabRoot.clicked()
    }
  }
}
