import Quickshell
import QtQuick
import QtQml

Base {
  Rectangle { 
    id: rect
    anchors.fill: parent
  }
  property alias color: rect.color
  property alias anchors: rect.anchors

}
