import QtQuick 2.0
import QtQuick.Window 2.2
import QtWayland.Compositor 1.1

WaylandOutput {
    id: output

    property alias surfaces: surfaceModel
    sizeFollowsWindow: true

    window: Window {
        id: window

        property int pixDens: Math.ceil(Screen.pixelDensity) // pixels per mm
        property int scaledMargin: 5 * pixDens // 5mm
        property int fontSize: 5 * pixDens // 5mm
        visible: true
        color: "gray"

        visibility: Qt.WindowFullScreen

        ShellSurfaceModel {
            id: surfaceModel
        }

        WaylandMouseTracker {
            id: mouseTracker
            anchors.fill: parent

            windowSystemCursorEnabled: true
            Image {
                id: background
                anchors.fill: parent
                fillMode: Image.Tile
                source: "file:/usr/share/weston/pattern.png"
                smooth: true
            }
            WaylandCursorItem {
                id: cursor
                inputEventsEnabled: false
                x: mouseTracker.mouseX
                y: mouseTracker.mouseY

                seat: output.compositor.defaultSeat
            }
        }

        // Display shell surfaces stacked in list order
        Item {
            id: root
            anchors.fill: parent
            Repeater {
                id: repeater
                model: surfaceModel
                ShellItem {
                    id: shellSurfaceItem
                    opacity: 1 - launcher.position * 0.5
                    visible: true
                    shellSurface: modelData
                    onDestroyAnimationFinished: {
                        surfaceModel.remove(index)
                    }

                    transform: Translate {
                        y: (-1) * launcher.position * window.height
                    }

                    // TODO: manage focus change
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            surfaceModel.bringToFront(modelData)
                        }
                    }
                }
            }
        }

        // AppLauncher drawer and AppSwitcher popup
        Launcher {
            id: launcher
            anchors.fill: parent
            surfaceModel: surfaceModel
        }
    }
}
