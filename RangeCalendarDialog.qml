import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import Qt.labs.calendar 1.0 as LAB

import yacalendar 1.0
import "util.js" as UTIL

Dialog
{
    id: control
    width: (parent.width * 0.95 > 500) ? 500 : parent.width * 0.95
    height: parent.height * 0.95
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    dim: true
    modal: true
    clip: true
    topPadding: 0
    leftPadding: 5
    rightPadding: 5
    bottomPadding: 5
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Dialog.CloseOnEscape

    property CalendarModel model: CalendarModel {
        from: new Date(2000, 1, 1)
        to: new Date(2020, 12, 1)
    }

    property CalendarSystem system: CalendarSystem {
        type: CalendarSystem.Gregorian
        locale: control.locale
    }

    property var today: control.system.today();
    property var day_headers: []
    property bool show_current_month: true
    property bool auto_reset: true
    readonly property alias start_date: private_props.m_start_date
    readonly property alias end_date: private_props.m_end_date
    readonly property alias currnet_month: private_props.m_current_month

    signal finished(int result, var range_date)

    function is_current_date(item, date)
    {
        if (!Object.keys(date).length)
            return false;
        return (
                    item.day === date.day &&
                    item.month === date.month &&
                    item.year === date.year &&
                    item.index === date.index
                    );
    }

    onLocaleChanged:
    {
        control.day_headers = UTIL.get_day_headers(control.locale);
    }

    onAccepted:
    {
        if (!Object.keys(control.start_date).length || !Object.keys(control.end_date).length)
        {
            rejected();
            return;
        }

        var range_date = {
            start_date: Object.assign({}, control.start_date),
            end_date: Object.assign({}, control.end_date),
        }
        finished(control.result, range_date);
    }

    onRejected:
    {
        finished(control.result, {});
    }

    onReset:
    {
        private_props.m_start_date = {};
        private_props.m_end_date = {};
        private_props.select_flag = false;
    }

    onClosed:
    {
        if (control.auto_reset)
            reset();
    }

    QtObject
    {
        id: private_props
        property bool select_flag: false
        property int m_current_month: -1
        property var m_start_date: ({})
        property var m_end_date: ({})
    }

    header: Rectangle {
        id: header
        height: 120
        color: Material.accent

        ToolButton
        {
            id: clear_btn
            icon.source: "qrc:/resource/close.svg"
            icon.color: "white"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 8

            onClicked:
            {
                reset();
            }
        }

        Label
        {
            text: "SELECTED RANGES"
            color: "white"
            anchors.left: clear_btn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
        }

        Row
        {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            Label
            {
                font.pointSize: 17
                font.bold: true
                color: "white"
                text: Object.keys(control.start_date).length ? `${control.system.month_name(control.start_date.month, Locale.ShortFormat)} ${control.start_date.day}` : ""
            }

            Label
            {
                font.pointSize: 17
                font.bold: true
                color: "white"
                text: "-"
            }

            Label
            {
                font.pointSize: 17
                font.bold: true
                color: "white"
                text: Object.keys(control.end_date).length ? `${control.system.month_name(control.end_date.month, Locale.ShortFormat)} ${control.end_date.day}` : ""
            }
        }
    }

    contentItem: Page {
        id: container_page
        header: Item {
            id: action_bar
            clip: false
            height: 30

            GridCombobox
            {
                id: grid_combo
                flat: true
                width: 170
                padding: 0
                popup.width: parent.width
                popup.height: container_page.height
                cell_width: ((parent.width - 10) / 3)
                cell_height: 35
                textRole: "number"
                currentIndex: 0
                indicator.rotation: (down) ? 180 : 0
                Material.theme: control.Material.theme

                displayText: {
                    if (listview.currentIndex === -1)
                        return;
                    const current_date = control.model.model.get(listview.currentIndex)
                    return `${control.system.month_name(current_date.month)} ${current_date.year}`
                }

                model: RangeModel {
                    from: control.model.from.getFullYear()
                    to: control.model.to.getFullYear()
                }

                delegate: ItemDelegate {
                    width: grid_combo.cell_width
                    height: grid_combo.cell_height
                    background: Rectangle {
                        color: "transparent"
                    }

                    Label
                    {
                        anchors.centerIn: parent
                        text: model.number
                        color: (grid_combo.highlightedIndex === index) ? "white" : Material.foreground
                    }
                }

                highlight: Rectangle {
                    color: Material.accent
                    radius: (width / 4)
                }

                onCurrentIndexChanged:
                {
                    const index = control.model.index_of(
                                    grid_combo.model.get(currentIndex).number,
                                    private_props.m_current_month
                                    );
                    listview.positionViewAtIndex(index, ListView.SnapToItem);
                }
            }

            Row
            {
                anchors.right: parent.right
                anchors.verticalCenter: grid_combo.verticalCenter
                visible: !grid_combo.down
                ToolButton
                {
                    id: prev_btn
                    icon.source: "qrc:/resource/left.svg"
                    onClicked: listview.decrementCurrentIndex();
                    Material.accent: Material.foreground
                    highlighted: true
                }

                ToolButton
                {
                    id: next_btn
                    icon.source: "qrc:/resource/right.svg"
                    onClicked: listview.incrementCurrentIndex();
                    Material.accent: Material.foreground
                    highlighted: true
                }
            }
        }

        LAB.DayOfWeekRow
        {
            id: days_of_week
            locale: control.locale
            width: parent.width
            delegate: Label {
                text: model.narrowName
                horizontalAlignment: Label.AlignHCenter
                width: (days_of_week.width / 7) - 1
            }
        }

        ListView
        {
            id: listview
            anchors.top: days_of_week.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            orientation: ListView.Horizontal
            highlightFollowsCurrentItem: true
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            model: control.opened ? control.model.model : undefined

            onModelChanged:
            {
                if (!control.show_current_month)
                    return 0;
                const index = control.model.index_of(control.today.year, control.today.month);
                listview.positionViewAtIndex(index, ListView.snapMode);
            }

            delegate: MonthGrid {
                id: month_grid
                clip: true
                year: model.year
                month: model.month
                width: listview.width
                height: listview.height
                system: control.system
                padding: 0
                cell_width: (listview.width / 7) - 0.1
                cell_height: cell_width
                start_date: control.start_date
                end_date: control.end_date

                states: [
                    State {
                        name: "is_currnet_month"
                        when: (listview.currentIndex === index)
                        PropertyChanges
                        {
                            target: private_props
                            m_current_month: month_grid.month
                        }
                    }
                ]

                highlight: Rectangle {
                    id: highlight_rect
                    height: month_grid.cell_height
                    color: Material.highlightedRippleColor
                    states: [
                        State {
                            name: "start_date"
                            when: control.is_current_date(dataModel, control.start_date)
                            PropertyChanges
                            {
                                target: highlight_rect
                                visible: month_grid.selected_days > 1
                                width: month_grid.cell_width / 2
                                x: month_grid.cell_width / 2
                            }
                        },
                        State
                        {
                            name: "end_date"
                            when: control.is_current_date(dataModel, control.end_date)
                            PropertyChanges
                            {
                                target: highlight_rect
                                visible: true
                                width: month_grid.cell_width / 2
                                x: 0
                            }
                        },
                        State
                        {
                            name: "selected"
                            when: dataModel.selected
                            PropertyChanges
                            {
                                target: highlight_rect
                                visible: true
                                x: 0
                                width: month_grid.cell_width
                            }
                        },
                        State {
                            name: "today"
                            when: (dataModel.year === control.today.year && dataModel.month === control.today.month && dataModel.day === control.today.day)
                            PropertyChanges
                            {
                                target: highlight_rect
                                visible: false
                            }
                        }
                    ]
                }

                delegate: Item {
                    width: month_grid.cell_width
                    height: month_grid.cell_height
                    opacity: (dataModel.in_month) ? 1 : 0

                    states: [
                        State
                        {
                            name: "start_date"
                            when: control.is_current_date(dataModel, control.start_date)
                            PropertyChanges
                            {
                                target: background_rect
                                border.width: 3
                                border.color: Material.background
                                color: Material.accent
                                visible: true
                            }
                            PropertyChanges
                            {
                                target: day_label
                                color: "white"
                            }
                        },
                        State
                        {
                            name: "today"
                            when: (dataModel.year === control.today.year && dataModel.month === control.today.month && dataModel.day === control.today.day)
                            PropertyChanges
                            {
                                target: background_rect
                                border.width: 1
                                border.color: Material.foreground
                                color: Material.background
                                visible: true
                            }
                        },
                        State
                        {
                            name: "end_date"
                            extend: "start_date"
                            when: control.is_current_date(dataModel, control.end_date)
                        },
                        State
                        {
                            name: "selected"
                            when: dataModel.selected
                            PropertyChanges
                            {
                                target: background_rect
                                visible: false
                            }
                            PropertyChanges
                            {
                                target: day_label
                                color: Material.foreground
                            }
                        },
                        State
                        {
                            name: "deslect"
                            extend: "selected"
                            when: !dataModel.selected
                        }
                    ]

                    Rectangle
                    {
                        id: background_rect
                        anchors.fill: parent
                        radius: width / 2
                    }

                    Label
                    {
                        id: day_label
                        anchors.centerIn: parent
                        text: dataModel.day
                        color: Material.foreground
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            if (!dataModel.in_month)
                                return;

                            if (private_props.select_flag)
                            {
                                private_props.m_end_date.day = dataModel.day;
                                private_props.m_end_date.month = dataModel.month;
                                private_props.m_end_date.year = dataModel.year;
                                private_props.m_end_date.index = dataModel.index;
                                if (!UTIL.is_lower_equal_than(control.system, control.start_date, control.end_date))
                                {
                                    const temp = private_props.m_start_date;
                                    private_props.m_start_date = private_props.m_end_date;
                                    private_props.m_end_date = temp;
                                }
                                private_props.m_end_dateChanged();
                                private_props.select_flag = false;
                                return;
                            }
                            private_props.m_start_date.day = dataModel.day;
                            private_props.m_start_date.month = dataModel.month;
                            private_props.m_start_date.year = dataModel.year;
                            private_props.m_start_date.index = dataModel.index;
                            private_props.m_start_dateChanged();
                            private_props.m_end_date = {};
                            private_props.m_end_dateChanged();
                            month_grid.select_day(dataModel.day);
                            private_props.select_flag = true;
                        }
                    }
                }
            }
        }
    }
}
