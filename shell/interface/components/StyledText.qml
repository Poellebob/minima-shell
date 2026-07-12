import QtQuick
import qs

Rectangle {
  id: styledText

  property string text: ""
  property int textSize: Global.format.text_size
  property color textColor: Global.colors.on_surface_variant
  property bool bold: false

  implicitHeight: textItem.implicitHeight
  implicitWidth: textItem.implicitWidth
  color: "transparent"

  Text {
    id: textItem
    anchors.centerIn: parent
    text: styledText.text
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: styledText.textSize
    font.bold: styledText.bold
    color: styledText.textColor
  }
}
