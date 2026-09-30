import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.text
import qs

Item {
  id: root

  implicitHeight: row.implicitHeight

  readonly property bool weekStartSunday: Global.config.calendar.weekStart === "sunday"

  property int viewYear: 0
  property int viewMonth: 0
  property int selectedYear: 0
  property int selectedMonth: 0
  property int selectedDay: 0

  readonly property string todayKey: Qt.formatDate(clock.date, "yyyy-MM-dd")

  readonly property int weekCellWidth: 28
  readonly property int dayCellWidth: 32
  readonly property int gridWidth: weekCellWidth + 7 * dayCellWidth + 7
                                  * Global.format.spacing_tiny

  readonly property var weekdayLabels: weekStartSunday ? ["", "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"] : ["", "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

  readonly property var cells: {
    viewYear;
    viewMonth;
    weekStartSunday;
    todayKey;
    selectedYear;
    selectedMonth;
    selectedDay;
    return buildCells();
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  function pad(n): string {
    return n < 10 ? "0" + n : n.toString();
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

  function buildCells(): var {
    const today = clock.date;
    const first = new Date(viewYear, viewMonth, 1);
    const startOffset = weekStartSunday ? first.getDay() : (first.getDay() + 6) % 7;
    const start = new Date(viewYear, viewMonth, 1 - startOffset);
    const result = [];

    for (let row = 0; row < 6; row++) {
      const rowStart = new Date(start.getFullYear(), start.getMonth(), start.getDate() + row * 7);
      const week = isoWeekNumber(new Date(rowStart.getFullYear(), rowStart.getMonth(), rowStart.getDate() + 3));
      result.push({
        "week": week
      });
      for (let col = 0; col < 7; col++) {
        const d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + row * 7 + col);
        result.push({
          "year": d.getFullYear(),
          "month": d.getMonth(),
          "day": d.getDate(),
          "other": d.getMonth() !== viewMonth || d.getFullYear() !== viewYear,
          "isToday": d.getFullYear() === today.getFullYear() && d.getMonth() === today.getMonth() && d.getDate() === today.getDate(),
          "isSelected": d.getFullYear() === selectedYear && d.getMonth() === selectedMonth && d.getDate() === selectedDay
        });
      }
    }
    return result;
  }

  function prevMonth(): void {
    if (viewMonth === 0) {
      viewMonth = 11;
      viewYear--;
    } else {
      viewMonth--;
    }
  }

  function nextMonth(): void {
    if (viewMonth === 11) {
      viewMonth = 0;
      viewYear++;
    } else {
      viewMonth++;
    }
  }

  function goToday(): void {
    viewYear = clock.date.getFullYear();
    viewMonth = clock.date.getMonth();
    selectedYear = viewYear;
    selectedMonth = viewMonth;
    selectedDay = clock.date.getDate();
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

  onVisibleChanged: {
    if (visible)
      goToday();
  }

  Component.onCompleted: goToday()

  RowLayout {
    id: row
    anchors.left: parent.left
    width: parent.width
    spacing: Global.format.spacing_large

    ColumnLayout {
      id: calendarBlock
      Layout.preferredWidth: root.gridWidth
      Layout.maximumWidth: root.gridWidth
      spacing: Global.format.spacing_medium

      RowLayout {
        id: header
        Layout.fillWidth: true
        spacing: Global.format.spacing_medium

        ClickableText {
          text: ""
          baseColor: Global.colors.on_surface_variant
          hoverColor: Global.colors.primary
          onClicked: root.prevMonth()
        }

        StyledText {
          text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
          color: Global.colors.on_surface
          font.bold: true
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
        }

        ClickableText {
          text: ""
          baseColor: Global.colors.on_surface_variant
          hoverColor: Global.colors.primary
          onClicked: root.nextMonth()
        }

        ClickableText {
          text: "Today"
          baseColor: Global.colors.primary
          hoverColor: Global.colors.tertiary
          onClicked: root.goToday()
        }
      }

      GridLayout {
        id: grid
        Layout.preferredWidth: root.gridWidth
        Layout.maximumWidth: root.gridWidth
        columns: 8
        columnSpacing: Global.format.spacing_tiny
        rowSpacing: Global.format.spacing_tiny

        Repeater {
          model: root.weekdayLabels

          delegate: Item {
            required property string modelData
            required property int index

            readonly property bool isCorner: index === 0

            Layout.preferredWidth: isCorner ? root.weekCellWidth : root.dayCellWidth
            Layout.maximumWidth: isCorner ? root.weekCellWidth : root.dayCellWidth
            Layout.preferredHeight: Global.format.text_size + Global.format.spacing_medium

            StyledText {
              anchors.centerIn: parent
              text: modelData
              color: Global.colors.outline
              font.pixelSize: Global.format.font_size_small
            }
          }
        }

        Repeater {
          model: root.cells

          delegate: Item {
            id: cellItem
            required property var modelData
            required property int index

            readonly property bool isWeek: index % 8 === 0

            Layout.preferredWidth: isWeek ? root.weekCellWidth : root.dayCellWidth
            Layout.maximumWidth: isWeek ? root.weekCellWidth : root.dayCellWidth
            Layout.preferredHeight: 30

            StyledText {
              visible: cellItem.isWeek
              anchors.centerIn: parent
              text: cellItem.modelData.week !== undefined ? root.pad(cellItem.modelData.week) : ""
              color: Global.colors.outline
              font.pixelSize: Global.format.font_size_small
            }

            Item {
              visible: !cellItem.isWeek
              anchors.fill: parent

              Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 0
                color: cellItem.modelData.isToday ? Global.colors.primary : cellMouse.containsMouse ? Global.colors.surface_container_high : "transparent"
                border.color: !cellItem.modelData.isToday && cellItem.modelData.isSelected ? Global.colors.primary : "transparent"
                border.width: 1
              }

              StyledText {
                anchors.centerIn: parent
                text: cellItem.modelData.day !== undefined ? cellItem.modelData.day.toString() : ""
                color: cellItem.modelData.isToday ? Global.colors.on_primary : cellItem.modelData.other ? Global.colors.outline : Global.colors.on_surface
              }

              MouseArea {
                id: cellMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selectDay(cellItem.modelData)
              }
            }
          }
        }
      }
    }

    ColumnLayout {
      id: dateDisplay
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 0

      StyledText {
        text: Qt.formatDateTime(clock.date, "dddd d MMMM yyyy")
        font.pixelSize: 20
        font.bold: true
        color: Global.colors.on_surface
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
      }

      StyledText {
        text: Qt.formatDateTime(clock.date, "HH:mm:ss")
        font.pixelSize: 30
        font.bold: true
        color: Global.colors.on_surface_variant
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
