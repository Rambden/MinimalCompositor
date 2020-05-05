import QtQuick 2.7
import QtQuick.Controls 2.0

Pane {
    id: root

    background: Rectangle {
        color: "transparent"
    }
    property var appPages: []

    property real itemWidth: window.pixDens * 24
    property real itemHeight: window.pixDens * 36
    property real itemSpacing: window.pixDens * 5
    property int columns: width / (itemWidth + itemSpacing)
    property int rows: height / (itemHeight + itemSpacing)

    onWidthChanged: {
        columns = width / (itemWidth + itemSpacing)
        refresh()
    }

    onHeightChanged: {
        rows = height / (itemHeight + itemSpacing)
        refresh()
    }

    function refresh() {
        var page = 0
        var itemsPerPage = rows * columns
        console.log("itemsPerPage: " + itemsPerPage)

        appPages = []
        appPages[page] = []

        pageRepeater.model = 0
        for (var i in appModel) {
            if (appPages[page].length >= itemsPerPage)
                page++

            if (!appPages[page])
                appPages[page] = []

            var app = appModel[i]
            appPages[page].push(app)
        }

        pageRepeater.model = appPages.length
    }

    function exec(program) {
        console.debug("Exec: " + program)
        proc.start(program)
    }

    Component.onCompleted: {
        refresh()
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.centerIn: parent

        //        snapMode: ListView.SnapToItem
        orientation: ListView.Horizontal
        spacing: itemSpacing

        property int selectedIndex: 0

        function select(index) {
            selectedIndex = index
        }

        onFocusChanged: {
            if (focus) {
                select(0)
            }
        }

        Repeater {
            id: pageRepeater
            model: appPages.length

            Item {
                id: pageContainer
                function count() {
                    return page.length
                }

                property var page: appPages[index]

                Grid {
                    spacing: window.pixDens * 5
                    anchors.centerIn: parent
                    columns: root.columns
                    rows: root.rows
                    columnSpacing: root.itemSpacing
                    rowSpacing: root.itemSpacing
                    horizontalItemAlignment: Grid.AlignHCenter

                    populate: Transition {
                        id: trans
                        SequentialAnimation {
                            NumberAnimation {
                                properties: "opacity"
                                from: 1
                                to: 0
                                duration: 0
                            }
                            PauseAnimation {
                                duration: (trans.ViewTransition.index
                                           - trans.ViewTransition.targetIndexes[0]) * 20
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    properties: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 600
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    properties: "y"
                                    from: trans.ViewTransition.destination.y + 50
                                    duration: 620
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Repeater {
                        model: page !== undefined ? page.length : 0

                        AppEntry {
                            app: page !== undefined ? page[index] : ["undefined", "", ""]
                            height: root.itemHeight
                            width: root.itemWidth
                            //                            padding: 10
                            selected: swipeView.selectedIndex === index
                            onHovered: {
                                swipeView.select(index)
                            }
                            onClicked: {
                                exec(app[2])
                            }
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        count: swipeView.count
        currentIndex: swipeView.currentIndex
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
