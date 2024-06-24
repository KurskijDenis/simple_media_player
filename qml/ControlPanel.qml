import QtQuick
import QtQuick.Controls
import QtMultimedia
import QtQuick.Window
import QtQuick.Controls.Basic
import Qt.labs.platform
import QtQuick.Dialogs
import main.scene

Rectangle {
    id: controlRect

    function getPassedTime(pos) {
        let remainTime = Math.floor(pos / 1000)
        let rtime = (`0${remainTime % 60}`).slice(-2)
        remainTime = Math.floor(remainTime / 60)
        rtime = (`0${remainTime % 60}:${rtime}`).slice(-5)
        remainTime = Math.floor(remainTime / 60)
        if (remainTime < 10) {
            return `0${remainTime}:${rtime}`
        }
        return `${remainTime}:${rtime}`
    }

    property bool isPlaying : false
    property bool isMediaEnabled: false

    property real volume: 1.0
    property int videoPosition: 0
    property int videoDuration: 1

    signal volumePositionChanged(position: real)
    signal videoPositionUpdated(position: real)
    signal nextTrack()
    signal prevTrack()
    signal playStopVideo()

    RoundButton {
        id: moveBack
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        anchors.leftMargin: 5
        anchors.top: parent.top

        icon.source: "qrc:///qml.test.project/imports/main/scene/resources/backward10.svg"
        icon.color: "#000000"
        background: Rectangle {
            border.width: moveBack.activeFocus ? 2 : 1
            border.color: "#888"
            color: moveBack.pressed ? "#ccc" : "#eee"
        }

        onClicked: controlRect.videoPositionUpdated(-10000)
    }

    RoundButton {
        id: playStopButton

        anchors.left: moveBack.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottomMargin: 2

        icon.source: !controlRect.isPlaying ? "qrc:///qml.test.project/imports/main/scene/resources/play.svg" : "qrc:///qml.test.project/imports/main/scene/resources/pause.svg"
        icon.color: "#000000"
        background: Rectangle {
            border.width: playStopButton.activeFocus ? 2 : 1
            border.color: "#888"
            color: playStopButton.pressed ? "#ccc" : "#eee"
        }

        onClicked: playStopVideo()
    }

    RoundButton {
        id: moveForward

        anchors.left: playStopButton.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        anchors.rightMargin: 5

        icon.source: "qrc:///qml.test.project/imports/main/scene/resources/forward10.svg"
        icon.color: "#000000"
        background: Rectangle {
            border.width: moveForward.activeFocus ? 2 : 1
            border.color: "#888"
            color: moveForward.pressed ? "#ccc" : "#eee"
        }

        onClicked: controlRect.videoPositionUpdated(10000)
    }

    RoundButton {
        id: rewindButton

        anchors.left: moveForward.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        anchors.leftMargin: 5

        icon.source: "qrc:///qml.test.project/imports/main/scene/resources/rewind.svg"
        icon.color: "#000000"
        background: Rectangle {
            border.width: rewindButton.activeFocus ? 2 : 1
            border.color: "#888"
            color: rewindButton.pressed ? "#ccc" : "#eee"
        }
        onClicked: controlRect.prevTrack()
    }

    RoundButton {
        id: getNext

        anchors.left: rewindButton.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        anchors.rightMargin: 5

        icon.source: "qrc:///qml.test.project/imports/main/scene/resources/next.svg"
        icon.color: "#000000"

        background: Rectangle {
            border.width: getNext.activeFocus ? 2 : 1
            border.color: "#888"
            color: getNext.pressed ? "#ccc" : "#eee"
        }

        onClicked: controlRect.nextTrack()
    }

    Text {
        id: currentTime

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: getNext.right
        anchors.leftMargin: 10

        text: "00:00:00"
        font.pointSize: 10
        font.family: "Helvetica"
        color: "black"
    }

    PlaybackSlider {
        id: mediaSlider

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: currentTime.right
        anchors.right: remainTime.left

        enabled: controlRect.isMediaEnabled
        to: 1.0
        value: controlRect.videoPosition / controlRect.videoDuration
        onMoved: controlRect.videoPositionUpdated(value * controlRect.videoDuration - controlRect.videoPosition)
        onValueChanged: {
            remainTime.text = getPassedTime(controlRect.videoDuration - controlRect.videoPosition)
            currentTime.text = getPassedTime(controlRect.videoPosition)
        }
    }

    Text {
        id: remainTime

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: speakerImage.left
        anchors.rightMargin: 10

        text: "00:00:00"
        font.family: "Helvetica"
        font.pointSize: 10
        color: "black"
    }

    Image {
        id: speakerImage

        property real lastSavedValue: 1.0

        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.right: volumeSlider.left
        anchors.bottomMargin: 5
        anchors.topMargin: 5
        width: height

        source: volumeSlider.value == 0.0 ? "qrc:///qml.test.project/imports/main/scene/resources/mute.svg" : "qrc:///qml.test.project/imports/main/scene/resources/sound.svg"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (volumeSlider.value == 0.0) {
                    volumeSlider.value = speakerImage.lastSavedValue
                } else {
                    speakerImage.lastSavedValue = volumeSlider.value
		    volumeSlider.value = 0.0
                }
                controlRect.volumePositionChanged(volumeSlider.value)
            }
        }
    }

    PlaybackSlider {
        id: volumeSlider

        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.right: volumeP.left
        width: 100

        enabled: controlRect.isMediaEnabled
        to: 1.0
        value: controlRect.volume

        onMoved: controlRect.volumePositionChanged(value)
    }

    Text {
        id: volumeP

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10

        text: `${Math.floor(volumeSlider.value * 100)}%`
        font.family: "Helvetica"
        font.pointSize: 10

        color: "black"
   }
}