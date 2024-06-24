import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Dialogs

Window {
    id : root
    width: 600
    height: 600

    signal changeVideoSources(videoFile: string, audioFile: string, subtitleFile: string)

    Rectangle {
        anchors.fill: parent

        OpenFileItem {
            id: videoFileController
            buttonText: "Open Video File"

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.leftMargin: 15
            anchors.rightMargin: 15
        }

        OpenFileItem {
            id: audioFileController
            buttonText: "Open Audio File"

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: videoFileController.top
            anchors.topMargin: 30
            anchors.leftMargin: 15
            anchors.rightMargin: 15
        }

        OpenFileItem {
            id: subtitleFileController
            buttonText: "Open Subtitles File"

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: audioFileController.top
            anchors.topMargin: 30
            anchors.leftMargin: 15
            anchors.rightMargin: 15
        }

        ControllerButton {
            id: okBtn

            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 15
            anchors.bottomMargin: 15

            text: "OK"

            onClicked: {
                root.changeVideoSources(
                    videoFileController.pathToFile,
                    audioFileController.pathToFile,
                    subtitleFileController.pathToFile)
                root.close()
            }
        }
        ControllerButton {
            id: closeBtn

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 15
            anchors.bottomMargin: 15

            text: "Cancel"

            onClicked: {
                root.close()
            }
        }
    }
}