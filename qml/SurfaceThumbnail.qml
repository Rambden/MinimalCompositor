import QtQuick 2.10
import QtWayland.Compositor 1.1
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.0

Rectangle {
    id: root
    property alias surface: waylandItem.surface
    property alias contentItem: thumbnailBorder
    property alias title: label.text
    property real animationSpeed: 150

    property real itemWidth: 0.0
    property real itemHeight: 0.0

    // ListView highlight and snapping do not work well with variable size items
    //    width: thumbnailBorder.width
    //    height: thumbnailBorder.height
    width: itemWidth
    height: itemHeight
    color: "transparent"

    signal tapped
    signal longPressed
    signal close
    signal animationComplete

    smooth: true

    Rectangle {
        id: thumbnailBorder
        anchors.centerIn: parent

        smooth: true

        width: {
            if (surface.size.width > modelData.surface.size.height) {
                return height * surface.size.width / surface.size.height
            } else {
                return itemHeight * surface.size.width / surface.size.height
            }
        }

        height: {
            if (surface.size.width > surface.size.height) {
                return Math.min(
                            itemWidth * surface.size.height / surface.size.width,
                            itemHeight)
            } else {
                return itemHeight
            }
        }

        radius: window.pixDens * 1
        color: "transparent"

        border.color: "orange"
        border.width: window.pixDens * 0.5

        WaylandQuickItem {
            id: waylandItem
            inputEventsEnabled: false
            sizeFollowsSurface: false
            anchors.centerIn: parent
            anchors.fill: parent
            anchors.margins: thumbnailBorder.border.width
            smooth: true

            onSurfaceDestroyed: {
                bufferLocked = true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.tapped()
                }
                onPressAndHold: {
                    if (root.state === "highlighted") {
                        closeButton.show()
                    }
                    root.longPressed()
                }
            }
        }
        AnimatedButton2 {
            id: closeButton
            anchors.horizontalCenter: waylandItem.right
            anchors.verticalCenter: waylandItem.top
            width: 48
            height: 48
            radius: 48
            color: "transparent"
            source: "qrc:/resources/close.png"

            onClicked: {
                hide()
                root.close()
            }

            Component.onCompleted: {
                hide()
            }
        }
        Label {
            id: label

            anchors.horizontalCenter: thumbnailBorder.horizontalCenter
            anchors.verticalCenter: thumbnailBorder.bottom
            height: font.pixelSize + window.pixDens * 2
            width: contentWidth + window.pixDens * 2
            font.pixelSize: window.pixDens * 4
            font.family: "Helvetica"
            text: "App window"
            color: "light gray"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            background: Rectangle {
                color: "black"
                radius: 10
                opacity: 0.75
            }
        }
    }

    //Reset state
    onVisibleChanged: {
        closeButton.hide()
    }

    transform: Scale {
        id: scaleTransform
        xScale: 1.0
        yScale: 1.0
        origin.x: root.width / 2
        origin.y: root.height / 2
    }

    onStateChanged: {
        console.log("thumbnail state: " + state)
    }

    states: [
        State {
            name: "inactive"
            PropertyChanges {
                target: root
                opacity: 0.5
            }
            PropertyChanges {
                target: thumbnailBorder
                border.color: "dark gray"
            }
            PropertyChanges {
                target: scaleTransform
                xScale: 0.95
                yScale: 0.95
            }
            StateChangeScript {
                name: "reset"
                script: {
                    closeButton.hide()
                }
            }
        },
        State {
            name: "highlighted"
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            ParallelAnimation {
                NumberAnimation {
                    target: root
                    property: "opacity"
                    duration: animationSpeed
                }
                NumberAnimation {
                    target: scaleTransform
                    properties: "xScale"
                    duration: animationSpeed
                    easing.type: Easing.InBack
                }
                NumberAnimation {
                    target: scaleTransform
                    properties: "yScale"
                    duration: animationSpeed
                    easing.type: Easing.InBack
                }
                ScriptAction {
                    scriptName: "reset"
                }
            }
        }
    ]
}
