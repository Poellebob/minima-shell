import QtQuick
import QtQuick.Shapes

Shape {
  id: root

  property color color: "#5294e2"
  property real corner: 0.5
  property bool flipH: false
  property bool flipV: false

  transform: Scale {
    xScale: root.flipH ? -1 : 1
    yScale: root.flipV ? -1 : 1
    origin.x: root.width / 2
    origin.y: root.height / 2
  }

  ShapePath {
    fillColor: root.color
    strokeColor: "transparent"
    strokeWidth: 0

    startX: 0; startY: 0

    PathLine { x: root.width;              y: 0 }
    PathLine { x: root.width;              y: root.height * (1 - root.corner) }
    PathLine { x: root.width * root.corner; y: root.height * (1 - root.corner) }
    PathLine { x: root.width * root.corner; y: root.height }
    PathLine { x: 0;                        y: root.height }
    PathLine { x: 0;                        y: 0 }
  }
}
