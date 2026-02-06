import QtQuick
import Quickshell.Io
import Quickshell

Item {
  id: themeColors

  FileView {
    id: colorFile
    path: Quickshell.env("HOME") + "/.config/quickshell/colors/colors.json"
    watchChanges: true
    blockLoading: true

    //Component.onCompleted: writeAdapter()

    onFileChanged: reload()

    JsonAdapter {
      id: json
      property JsonObject colors: JsonObject {
        property JsonObject dark: JsonObject {
          property string background: ""
          property string error: ""
          property string error_container: ""
          property string inverse_on_surface: ""
          property string inverse_primary: ""
          property string inverse_surface: ""
          property string on_background: ""
          property string on_error: ""
          property string on_error_container: ""
          property string on_primary: ""
          property string on_primary_container: ""
          property string on_primary_fixed: ""
          property string on_primary_fixed_variant: ""
          property string on_secondary: ""
          property string on_secondary_container: ""
          property string on_secondary_fixed: ""
          property string on_secondary_fixed_variant: ""
          property string on_surface: ""
          property string on_surface_variant: ""
          property string on_tertiary: ""
          property string on_tertiary_container: ""
          property string on_tertiary_fixed: ""
          property string on_tertiary_fixed_variant: ""
          property string outline: ""
          property string outline_variant: ""
          property string primary: ""
          property string primary_container: ""
          property string primary_fixed: ""
          property string primary_fixed_dim: ""
          property string scrim: ""
          property string secondary: ""
          property string secondary_container: ""
          property string secondary_fixed: ""
          property string secondary_fixed_dim: ""
          property string shadow: ""
          property string surface: ""
          property string surface_bright: ""
          property string surface_container: ""
          property string surface_container_high: ""
          property string surface_container_highest: ""
          property string surface_container_low: ""
          property string surface_container_lowest: ""
          property string surface_dim: ""
          property string surface_tint: ""
          property string surface_variant: ""
          property string tertiary: ""
          property string tertiary_container: ""
          property string tertiary_fixed: ""
          property string tertiary_fixed_dim: ""
        }

        property JsonObject light: JsonObject {
          property string background: ""
          property string error: ""
          property string error_container: ""
          property string inverse_on_surface: ""
          property string inverse_primary: ""
          property string inverse_surface: ""
          property string on_background: ""
          property string on_error: ""
          property string on_error_container: ""
          property string on_primary: ""
          property string on_primary_container: ""
          property string on_primary_fixed: ""
          property string on_primary_fixed_variant: ""
          property string on_secondary: ""
          property string on_secondary_container: ""
          property string on_secondary_fixed: ""
          property string on_secondary_fixed_variant: ""
          property string on_surface: ""
          property string on_surface_variant: ""
          property string on_tertiary: ""
          property string on_tertiary_container: ""
          property string on_tertiary_fixed: ""
          property string on_tertiary_fixed_variant: ""
          property string outline: ""
          property string outline_variant: ""
          property string primary: ""
          property string primary_container: ""
          property string primary_fixed: ""
          property string primary_fixed_dim: ""
          property string scrim: ""
          property string secondary: ""
          property string secondary_container: ""
          property string secondary_fixed: ""
          property string secondary_fixed_dim: ""
          property string shadow: ""
          property string source_color: ""
          property string surface: ""
          property string surface_bright: ""
          property string surface_container: ""
          property string surface_container_high: ""
          property string surface_container_highest: ""
          property string surface_container_low: ""
          property string surface_container_lowest: ""
          property string surface_dim: ""
          property string surface_tint: ""
          property string surface_variant: ""
          property string tertiary: ""
          property string tertiary_container: ""
          property string tertiary_fixed: ""
          property string tertiary_fixed_dim: ""
        }
      }
    }
  }

  // Expose actual Colors bindings
  readonly property Colors dark: Colors {
    background: json.colors.dark.background
    error: json.colors.dark.error
    error_container: json.colors.dark.error_container
    inverse_on_surface: json.colors.dark.inverse_on_surface
    inverse_primary: json.colors.dark.inverse_primary
    inverse_surface: json.colors.dark.inverse_surface
    on_background: json.colors.dark.on_background
    on_error: json.colors.dark.on_error
    on_error_container: json.colors.dark.on_error_container
    on_primary: json.colors.dark.on_primary
    on_primary_container: json.colors.dark.on_primary_container
    on_primary_fixed: json.colors.dark.on_primary_fixed
    on_primary_fixed_variant: json.colors.dark.on_primary_fixed_variant
    on_secondary: json.colors.dark.on_secondary
    on_secondary_container: json.colors.dark.on_secondary_container
    on_secondary_fixed: json.colors.dark.on_secondary_fixed
    on_secondary_fixed_variant: json.colors.dark.on_secondary_fixed_variant
    on_surface: json.colors.dark.on_surface
    on_surface_variant: json.colors.dark.on_surface_variant
    on_tertiary: json.colors.dark.on_tertiary
    on_tertiary_container: json.colors.dark.on_tertiary_container
    on_tertiary_fixed: json.colors.dark.on_tertiary_fixed
    on_tertiary_fixed_variant: json.colors.dark.on_tertiary_fixed_variant
    outline: json.colors.dark.outline
    outline_variant: json.colors.dark.outline_variant
    primary: json.colors.dark.primary
    primary_container: json.colors.dark.primary_container
    primary_fixed: json.colors.dark.primary_fixed
    primary_fixed_dim: json.colors.dark.primary_fixed_dim
    scrim: json.colors.dark.scrim
    secondary: json.colors.dark.secondary
    secondary_container: json.colors.dark.secondary_container
    secondary_fixed: json.colors.dark.secondary_fixed
    secondary_fixed_dim: json.colors.dark.secondary_fixed_dim
    shadow: json.colors.dark.shadow
    surface: json.colors.dark.surface
    surface_bright: json.colors.dark.surface_bright
    surface_container: json.colors.dark.surface_container
    surface_container_high: json.colors.dark.surface_container_high
    surface_container_highest: json.colors.dark.surface_container_highest
    surface_container_low: json.colors.dark.surface_container_low
    surface_container_lowest: json.colors.dark.surface_container_lowest
    surface_dim: json.colors.dark.surface_dim
    surface_tint: json.colors.dark.surface_tint
    surface_variant: json.colors.dark.surface_variant
    tertiary: json.colors.dark.tertiary
    tertiary_container: json.colors.dark.tertiary_container
    tertiary_fixed: json.colors.dark.tertiary_fixed
    tertiary_fixed_dim: json.colors.dark.tertiary_fixed_dim
  }

  readonly property Colors light: Colors {
    background: json.colors.light.background
    error: json.colors.light.error
    error_container: json.colors.light.error_container
    inverse_on_surface: json.colors.light.inverse_on_surface
    inverse_primary: json.colors.light.inverse_primary
    inverse_surface: json.colors.light.inverse_surface
    on_background: json.colors.light.on_background
    on_error: json.colors.light.on_error
    on_error_container: json.colors.light.on_error_container
    on_primary: json.colors.light.on_primary
    on_primary_container: json.colors.light.on_primary_container
    on_primary_fixed: json.colors.light.on_primary_fixed
    on_primary_fixed_variant: json.colors.light.on_primary_fixed_variant
    on_secondary: json.colors.light.on_secondary
    on_secondary_container: json.colors.light.on_secondary_container
    on_secondary_fixed: json.colors.light.on_secondary_fixed
    on_secondary_fixed_variant: json.colors.light.on_secondary_fixed_variant
    on_surface: json.colors.light.on_surface
    on_surface_variant: json.colors.light.on_surface_variant
    on_tertiary: json.colors.light.on_tertiary
    on_tertiary_container: json.colors.light.on_tertiary_container
    on_tertiary_fixed: json.colors.light.on_tertiary_fixed
    on_tertiary_fixed_variant: json.colors.light.on_tertiary_fixed_variant
    outline: json.colors.light.outline
    outline_variant: json.colors.light.outline_variant
    primary: json.colors.light.primary
    primary_container: json.colors.light.primary_container
    primary_fixed: json.colors.light.primary_fixed
    primary_fixed_dim: json.colors.light.primary_fixed_dim
    scrim: json.colors.light.scrim
    secondary: json.colors.light.secondary
    secondary_container: json.colors.light.secondary_container
    secondary_fixed: json.colors.light.secondary_fixed
    secondary_fixed_dim: json.colors.light.secondary_fixed_dim
    shadow: json.colors.light.shadow
    surface: json.colors.light.surface
    surface_bright: json.colors.light.surface_bright
    surface_container: json.colors.light.surface_container
    surface_container_high: json.colors.light.surface_container_high
    surface_container_highest: json.colors.light.surface_container_highest
    surface_container_low: json.colors.light.surface_container_low
    surface_container_lowest: json.colors.light.surface_container_lowest
    surface_dim: json.colors.light.surface_dim
    surface_tint: json.colors.light.surface_tint
    surface_variant: json.colors.light.surface_variant
    tertiary: json.colors.light.tertiary
    tertiary_container: json.colors.light.tertiary_container
    tertiary_fixed: json.colors.light.tertiary_fixed
    tertiary_fixed_dim: json.colors.light.tertiary_fixed_dim
    source_color: json.colors.light.source_color
  }
}
