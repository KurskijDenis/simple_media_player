import QtQuick
import QtQuick.Controls

Window {
    width: 600
    height: 600
    property var mediaPlayer

    Rectangle {
        anchors.fill: parent
        ListView {
            anchors.fill: parent

            model: listModel
            delegate: metaDataDelegate
        }

        Component {
            id: metaDataDelegate
            Row {
                spacing: 10
                Text { text: name }
                Text { text: value }
            }
        }
    }

    function read(metadata) {
        if (!metadata) {
            return
        }

        for (const key of metadata.keys()) {
            if (metadata.stringValue(key)) {
                listModel.append({
                    name: metadata.metaDataKeyToString(key),
                    value: metadata.stringValue(key)
                })
            }
        }
    }

    Component.onCompleted: {
        if (!mediaPlayer) {
            return
        }

        read(mediaPlayer.metaData)
        read(mediaPlayer.audioTracks[mediaplayer.activeAudioTrack])
        read(mediaPlayer.videoTracks[mediaplayer.activeVideoTrack])
        read(mediaPlayer.subtitleTracks[mediaplayer.activeSubtitleTrack])
    }

    ListModel {
        id: listModel
    }
}