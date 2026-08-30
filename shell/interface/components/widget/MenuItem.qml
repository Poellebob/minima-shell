import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text
import qs

Item {
  id: root

  property QsMenuEntry entry
  property int groupIndex: 0
  signal triggered

  property color groupColor: {
    switch (groupIndex % 3) {
    case 0:
      return Global.colors.primary;
    case 1:
      return Global.colors.secondary;
    case 2:
      return Global.colors.tertiary;
    }
  }

  implicitHeight: entry && entry.isSeparator ? 2 : Global.format.module_height
                                               + Global.format.spacing_small

  ClickableText {
    id: label
    visible: root.entry && !root.entry.isSeparator
    anchors.fill: parent
    anchors.leftMargin: Global.format.spacing_small
    anchors.rightMargin: Global.format.spacing_small
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter
    baseColor: root.entry && root.entry.enabled ? root.groupColor :
                                                  Global.colors.outline
    mouseEnabled: root.entry && !root.entry.isSeparator
    text: root.entry ? root.entry.text : ""
    elide: Text.ElideRight

    onClicked: event => {
                 if (event.button === Qt.LeftButton && root.entry) {
                   root.entry.triggered();
                   root.triggered();
                 }
               }
  }
}
