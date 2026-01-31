import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property alias text: hiddenInput.text
    property int charCount: hiddenInput.text.length

    // Catppuccin colors
    readonly property color colText: "#CDD6F4"
    readonly property color colMauve: "#CBA6F7"
    readonly property color colPink: "#F5C2E7"
    readonly property color colBlue: "#89B4FA"
    readonly property color colTeal: "#94E2D5"
    readonly property color colGreen: "#A6E3A1"
    readonly property color colYellow: "#F9E2AF"
    readonly property color colPeach: "#FAB387"
    readonly property color colOverlay0: "#6C7086"
    readonly property color colRed: "#F38BA8"

    // Shape colors for password characters
    readonly property var shapeColors: [colMauve, colPink, colBlue, colTeal, colGreen, colYellow, colPeach]

    signal accepted()

    function forceActiveFocus() {
        hiddenInput.forceActiveFocus()
    }

    function clear() {
        hiddenInput.text = ""
    }

    function shake() {
        shakeAnimation.start()
    }

    implicitHeight: 40

    // Hidden text input
    TextInput {
        id: hiddenInput
        anchors.fill: parent
        opacity: 0
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData
        focus: true

        onAccepted: root.accepted()
    }

    // Container with clipping for password shapes
    Item {
        id: shapeContainer
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        clip: true

        // Visual password display with shapes - show only last N characters that fit
        Row {
            id: shapeRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4
            spacing: 4

            Repeater {
                // Calculate max visible chars based on container width (24px per char)
                property int maxVisible: Math.floor((shapeContainer.width - 8) / 24)
                property int startIndex: Math.max(0, root.charCount - maxVisible)
                model: Math.min(root.charCount, maxVisible)

            delegate: Item {
                id: charShape
                width: 20
                height: 20

                // Use actual character index for consistent shape colors
                property int actualIndex: index + parent.parent.startIndex
                property int shapeIndex: actualIndex % 7
                property color shapeColor: shapeColors[shapeIndex]

                // Different shapes based on index
                Canvas {
                    id: shapeCanvas
                    anchors.fill: parent
                    opacity: 0
                    scale: 0.5

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.fillStyle = charShape.shapeColor

                        var cx = width / 2
                        var cy = height / 2
                        var r = Math.min(width, height) / 2 - 2

                        switch (charShape.shapeIndex) {
                            case 0: // Circle
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                                ctx.fill()
                                break
                            case 1: // Diamond
                                ctx.beginPath()
                                ctx.moveTo(cx, cy - r)
                                ctx.lineTo(cx + r, cy)
                                ctx.lineTo(cx, cy + r)
                                ctx.lineTo(cx - r, cy)
                                ctx.closePath()
                                ctx.fill()
                                break
                            case 2: // Triangle
                                ctx.beginPath()
                                ctx.moveTo(cx, cy - r)
                                ctx.lineTo(cx + r, cy + r * 0.7)
                                ctx.lineTo(cx - r, cy + r * 0.7)
                                ctx.closePath()
                                ctx.fill()
                                break
                            case 3: // Square (rounded)
                                var sr = r * 0.8
                                drawRoundedRect(ctx, cx - sr, cy - sr, sr * 2, sr * 2, 3)
                                ctx.fill()
                                break
                            case 4: // Star
                                drawStar(ctx, cx, cy, 5, r, r * 0.5)
                                ctx.fill()
                                break
                            case 5: // Hexagon
                                drawPolygon(ctx, cx, cy, r, 6)
                                ctx.fill()
                                break
                            case 6: // Pentagon
                                drawPolygon(ctx, cx, cy, r, 5)
                                ctx.fill()
                                break
                        }
                    }

                    function drawRoundedRect(ctx, x, y, w, h, r) {
                        ctx.beginPath()
                        ctx.moveTo(x + r, y)
                        ctx.lineTo(x + w - r, y)
                        ctx.arcTo(x + w, y, x + w, y + r, r)
                        ctx.lineTo(x + w, y + h - r)
                        ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
                        ctx.lineTo(x + r, y + h)
                        ctx.arcTo(x, y + h, x, y + h - r, r)
                        ctx.lineTo(x, y + r)
                        ctx.arcTo(x, y, x + r, y, r)
                        ctx.closePath()
                    }

                    function drawPolygon(ctx, cx, cy, r, sides) {
                        ctx.beginPath()
                        for (var i = 0; i < sides; i++) {
                            var angle = (i * 2 * Math.PI / sides) - Math.PI / 2
                            var x = cx + r * Math.cos(angle)
                            var y = cy + r * Math.sin(angle)
                            if (i === 0) ctx.moveTo(x, y)
                            else ctx.lineTo(x, y)
                        }
                        ctx.closePath()
                    }

                    function drawStar(ctx, cx, cy, points, outer, inner) {
                        ctx.beginPath()
                        for (var i = 0; i < points * 2; i++) {
                            var r = (i % 2 === 0) ? outer : inner
                            var angle = (i * Math.PI / points) - Math.PI / 2
                            var x = cx + r * Math.cos(angle)
                            var y = cy + r * Math.sin(angle)
                            if (i === 0) ctx.moveTo(x, y)
                            else ctx.lineTo(x, y)
                        }
                        ctx.closePath()
                    }

                    Component.onCompleted: {
                        requestPaint()
                        appearAnim.start()
                    }
                }

                ParallelAnimation {
                    id: appearAnim
                    NumberAnimation {
                        target: shapeCanvas
                        property: "opacity"
                        to: 1
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: shapeCanvas
                        property: "scale"
                        to: 1
                        duration: 200
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
    }

    // Placeholder when empty
    Text {
        anchors.centerIn: parent
        text: "Enter password"
        color: colOverlay0
        font.pixelSize: 14
        font.family: config.Font
        visible: root.charCount === 0
    }

    // Cursor - positioned at right edge of shape container
    Rectangle {
        visible: hiddenInput.activeFocus && root.charCount > 0
        x: shapeContainer.x + shapeContainer.width - 2
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: 20
        color: colMauve
        opacity: cursorBlink.running ? (cursorBlink.cursorVisible ? 1 : 0) : 1

        Timer {
            id: cursorBlink
            property bool cursorVisible: true
            interval: 530
            running: hiddenInput.activeFocus
            repeat: true
            onTriggered: cursorVisible = !cursorVisible
        }
    }

    // Shake animation for wrong password
    SequentialAnimation {
        id: shakeAnimation
        NumberAnimation { target: shapeContainer; property: "anchors.leftMargin"; to: -12; duration: 50 }
        NumberAnimation { target: shapeContainer; property: "anchors.leftMargin"; to: 28; duration: 50 }
        NumberAnimation { target: shapeContainer; property: "anchors.leftMargin"; to: -2; duration: 40 }
        NumberAnimation { target: shapeContainer; property: "anchors.leftMargin"; to: 18; duration: 40 }
        NumberAnimation { target: shapeContainer; property: "anchors.leftMargin"; to: 8; duration: 30 }
    }

    // Click to focus
    MouseArea {
        anchors.fill: parent
        onClicked: hiddenInput.forceActiveFocus()
    }
}
