import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

Button {
    id: playButton
    icon.color: "#000000"
    background: Rectangle {
        border.width: playButton.activeFocus ? 2 : 1
        color: playButton.pressed ? "#ccc" : "#eee"
    }
}