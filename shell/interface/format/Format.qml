import QtQuick

Item {
    readonly property int icon_size: 24
    readonly property int big_icon_size: 28
    readonly property int systray_icon_size: 16

    readonly property int text_size: 13
    readonly property int module_height: 22
    readonly property int module_radius: 4
    readonly property int panel_height: 30

    readonly property int spacing_tiny: 2
    readonly property int spacing_small: 4
    readonly property int spacing_medium: 8
    readonly property int spacing_large: 12

    readonly property int radius_small: 4
    readonly property int radius_medium: 6
    readonly property int radius_large: 12
    readonly property int radius_xlarge: 16

    readonly property int font_size_small: 10
    readonly property int font_size_medium: 12
    readonly property int font_size_large: 20
    readonly property int font_size_xlarge: 22

    readonly property int interval_short: 1000
    readonly property int interval_medium: 3000
    readonly property int interval_long: 5000
    readonly property int interval_xlong: 10000

    // TUI-specific tokens
    readonly property int bar_width: 360
    readonly property int expanded_max_height: 400
    readonly property int module_min_width: 60
    readonly property int module_padding: 6
    readonly property int focus_border_width: 2
}
