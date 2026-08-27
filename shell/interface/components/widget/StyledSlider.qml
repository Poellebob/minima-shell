import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root

    implicitWidth: 150
    implicitHeight: 18

    property real from: 0
    property real to: 100
    property real value: 0

    signal moved(real value)
    signal doneMoving(real value)

    readonly property real _ratio: {
        if (to === from)
            return 0;

        return Math.max(0, Math.min(1, (value - from) / (to - from)));
    }

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right

        height: 2
        color: Global.colors.surface_container_highest

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width * root._ratio
            color: Global.colors.primary
        }
    }

    Rectangle {
        id: handle

        anchors.verticalCenter: parent.verticalCenter

        x: (parent.width - width) * root._ratio

        width: 10
        height: 14

        color: Global.colors.primary

        Behavior on x {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        property bool _pressedInside: false

        function updateValue(mouseX) {
            const ratio = Math.max(0, Math.min(1, mouseX / width));
            const newValue = from + ratio * (to - from);
            root.value = Math.max(from, Math.min(to, newValue));
            root.moved(root.value);
        }

        function _isInside(mouse) {
            return mouse.x >= 0 && mouse.x <= width && mouse.y >= 0 && mouse.y <= height;
        }

        onPressed: mouse => {
            _pressedInside = _isInside(mouse);
            if (_pressedInside)
                updateValue(mouse.x);
        }

        onPositionChanged: mouse => {
            if (!pressed || !_pressedInside)
                return;
            updateValue(mouse.x);
        }

        onReleased: mouse => {
            if (_pressedInside)
                root.doneMoving(root.value);
            _pressedInside = false;
        }

        onCanceled: {
            _pressedInside = false;
        }
    }
}
