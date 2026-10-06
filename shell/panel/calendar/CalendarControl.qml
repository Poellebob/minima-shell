import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.text
import qs

Item {
  id: root

  readonly property var cells: {
    // Explicit dependencies for the binding
    viewYear;
    viewMonth;
    weekStartSunday;
    todayYear;
    todayMonth;
    todayDay;
    selectedYear;
    selectedMonth;
    selectedDay;
    return buildCells();
  }
  readonly property int dayCellWidth: 32
  readonly property int gridWidth: weekCellWidth + 7 * dayCellWidth + 7 * Global.format.spacing_tiny
  property int selectedDay: 0
  property int selectedMonth: 0
  property int selectedYear: 0
  readonly property int todayDay: clock.date.getDate()
  readonly property int todayMonth: clock.date.getMonth()
  readonly property int todayYear: clock.date.getFullYear()
  property int viewMonth: new Date().getMonth()
  property int viewYear: new Date().getFullYear()
  readonly property int weekCellWidth: 28
  readonly property bool weekStartSunday: Global.config.calendar.weekStart === "sunday"
  readonly property var weekdayLabels: weekStartSunday ? ["", "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"] : ["", "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

  function buildCells(): var {
    const first = new Date(viewYear, viewMonth, 1);
    const startOffset = weekStartSunday ? first.getDay() : (first.getDay() + 6) % 7;
    const start = new Date(viewYear, viewMonth, 1 - startOffset);
    const result = [];

    for (let r = 0; r < 6; r++) {
      const rowStart = new Date(start.getFullYear(), start.getMonth(), start.getDate() + r * 7);
      // Mid-week day decides the week number
      const week = isoWeekNumber(new Date(rowStart.getFullYear(), rowStart.getMonth(), rowStart.getDate() + 3));
      result.push({
        "week": week
      });

      for (let c = 0; c < 7; c++) {
        const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + r * 7 + c);
        const y = d.getFullYear();
        const m = d.getMonth();
        const day = d.getDate();
        result.push({
          "year": y,
          "month": m,
          "day": day,
          "other": m !== viewMonth || y !== viewYear,
          "isToday": y === todayYear && m === todayMonth && day === todayDay,
          "isSelected": y === selectedYear && m === selectedMonth && day === selectedDay
        });
      }
    }
    return result;
  }
  function goToday(): void {
    viewYear = clock.date.getFullYear();
    viewMonth = clock.date.getMonth();
    selectedYear = viewYear;
    selectedMonth = viewMonth;
    selectedDay = clock.date.getDate();
  }
  function isoWeekNumber(d): int {
    const t = new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const day = (t.getDay() + 6) % 7;
    t.setDate(t.getDate() - day + 3);
    const firstThu = new Date(t.getFullYear(), 0, 4);
    const fday = (firstThu.getDay() + 6) % 7;
    firstThu.setDate(firstThu.getDate() - fday + 3);
    return 1 + Math.round((t.getTime() - firstThu.getTime()) / (7 * 24 * 60 * 60 * 1000));
  }
  function nextMonth(): void {
    if (viewMonth === 11) {
      viewMonth = 0;
      viewYear++;
    } else {
      viewMonth++;
    }
  }
  function pad(n): string {
    return n < 10 ? "0" + n : n.toString();
  }
  function prevMonth(): void {
    if (viewMonth === 0) {
      viewMonth = 11;
      viewYear--;
    } else {
      viewMonth--;
    }
  }
  function selectDay(cell): void {
    selectedYear = cell.year;
    selectedMonth = cell.month;
    selectedDay = cell.day;
    if (cell.other) {
      viewYear = cell.year;
      viewMonth = cell.month;
    }
  }

  implicitHeight: row.implicitHeight

  Component.onCompleted: goToday()
  onVisibleChanged: {
    if (visible)
      goToday();
  }

  SystemClock {
    id: clock

    precision: SystemClock.Seconds
  }

  RowLayout {
    id: row

    anchors.left: parent.left
    spacing: Global.format.spacing_large
    width: parent.width

    ColumnLayout {
      id: calendarBlock

      Layout.maximumWidth: root.gridWidth
      Layout.preferredWidth: root.gridWidth
      spacing: Global.format.spacing_medium

      RowLayout {
        id: header

        Layout.fillWidth: true
        spacing: Global.format.spacing_medium

        ClickableText {
          baseColor: Global.colors.on_surface_variant
          hoverColor: Global.colors.primary
          text: "‹" // replace with your icon glyph if you like

          onClicked: root.prevMonth()
        }

        StyledText {
          Layout.fillWidth: true
          color: Global.colors.on_surface
          font.bold: true
          horizontalAlignment: Text.AlignHCenter
          text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
        }

        ClickableText {
          baseColor: Global.colors.on_surface_variant
          hoverColor: Global.colors.primary
          text: "›" // replace with your icon glyph if you like

          onClicked: root.nextMonth()
        }

        ClickableText {
          baseColor: Global.colors.primary
          hoverColor: Global.colors.tertiary
          text: "Today"

          onClicked: root.goToday()
        }
      }

      GridLayout {
        id: grid

        Layout.maximumWidth: root.gridWidth
        Layout.preferredWidth: root.gridWidth
        columnSpacing: Global.format.spacing_tiny
        columns: 8
        rowSpacing: Global.format.spacing_tiny

        Repeater {
          model: root.weekdayLabels

          delegate: Item {
            required property int index
            readonly property bool isCorner: index === 0
            required property string modelData

            Layout.maximumWidth: isCorner ? root.weekCellWidth : root.dayCellWidth
            Layout.preferredHeight: Global.format.text_size + Global.format.spacing_medium
            Layout.preferredWidth: isCorner ? root.weekCellWidth : root.dayCellWidth

            StyledText {
              anchors.centerIn: parent
              color: Global.colors.outline
              font.pixelSize: Global.format.font_size_small
              text: modelData
            }
          }
        }

        Repeater {
          model: root.cells

          delegate: Item {
            id: cellItem

            required property int index
            readonly property bool isWeek: index % 8 === 0
            required property var modelData

            Layout.maximumWidth: isWeek ? root.weekCellWidth : root.dayCellWidth
            Layout.preferredHeight: 30
            Layout.preferredWidth: isWeek ? root.weekCellWidth : root.dayCellWidth

            StyledText {
              anchors.centerIn: parent
              color: Global.colors.outline
              font.pixelSize: Global.format.font_size_small
              text: cellItem.modelData.week !== undefined ? root.pad(cellItem.modelData.week) : ""
              visible: cellItem.isWeek
            }

            Item {
              anchors.fill: parent
              visible: !cellItem.isWeek

              Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                border.color: !cellItem.modelData.isToday && cellItem.modelData.isSelected ? Global.colors.primary : "transparent"
                border.width: 1
                color: cellItem.modelData.isToday ? Global.colors.primary : cellMouse.containsMouse ? Global.colors.surface_container_high : "transparent"
                radius: 0
              }

              StyledText {
                anchors.centerIn: parent
                color: cellItem.modelData.isToday ? Global.colors.on_primary : cellItem.modelData.other ? Global.colors.outline : Global.colors.on_surface
                text: cellItem.modelData.day !== undefined ? cellItem.modelData.day.toString() : ""
              }

              MouseArea {
                id: cellMouse

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: root.selectDay(cellItem.modelData)
              }
            }
          }
        }
      }
    }

    ColumnLayout {
      id: dateDisplay

      Layout.alignment: Qt.AlignVCenter
      Layout.fillWidth: true
      spacing: 0

      StyledText {
        Layout.fillWidth: true
        color: Global.colors.on_surface
        font.bold: true
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDateTime(clock.date, "dddd d MMMM yyyy")
      }

      StyledText {
        Layout.fillWidth: true
        color: Global.colors.on_surface_variant
        font.bold: true
        font.pixelSize: 30
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDateTime(clock.date, "HH:mm:ss")
      }
    }
  }
}
