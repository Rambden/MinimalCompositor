import QtQuick 2.3
import QtWayland.Compositor 1.1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

Item {
    id: root
    property alias model: listView.model
    property alias count: listView.count
    property alias spacing: listView.spacing

    property real itemWidth
    property real itemHeight

    signal switchRequested(var waylandSurface)
    signal closeRequested(var waylandSurface)

    ColumnLayout {
        anchors.fill: parent
        anchors.centerIn: parent
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: model.model
            snapMode: ListView.SnapToItem
            orientation: ListView.Horizontal
            layoutDirection: Qt.RightToLeft

            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: (width) / 2 - itemWidth / 2
            preferredHighlightEnd: (width) / 2 + itemWidth / 2
            highlightMoveDuration: 300
            highlightMoveVelocity: -1
            displayMarginBeginning: count * itemWidth
            displayMarginEnd: count * itemWidth

            Component {
                id: surfaceDelegate
                SurfaceThumbnail {
                    id: thumbnail
                    anchors.verticalCenter: parent.verticalCenter
                    itemWidth: root.itemWidth
                    itemHeight: root.itemHeight
                    state: ListView.isCurrentItem ? "highlighted" : "inactive"
                    surface: modelData.surface
                    title: modelData.title

                    AnimatedButton2 {
                        anchors.horizontalCenter: thumbnail.contentItem.right
                        anchors.verticalCenter: thumbnail.contentItem.top
                        visible: true
                        width: 48
                        height: 48
                        radius: 48
                        color: "transparent"
                        source: "qrc:/resources/close.png"

                        onClicked: {
                            root.closeRequested(modelData)
                        }
                    }

                    onTapped: {
                        if (listView.currentIndex === index) {
                            root.switchRequested(modelData)
                        } else {
                            listView.currentIndex = index
                        }
                    }

                    ListView.onAdd: {
                        listView.currentIndex = index
                    }

                    ListView.onRemove: SequentialAnimation {
                        PropertyAction {
                            target: thumbnail
                            property: "ListView.delayRemove"
                            value: true
                        }
                        NumberAnimation {
                            target: translate
                            property: "y"
                            to: -1 * window.height
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction {
                            target: thumbnail
                            property: "ListView.delayRemove"
                            value: false
                        }
                    }

                    transform: Translate {
                        id: translate
                    }
                }
            }

            delegate: surfaceDelegate

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 150
                    easing.type: Easing.InCubic
                }
            }

            remove: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 150
                    easing.type: Easing.InCubic
                }
            }

            onVisibleChanged: {
                listView.positionViewAtIndex(count - 1, ListView.SnapPosition)
            }
        }
        Item {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: window.pixDens * 5
            AppSwitcherIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                currentIndex: listView.count - listView.currentIndex - 1
                count: listView.count
            }
        }
    }
}
