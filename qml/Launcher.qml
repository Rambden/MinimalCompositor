import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtWayland.Compositor 1.1

Item {

    property alias surfaceModel: appSwitcher.model
    property alias position: drawer.position
    property alias opened: drawer.opened

    Popup {
        id: popup
        x: 0
        y: 0
        width: parent.width
        height: parent.height * 2 / 3
        modal: false
        focus: false
        padding: 0
        opacity: drawer.position
        closePolicy: Popup.NoAutoClose
        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
        }

        Item {
            anchors.fill: parent
            RowLayout {
                anchors.fill: parent
                Layout.alignment: Qt.AlignCenter
                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    AppSwitcher {
                        id: appSwitcher
                        Layout.preferredWidth: popup.width
                        Layout.preferredHeight: popup.height
                        itemWidth: window.width / 2
                        itemHeight: window.height / 2
                        spacing: window.pixDens * 10
                        onSwitchRequested: {
                            surfaceModel.bringToFront(waylandSurface)
                            drawer.close()
                        }

                        onCloseRequested: {
                            console.log("Close " + waylandSurface)
                            if (waylandSurface instanceof XdgSurfaceV5) {
                                waylandSurface.sendClose()
                            } else if (waylandSurface instanceof XdgPopupV5) {
                                waylandSurface.sendClose()
                            } else {
                                console.log("Close request not implemented, close WaylandClient instead")
                                waylandSurface.surface.client.close()
                            }
                        }
                    }
                }
            }
            transform: Translate {
                y: popup.height * (drawer.position - 1)
            }
        }
    }
    Component.onCompleted: drawer.open()
    Drawer {
        id: drawer
        width: window.width
        height: window.height / 3
        edge: Qt.BottomEdge
        modal: false
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            anchors.fill: parent
            color: "dimgray"
            opacity: 0.5
        }

        onAboutToShow: {
            popup.open()
        }

        onAboutToHide: {
            popup.close()
        }

        AppLauncher {
            id: appLauncher
            anchors.fill: parent
        }
    }
}
