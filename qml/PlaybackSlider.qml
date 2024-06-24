import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

Slider {
    id: root

    property double handlerSize: 1.0
    property double lineSize: 0.3

    background: Rectangle {
        anchors.verticalCenter: root.verticalCenter
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        width: root.availableWidth

        radius: root.availableHeight * lineSize / 2
        height: root.availableHeight * lineSize
        color: "#bdbebf"

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: "#000000"
            radius: parent.radius
        }
    }

    handle: Rectangle {
            x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
            y: root.topPadding + root.availableHeight / 2 - height / 2
            radius: root.availableHeight * handlerSize / 2
            height: root.availableHeight * handlerSize
            width: root.availableHeight * handlerSize
            color: root.pressed ? "#f0f0f0" : "#f6f6f6"
            border.color: "#bdbebf"
    }
}