import QtQuick 2.0
import QtWayland.Compositor 1.1

ListModel {
    id: shellSurfaceItems

    function addSurface(surface) {
        var index = indexOf(surface)
        if (index >= 0) {
            remove(index)
        }
        shellSurfaceItems.append({
                                     "shellSurface": surface
                                 })
    }

    function removeSurface(surface) {
        var index = indexOf(surface)
        if (index >= 0) {
            shellSurfaceItems.remove(index)
        } else {
            console.warn("Failed to remove " + surface)
        }
    }

    function indexOf(surface) {
        for (var i = 0; i < shellSurfaceItems.count; ++i) {
            if (shellSurfaceItems.get(i).shellSurface === surface) {
                return i
            }
        }
        console.warn("Failed to find index of " + surface)
        return -1
    }

    function bringToFront(waylandSurface) {
        var index = indexOf(waylandSurface)
        if (index >= 0) {
            shellSurfaceItems.move(index, shellSurfaceItems.count - 1, 1)
        } else {
            console.warn("Failed to move " + surface)
        }
    }
}
