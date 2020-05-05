import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

Pane {
    id: root
    property var app
    property bool selected: false

    background: Rectangle {
        visible: selected === true
        radius: width * 0.1
        opacity: 0.5
        color: "black"
    }

    signal hovered
    signal clicked
    signal released

    Column {
        anchors.fill: parent
        anchors.margins: window.pixDens * 1
        spacing: window.pixDens * 1
        AnimatedButton2 {
            id: icon
            width: parent.width
            height: parent.width

            source: "image://icons/" + app[1]
            onHovered: {
                if (hovered) {
                    root.hovered()
                }
            }

            onClicked: {
                root.clicked()
            }

            onReleased: {
                root.released()
            }
        }

        Label {
            id: label
            width: parent.width
            height: parent.height - icon.height - spacing
            text: app[0]
            font.pixelSize: window.pixDens * 4
            font.family: "Helvetica"
            color: "white"
            maximumLineCount: height / font.pixelSize
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
