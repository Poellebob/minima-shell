import QtQuick
import qs.colors
import qs.format

Text {
  readonly property Format format: Format {}
  // TODO: The color theme is hardcoded to dark.
  // This should be made dynamic.
  readonly property Colors colors: ColorsDark {}

  color: colors.on_surface_variant
  font.pixelSize: format.text_size
}