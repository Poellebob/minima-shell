import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs

Flow {
  id: root

  required property var model
  signal itemTriggered

  property var groupIndices: []
  spacing: 0

  onModelChanged: {
    var vals = model.values;
    var groups = [];
    var sepCount = 0;
    for (var i = 0; i < vals.length; i++) {
      if (vals[i].isSeparator)
        sepCount++;
      groups.push(sepCount);
    }
    groupIndices = groups;

    visible = false;
    itemRepeater.model = root.model;
    visible = true;
  }

  Repeater {
    id: itemRepeater
    model: root.model

    MenuItem {
      required property QsMenuEntry modelData
      required property int index
      width: modelData.isSeparator ? root.width : Math.floor(root.width / 6)
      height: modelData.isSeparator ? 1 : Global.format.module_height
                                      + Global.format.spacing_small
      entry: modelData
      groupIndex: root.groupIndices[index] ?? 0
      onTriggered: root.itemTriggered()
    }
  }
}
