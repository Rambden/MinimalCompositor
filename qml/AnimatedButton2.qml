import QtQuick 2.0

Rectangle {
    id: root

    property alias source: thumbnail.source
    property alias fillMode: thumbnail.fillMode
    property real animationSpeed: 150

    color: "transparent"

    signal clicked
    signal released
    signal hovered

    function show() {
        state = "visible"
    }

    function hide() {
        state = "hidden"
    }

    Component.onCompleted: {
        state = "released"
    }

    Image {
        id: thumbnail
        anchors.centerIn: parent
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        sourceSize.height: root.height
        sourceSize.width: root.width

        Rectangle {
            anchors.fill: parent
            visible: thumbnail.status !== Image.Ready
            radius: width * 0.1
            opacity: 1.0
            color: "yellow"
        }
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: {
            if (hovered) {
                root.hovered()
            }
        }

        onCanceled: {
            root.state = "released"
        }

        onExited: {
            root.state = "released"
        }

        onPressed: {
            root.state = "pressed"
        }

        onReleased: {
            root.state = "released"
            root.released()
        }

        onClicked: {
            root.clicked()
        }
    }

    transform: Scale {
        id: scaleTransform
        xScale: 1.0
        yScale: 1.0
        origin.x: root.width / 2
        origin.y: root.height / 2
    }

    states: [
        State {
            name: "pressed"
            PropertyChanges {
                target: root
                opacity: 0.5
            }
            PropertyChanges {
                target: scaleTransform
                xScale: 1.05
                yScale: 1.05
            }
        },
        State {
            name: "released"
        },
        State {
            name: "visible"
            PropertyChanges {
                target: root
                opacity: 1.0
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: root
                opacity: 0.0
            }
            PropertyChanges {
                target: scaleTransform
                xScale: 0
                yScale: 0
            }
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
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: scaleTransform
                    properties: "yScale"
                    duration: animationSpeed
                    easing.type: Easing.OutBack
                }
            }
        }
    ]
}
