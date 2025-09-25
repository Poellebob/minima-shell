import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.DBusMenu
import Qt5Compat.GraphicalEffects

MouseArea {
  id: sysTrayItem

  required property var bar
  required property SystemTrayItem item
  property bool targetMenuOpen: false
  property int trayItemWidth: panel.format.radius_xlarge

  anchors {
    verticalCenter: parent.verticalCenter
  }

  acceptedButtons: Qt.LeftButton | Qt.RightButton
  Layout.fillHeight: true
  implicitWidth: trayItemWidth

  onClicked: (event) => {
    switch (event.button) {
      case Qt.LeftButton:
        item.activate();
      break; 

      case Qt.RightButton:
        if (item.hasMenu) {
          menu.visible = !menu.visible;
          hideTimer.restart();
        }
      break;
    }
    event.accepted = true;
  }

  QsMenuOpener {
    id: menuOpen
    menu: sysTrayItem.item.menu
  }

  PopupWindow {
    id: menu
    anchor.window: bar
    anchor.rect.x: sysTrayItem.x
    anchor.rect.y: bar.implicitHeight
    anchor.edges: Edges.Top
    color: "transparent"
    implicitWidth: 200
    implicitHeight: items.height + panel.format.spacing_large + panel.format.spacing_small
    
    Timer {
      id: hideTimer
      interval: panel.format.interval_short
      running: false
      repeat: false
      onTriggered: menu.visible = false
    }

    

    MouseArea {
      id: menuMouseArea
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton  // Don't intercept mouse clicks
      propagateComposedEvents: true  // Allow child elements to receive events
      
      onEntered: hideTimer.stop()
      onExited: hideTimer.restart()

      Rectangle {
        id: rect
        color: panel.colors.dark_background
        implicitWidth: parent.width
        implicitHeight: parent.height
        bottomLeftRadius: panel.format.radius_xlarge
        bottomRightRadius: panel.format.radius_xlarge
        anchors.fill: parent
        
        ColumnLayout {
          id: items
          spacing: panel.format.radius_medium
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          
          
          Repeater {
            model: menuOpen.children
            anchors.verticalCenter: parent.verticalCenter
            
            Rectangle {
              required property QsMenuEntry modelData
              color: mouseArea.containsMouse && !modelData.isSeparator ? panel.colors.dark_surface_container_high : panel.colors.dark_surface_variant
              anchors.horizontalCenter: parent.horizontalCenter
              implicitWidth: menu.width - panel.format.spacing_large
              implicitHeight: modelData.isSeparator ? 2 : panel.format.icon_size
              radius: panel.format.radius_large
              
              // Smooth color transition
              Behavior on color {
                ColorAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
              
              Text {
                visible: !modelData.isSeparator
                anchors.fill: parent
                color: panel.colors.dark_on_background
                text: modelData.text
                anchors.left: parent.left
                anchors.leftMargin: panel.format.font_size_small
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
              }
              
              MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                
                onClicked: (event) => {
                  if (event.button == Qt.LeftButton) {
                    modelData.triggered()
                    menu.visible = false
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  IconImage {
    id: trayIcon
    visible: true
    source: sysTrayItem.item.icon
    anchors.centerIn: parent
    width: parent.width
    height: parent.height
  }
}
