import QtQuick

Canvas {
  id: root

  property color fillColor: "white"
  property string corner: "topLeft"
  property real radius: width

  onFillColorChanged: requestPaint()
  onCornerChanged: requestPaint()
  onRadiusChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    const ctx = getContext("2d")
    const w = width
    const h = height
    const r = Math.min(radius, w, h)

    ctx.clearRect(0, 0, w, h)
    ctx.fillStyle = fillColor
    ctx.beginPath()

    ctx.rect(0, 0, w, h)

    switch (corner) {
      case "bottomLeft":
        ctx.moveTo(w - r, 0)
        ctx.arc(w, 0, r, Math.PI, Math.PI / 2, true)
        ctx.lineTo(w, 0)
        break

      case "bottomRight":
        ctx.moveTo(0, r)
        ctx.arc(0, 0, r, Math.PI / 2, 0, true)
        ctx.lineTo(0, 0)
        break

      case "topLeft":
        ctx.moveTo(w, h - r)
        ctx.arc(w, h, r, -Math.PI / 2, Math.PI, true)
        ctx.lineTo(w, h)
        break

      case "topRight":
        ctx.moveTo(r, h)
        ctx.arc(0, h, r, 0, -Math.PI / 2, true)
        ctx.lineTo(0, h)
        break
    }

    ctx.fill("evenodd")
  }
}
