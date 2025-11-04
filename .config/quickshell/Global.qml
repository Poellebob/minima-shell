pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.colors
import qs.format

Singleton {
  readonly property Colors darkColors: ColorsDark {}
  readonly property Colors lightColors: ColorsLight {}

  readonly property Colors colors: settings["Panel"]["darkTheme"] ? darkColors : lightColors
  readonly property Format format: Format {}

  FileView {
    id: confFile
    path: Quickshell.env("HOME") + "/.config/quickshell/config.ini"
    blockLoading: true
  }

  property bool darkTheme: settings["Panel"]["darkTheme"]
  property var settings: {
    const lines = confFile.text().split(/\r?\n/);
    const result = {};
    let section = null;

    function parseValue(value) {
      // normalize booleans
      if (value === "true") return true;
      if (value === "false") return false;

      // try numeric conversion
      if (!isNaN(value) && value.trim() !== "")
        return Number(value);

      // fallback to string
      return value;
    }

    for (let line of lines) {
      line = line.trim();
      if (!line || line.startsWith(";") || line.startsWith("#")) continue;

      if (line.startsWith("[") && line.endsWith("]")) {
        section = line.slice(1, -1);
        result[section] = {};
      } else {
        const [key, ...rest] = line.split("=");
        const rawValue = rest.join("=").trim();
        const value = parseValue(rawValue);

        if (section){
          result[section][key.trim()] = value;
        }
        else {
          result[key.trim()] = value;
        }
      }
    }

    return result;
  }
}
