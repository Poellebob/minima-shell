import QtQuick
import qs.colors
import qs.format

Rectangle {
  readonly property Format format: Format {}
  // TODO: The color theme is hardcoded to dark.
  // This should be made dynamic.
  readonly property Colors colors: ColorsDark {}

  implicitHeight: format.module_height
  color: colors.surface_variant
  radius: format.radius_small
}