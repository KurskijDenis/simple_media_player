import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

Button {
    id: btn
    background: Rectangle {
        radius: 6
        gradient: Gradient {
            GradientStop { position: 0 ; color: btn.pressed ? "#444" : "#333" }
            GradientStop { position: 1 ; color: btn.pressed ? "#555" : "#444" }
        }
    }
}