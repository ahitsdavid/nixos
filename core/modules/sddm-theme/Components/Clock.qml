import QtQuick 2.15

Column {
    id: root
    spacing: 8

    readonly property color colText: "#CDD6F4"
    readonly property color colSubtext0: "#A6ADC8"

    Text {
        id: timeText
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 72
        font.family: config.Font
        font.weight: Font.Light
        color: colText
        text: Qt.formatTime(new Date(), "hh:mm")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }

    Text {
        id: dateText
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 18
        font.family: config.Font
        color: colSubtext0
        text: Qt.formatDate(new Date(), "dddd, MMMM d")

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: dateText.text = Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }
}
