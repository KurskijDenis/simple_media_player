import QtQuick

Item {
    property alias metadata: listModel
    property alias count: listModel.count

    function clear() {
        listModel.clear()
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

    ListModel {
        id: listModel
    }
}