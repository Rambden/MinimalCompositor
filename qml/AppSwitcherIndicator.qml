import QtQuick 2.3
import QtQuick.Controls 2.0

PageIndicator {
    id: indicator
    delegate: Rectangle {
        implicitWidth: window.pixDens * 1.5
        implicitHeight: window.pixDens * 1.5
        radius: width / 2
        color: "dark gray"
        opacity: index === indicator.currentIndex ? 0.95 : pressed ? 0.7 : 0.45
        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }
}
