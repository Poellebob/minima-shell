import QtQuick
import Quickshell
import qs.colors
import qs.format

Item {
  property darktheme: {
    const palette = Qt.application.palette
    const baseLightness = palette.window.color.lightness()
    const textLightness = palette.text.color.lightness()

    const prefersDark = baseLightness < textLightness
    console.log(prefersDark ? "dark" : "light")
    return prefersDark
  }
}
