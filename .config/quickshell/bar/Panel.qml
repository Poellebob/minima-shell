import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.widgets.centerMenu
import qs.widgets.audio
import qs

PanelWindow {
  id: panel
  implicitHeight: Global.format.panel_height
  aboveWindows: true
  focusable: WlrKeyboardFocus.OnDemand

  anchors {
    top: true
    left: true
    right: true
  }

  Rectangle {
    anchors.fill: parent
    color: Global.colors.surface
    
    RowLayout {
      id: itemsLeft
      anchors {
        left: parent.left
        leftMargin: Global.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: Global.format.spacing_medium
      
      Systray { Layout.alignment: Qt.AlignVCenter }
    }
    
    Item {
      id: itemsCenterWrapper
      anchors.centerIn: parent
      implicitWidth: itemsCenter.implicitWidth
      implicitHeight: itemsCenter.implicitHeight

      MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.RightButton

        onClicked: (event) => {
          if (event.button === Qt.RightButton)
            centerMenu.visible = !centerMenu.visible
        }

        RowLayout {
          id: itemsCenter
          anchors.centerIn: parent
          spacing: Global.format.spacing_medium

          Audio { Layout.alignment: Qt.AlignVCenter }
          Battery { Layout.alignment: Qt.AlignVCenter }
          Bluetooth { Layout.alignment: Qt.AlignVCenter }
          Network { Layout.alignment: Qt.AlignVCenter }
          Clock { Layout.alignment: Qt.AlignVCenter }
        }
      }
    }

    
    RowLayout {
      id: itemsRight
      anchors {
        right: parent.right
        rightMargin: Global.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: Global.format.spacing_medium
      
      Pager { Layout.alignment: Qt.AlignVCenter }
    }
  }
  
  CenterMenu {
    id: centerMenu
    window: panel
  }
}
