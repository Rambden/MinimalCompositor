import QtQuick 2.0
import QtWayland.Compositor 1.0

ShellSurfaceItem {
    id: chrome

    property bool isChild: parent.shellSurface !== undefined
    property bool isFullscreen: false
    property bool active: false

    signal destroyAnimationFinished
    signal activated(var shellSurface)

    // Do not steal focus and activate on tap, preventing undesired window switches
    //    focusOnClick: false
    onSurfaceDestroyed: {
        bufferLocked = true
        destroyAnimation.start()
    }

    onActiveFocusChanged: {
        console.log("Active focus: " + activeFocus)
        if (activeFocus) {
            activated(shellSurface)
        }
    }

    Connections {
        target: shellSurface

        // some signals are not available on wl_shell, so let's ignore them
        ignoreUnknownSignals: true

        onChildrenChanged: {
            console.log("children: " + shellSurface.title + ", " + shellSurface.children.count)
        }

        onActivatedChanged: {
            // xdg_shell only
            console.log("onActivatedChanged: " + shellSurface.title + ", " + shellSurface.activated)
            activated(shellSurface)
        }

        onSetFullScreen: {
            console.log("SetFullscreen!")
            chrome.isFullscreen = true
        }
    }

    SequentialAnimation {
        id: destroyAnimation
        NumberAnimation {
            target: chrome
            property: "opacity"
            //            to: chrome.isChild ? 0 : 1
            to: 0
            duration: 150
        }
        ScriptAction {
            script: destroyAnimationFinished()
        }
    }
}
