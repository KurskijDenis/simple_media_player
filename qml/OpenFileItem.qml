import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Dialogs

Item {
    id: root

    property string buttonText
    property string pathToFile: ""

    ControllerButton {
        id: loadBtn
        anchors.left: parent.left
        text: buttonText
        onClicked: dialog.open()
    }

    TextArea {
        id: filePath

        anchors.left: loadBtn.right
        anchors.right: parent.right
        anchors.leftMargin: 15
        anchors.top: loadBtn.top
        anchors.bottom: loadBtn.bottom

        verticalAlignment: TextInput.AlignVCenter
        color: "#000"

        background: Rectangle {
            radius: 8
            gradient: Gradient {
                GradientStop { position: 0 ; color: "#eee" }
                GradientStop { position: 1 ; color: "#ccc" }
            }
        }
    }

    FileDialog {
        id: dialog
        onAccepted: {
            const re = new RegExp("(.*)://(.*)")

            root.pathToFile = selectedFile.toString()
            filePath.text = selectedFile.toString().replace(re, "$2")
        }
    }
}