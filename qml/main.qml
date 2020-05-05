import QtQuick 2.0
import QtWayland.Compositor 1.2

WaylandCompositor {
    id: waylandCompositor

    Output {
        id: output
        compositor: waylandCompositor
    }

    TextInputManager {}

    XdgShellV5 {
        onXdgSurfaceCreated: {
            console.log("XdgShellV5: XdgSurfaceCreated")
            xdgSurface.setFullscreen(output)
            handleShellSurfaceCreated(xdgSurface)
        }
        onXdgPopupCreated: {
            console.log("XdgShellV5: XdgPopupCreated")
            handleShellSurfaceCreated(xdgSurface)
        }
    }

    XdgShellV6 {
        onToplevelCreated: {
            console.log("XdgShellV6: ToplevelCreated " + xdgSurface)
            handleShellSurfaceCreated(xdgSurface)
        }
        onPopupCreated: {
            console.log("XdgShellV6: PopupCreated " + xdgSurface)
            handleShellSurfaceCreated(xdgSurface)
        }
        onXdgSurfaceCreated: {
            console.log("XdgShellV6: XdgSurfaceCreated " + xdgSurface)
            handleShellSurfaceCreated(xdgSurface)
        }
    }

    WlShell {
        onWlShellSurfaceCreated: {
            console.log("WlShell: WlShellSurfaceCreated")
            handleShellSurfaceCreated(shellSurface)
        }
    }

    Component {
        id: shellComponent
        ShellItem {}
    }

    function handleShellSurfaceCreated(shellSurface) {
        output.surfaces.addSurface(shellSurface)
        console.log("Window type: " + shellSurface.windowType)
    }

    //    function createShellSurfaceItem(shellSurface) {
    //        var parentSurfaceItem = output.viewsBySurface[shellSurface.parentSurface]
    //        var parent = parentSurfaceItem || output.surfaceArea
    //        var item = shellComponent.createObject(parent, {
    //                                                   "shellSurface": shellSurface
    //                                               })
    //        if (parentSurfaceItem) {
    //            item.x += output.position.x
    //            item.y += output.position.y
    //        }
    //        output.viewsBySurface[shellSurface.surface] = item
    //    }
    //    function handleShellSurfaceCreated(shellSurface) {
    //        var moveItem = moveItemComponent.createObject(
    //                    defaultOutput.surfaceArea, {
    //                        "x": screens.objectAt(0).position.x,
    //                        "y": screens.objectAt(0).position.y,
    //                        "width": Qt.binding(function () {
    //                            return shellSurface.surface.width
    //                        }),
    //                        "height": Qt.binding(function () {
    //                            return shellSurface.surface.height
    //                        })
    //                    })
    //        for (var i = 0; i < screens.count; ++i)
    //            createShellSurfaceItem(shellSurface, moveItem, screens.objectAt(i))
    //    }
}
