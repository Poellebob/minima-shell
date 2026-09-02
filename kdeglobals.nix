{ config, lib, ... }:

with lib;
{
  options.minima.kdeglobals = mkOption { default = ''
    [ColorEffects:Disabled]
    ChangeSelectionColor=
    Color=56,56,56
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    Enable=
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=112,111,110
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=false
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=174,155,45
    BackgroundNormal=41,44,48
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=161,169,177
    ForegroundLink=232,203,45
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Complementary]
    BackgroundAlternate=30,87,116
    BackgroundNormal=32,35,38
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=161,169,177
    ForegroundLink=232,203,45
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Header]
    BackgroundAlternate=32,35,38
    BackgroundNormal=41,44,48
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=161,169,177
    ForegroundLink=232,203,45
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Header][Inactive]
    BackgroundAlternate=41,44,48
    BackgroundNormal=32,35,38
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundActive=61,174,233
    ForegroundInactive=161,169,177
    ForegroundLink=29,153,243
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Selection]
    BackgroundAlternate=168,148,38
    BackgroundNormal=168,148,38
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=0,0,0
    ForegroundLink=254,231,139
    ForegroundNegative=176,55,69
    ForegroundNeutral=198,92,0
    ForegroundNormal=0,0,0
    ForegroundPositive=23,104,57
    ForegroundVisited=155,89,182

    [Colors:Tooltip]
    BackgroundAlternate=32,35,38
    BackgroundNormal=41,44,48
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=161,169,177
    ForegroundLink=232,203,45
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:View]
    BackgroundAlternate=29,31,34
    BackgroundNormal=20,22,24
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=161,169,177
    ForegroundLink=232,203,45
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Window]
    BackgroundAlternate=41,44,48
    BackgroundNormal=32,35,38
    DecorationFocus=232,203,45
    DecorationHover=232,203,45
    ForegroundActive=232,203,45
    ForegroundInactive=161,169,177
    ForegroundLink=232,203,45
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=252,252,252
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [General]
    AccentColor=232,203,45
    LastUsedCustomAccentColor=232,203,45
    ColorScheme=BreezeDark
    UseSystemBell=true

    [Icons]
    Theme=Papirus-Dark

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
    widgetStyle=Breeze

    [KFileDialog Settings]
    Allow Expansion=false
    Automatically select filename extension=true
    Breadcrumb Navigation=false
    Decoration position=2
    Show Full Path=false
    Show Inline Previews=true
    Show Preview=false
    Show Speedbar=true
    Show hidden files=true
    Sort by=Name
    Sort directories first=true
    Sort hidden files last=false
    Sort reversed=false
    Speedbar Width=140
    View Style=DetailTree

    [Sounds]
    Enable=false

    [WM]
    activeBackground=39,44,49
    activeBlend=252,252,252
    activeForeground=252,252,252
    inactiveBackground=32,36,40
    inactiveBlend=161,169,177
    inactiveForeground=161,169,177
  ''; };
}
