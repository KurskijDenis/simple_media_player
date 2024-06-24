import QtQuick
import QtMultimedia

Item {
    property alias model: model
    property int selectedTrack: 0

    function getPreferableIndex(tracks) {
        let lang = "english"
        if (selectedTrack < model.count && !!model.get(selectedTrack).lang) {
            lang = model.get(selectedTrack).lang.toLowerCase()
        }

        for (let i = 0; i < tracks.length; i++) {
            const tlang = tracks[i].stringValue(MediaMetaData.Language).toLowerCase()
            if (lang == tlang) {
                return i
            }

            if (lang.length >= 3 && tlang.length >= 3 && lang.substring(0, 3) == tlang.substring(0, 3)) {
                return i
            }
        }

        return 0
    }

    function read(tracks) {
        selectedTrack = getPreferableIndex(tracks)
        model.clear()

        if (!tracks) {
            return
        }

        tracks.forEach((metadata, index) => {
            const data = metadata.stringValue(MediaMetaData.Title)
            const lang = metadata.stringValue(MediaMetaData.Language)
            let label = data ? data : qsTr("track ") + (index + 1)
            label = lang ? label + qsTr(" [") + lang + qsTr("]") : label
            model.append({
                data: label,
                index: index,
                lang: lang,
                pathToFile: "",
                isActive: selectedTrack == index,
            })
        })
    }

    function addExternalTrack(info, pathToFile) {
        if (!info || pathToFile == "") {
            return
        }

        const index = model.count
        for (let i = 0; i < index; i++) {
            if (model.get(i).pathToFile == pathToFile) {
                updateActiveTrack(i)
                return
            }
        }

        model.get(selectedTrack).isActive = false
        selectedTrack = index

        const data = info[0].stringValue(MediaMetaData.Title)
        const lang = info[0].stringValue(MediaMetaData.Language)
        let label = "[External] " + (data ? data : qsTr("track ") + (index + 1))
        label = lang ? label + qsTr(" [") + lang + qsTr("]") : label
        model.append({
            data: label,
            index: index,
            lang: lang,
            pathToFile: pathToFile,
            external: true,
            isActive: true,
        })

    }

    function updateActiveTrack(index) {
        if (model.count <= index) {
            return 0
        }

        if (model.get(index).isActive) {
            return index
        }

        let oldSelectedTrack = selectedTrack
        model.get(selectedTrack).isActive = false

        selectedTrack = index
        model.get(selectedTrack).isActive = true

        return oldSelectedTrack
    }

    ListModel { id: model }
}