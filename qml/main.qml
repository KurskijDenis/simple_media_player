import QtQuick
import QtQuick.Controls
import QtMultimedia
import QtQuick.Window
import QtQuick.Controls.Basic
import Qt.labs.platform
import QtQuick.Dialogs
import main.scene

ApplicationWindow {
    id: root
    visible: true
    width: 800; height: 600

    property bool showControls: true
    property bool autoNextPlay: true

    function loadNewMedia(videoFile, audioFile, subtitleFile) {
        playListVideo.setFileToPlay(videoFile, true)
        playListAudio.setFileToPlay(audioFile, false)

    }

    function playNextTrack() {
        playListVideo.switchToNext()
        playListVideo.apply()

        playListAudio.switchToNext()
    }

    function playPrevTrack() {
        playListVideo.switchToPrevious()
        playListVideo.apply()

        playListAudio.switchToPrevious()
    }

    function toggleVideo() {
        if (videoOutput.playing) {
            mediaplayer.pause()
            if (mediaplayerSound.enabled){
                mediaplayerSound.pause()
            }
        } else {
            mediaplayer.play()
            if (mediaplayerSound.enabled) {
                mediaplayerSound.play()
                mediaplayerSound.setPosition(mediaplayer.position)
             }
        }

        videoOutput.playing = !videoOutput.playing;
    }

    function updatePosition(offset) {
        let newPosition = mediaplayer.position + offset
        mediaplayer.setPosition(newPosition)
        if (mediaplayerSound.enabled){
            mediaplayerSound.setPosition(newPosition)
        }
    }

    MetaDataInfo {
        id: metaDataInfo
    }

    TrackInfo {
       id: trackInfoModel
    }

    PlayListController{
        id: playListVideo

        onCurrentFileNameChanged: {
            mediaplayer.setSource(currentFileName)
            if (currentFileName === "") {
                console.log("Video file is not set")

                if (videoOutput.playing) {
                    toggleVideo()
                }

                mediaplayer.setSource("")
                playListAudio.setFileToPlay("", true)
            } else {
                console.log("Use new video file " + currentFileName)
            }

            if (videoOutput.playing) {
                mediaplayer.play()
            }
        }
    }

    PlayListController {
        id: playListAudio

        onCurrentFileNameChanged: {
            mediaplayerSound.setSource(currentFileName)
            mediaplayerSound.enabled = (currentFileName !== "")

            if (mediaplayerSound.enabled) {
                mediaplayerSound.setPosition(mediaplayer.position)
                if (videoOutput.playing) {
                    mediaplayerSound.play()
                } else {
                    mediaplayerSound.pause()
                }
            }
        }
    }

    FileDialog {
        id: openTrackDialog
        onAccepted: {
            let audioFile = openTrackDialog.selectedFile.toString()
            if (audioFile == "") {
                return
            }

            playListAudio.setFileToPlay(audioFile, true)
        }
    }

    MenuBar {
        id: mainMenu
        Menu {
            id: fileMenu
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open...")
                onTriggered: {
                    let component = Qt.createComponent("FindFiles.qml");
                    if (component.status === Component.Error) {
                        console.log(component.errorString())
                        return
                    }

                    let win = component.createObject(root);
                    win.changeVideoSources.connect(loadNewMedia)
                    win.show();
                }
            }
        }
        Menu {
            id: audioMenu
            title: qsTr("&Audio")
            Menu {
                id: tracksMenu
                title: qsTr("&Tracks")
                MenuItemGroup {
                    id: tracksGroup
                    exclusive : true
                }
                Instantiator {
                    id: audioInstantiator
                    model: trackInfoModel.model
                    MenuItem {
                        text: model.data
                        checkable: true
                        checked: model.isActive
                        group: tracksGroup
                        onTriggered: {
                            mediaplayer.activeAudioTrack = model.index;
                            let oldTrack = trackInfoModel.updateActiveTrack(model.index);
                            tracksGroup.items[model.index].checked = true

                            if (oldTrack == model.index) {
                                return
                            }

                            let newTrackPath = trackInfoModel.model.get(model.index).pathToFile
                            let oldTrackIsInternal = trackInfoModel.model.get(oldTrack).pathToFile == ""
                            let newTrackIsInternal = newTrackPath == ""

                            if (oldTrackIsInternal) {
                                if (newTrackIsInternal) {
                                    return
                                }
                            } else {
                                if (newTrackIsInternal) {
                                    playListAudio.setFileToPlay("", true)
                                    return
                                }
                            }

                            mediaplayer.activeAudioTrack = 0
                            playListAudio.setFileToPlay(newTrackPath, true)
                        }
                    }

                    onObjectAdded: (index, object) => {
                        if (object.checked) {
                            if (trackInfoModel.model.get(index).pathToFile == "") {
                                mediaplayer.activeAudioTrack = index
                            } else {
                                mediaplayer.activeAudioTrack = 0
                            }
                        }
                        tracksMenu.insertItem(index, object)
                    }
                    onObjectRemoved: (index, object) => tracksMenu.removeItem(object)
                }
            }

            MenuItem {
                text: qsTr("&Open...")
                onTriggered: openTrackDialog.open()
            }
        }
        Menu {
            id: helpMenu
            title: qsTr("&Help")
            MenuItem {
                text: qsTr("Meta")
                onTriggered: {
                    let component = Qt.createComponent("MetaInfoWindow.qml");
                    let win = component.createObject(root, { mediaPlayer: mediaplayer});

                    win.show();
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        Timer {
            id: nextTrackTracker
            interval: 3000
            running: false
            repeat: false
            onTriggered: {
                if (mediaplayer.position != 0) {
                    if (mediaplayer.position >= mediaplayer.duration) {
                        root.playNextTrack()
                    }
                }
            }
        }

        MediaPlayer {
            id: mediaplayer

            audioOutput: mediaplayerSound.enabled ? null : playerAudio
            videoOutput: videoOutput

            onPositionChanged: {
                if (root.autoNextPlay && mediaplayer.position >= mediaplayer.duration) {
                    nextTrackTracker.start()
                } else {
                    nextTrackTracker.stop()
                }
            }

            onMetaDataChanged: {
                trackInfoModel.read(mediaplayer.audioTracks)

                metaDataInfo.clear()
                metaDataInfo.read(mediaplayer.metaData)
                metaDataInfo.read(mediaplayer.audioTracks[mediaplayer.activeAudioTrack])
                metaDataInfo.read(mediaplayer.videoTracks[mediaplayer.activeVideoTrack])
                metaDataInfo.read(mediaplayer.subtitleTracks[mediaplayer.activeSubtitleTrack])

                playListAudio.apply()
            }
        }

        MediaPlayer {
            id: mediaplayerSound

            property bool enabled: false
            property string srcPath: ""

            audioOutput: enabled ? playerAudio : null

            onMediaStatusChanged: {
                mediaplayerSound.setPosition(mediaplayer.position)
            }
            onMetaDataChanged: trackInfoModel.addExternalTrack(mediaplayerSound.audioTracks, playListAudio.currentFileName)
        }

        AudioOutput {
            id: playerAudio
            volume: 1
        }

        VideoOutput {
            id: videoOutput

            property bool fullScreen: false
            property bool playing: false

            anchors.fill: parent

            TapHandler {
                exclusiveSignals: TapHandler.SingleTap | TapHandler.DoubleTap
                onDoubleTapped: {
                    parent.fullScreen ? root.showNormal() : root.showFullScreen()
                    parent.fullScreen = !parent.fullScreen
                }

                onSingleTapped: toggleVideo()
            }
        }

        ControlPanel {
            id: controlRect

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            visible: root.showControls
            height: 30

            isPlaying: videoOutput.playing
            isMediaEnabled: mediaplayer.seekable

            volume: playerAudio.volume
            videoPosition: mediaplayer.position
            videoDuration: mediaplayer.duration

            onVolumePositionChanged: position => playerAudio.volume = position
            onVideoPositionUpdated: position => updatePosition(position)

            onPrevTrack: root.playPrevTrack()
            onNextTrack: root.playNextTrack()

            onPlayStopVideo: toggleVideo()
        }

        Item {
            focus: true
            Keys.onLeftPressed: updatePosition(-10000)
            Keys.onRightPressed: updatePosition(10000)
            Keys.onSpacePressed: toggleVideo()
            Keys.onEscapePressed: {
                root.showNormal()
                videoOutput.fullScreen = false
            }
        }

        MouseArea {
            property var lastActiveMouse: new Date()

            propagateComposedEvents: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: controlRect.top

            hoverEnabled: true
            cursorShape: root.showControls ? Qt.ArrowCursor : Qt.BlankCursor

            onClicked: mouse => mouse.accepted = false
            onPressed: mouse => mouse.accepted = false
            onPositionChanged: (mouse) => {
                lastActiveMouse = new Date();
                root.showControls = true;
                mouse.accepted = true
            }
            Timer {
                id: vivibilityTracker
                interval: 1000;
                running: true;
                repeat: true
                onTriggered: {
                    let now = new Date()
                    root.showControls = controlMouseArea.containsMouse || now.getTime() - parent.lastActiveMouse.getTime() < 3000;
                }
            }
        }

        MouseArea {
            id: controlMouseArea
            propagateComposedEvents: true
            anchors.fill: controlRect
            onClicked: mouse => mouse.accepted = false
            onPressed: mouse => mouse.accepted = false
            hoverEnabled: true
        }
    }
}
