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

    header: Rectangle {
        id: header
        height: 120
        color: Material.accent
        Label
        {
            id: title
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 8
            color: "white"
            text: qsTr("SELECT DATE")
            font.pointSize: 9
        }

        Label
        {
            id: date_lbl
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 8
            anchors.leftMargin: 16
            font.pointSize: 17
            font.bold: true
            color: "white"
            text:
            {
                if (!control.opened)
                    return "-";
                const day_index = (selected_day_index > -1) ? selected_day_index % 7 : 0;
                const day_name = control.locale.dayName(control.day_headers[day_index], Locale.ShortFormat)
                return `${day_name}, ${control.system.month_name(control.selected_month)}, ${selected_day}`
            }
        }
    }

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
    property int selected_day: -1
    property int selected_month: -1
    property int selected_year: -1
    property int selected_day_index: -1

    signal finished(int result, var selected_date)

    function format(date, sperator = '-')
    {
        return `${date.year}${sperator}${date.month}${sperator}${date.day}`
    }

    onLocaleChanged:
    {
        control.day_headers = UTIL.get_day_headers(control.locale);
    }

    onOpened:
    {
        if (opened)
        {
            listview.model = control.model.model;
        }
    }

    onClosed:
    {
        selected_year = selected_month = selected_day = -1;
        listview.model = undefined;
    }

    onAccepted:
    {
        const selected_date = {
            year: control.selected_year,
            month: control.selected_month,
            day: control.selected_day
        };
        finished(control.result, selected_date);
    }

    onRejected:
    {
        finished(control.result, {});
    }

    Item
    {
        id: container
        anchors.fill: parent

        Item
        {
            id: action_bar
            width: container.width
            height: 30

            GridCombobox
            {
                id: grid_combo
                flat: true
                width: 170
                padding: 0
                popup.width: container.width
                popup.height: container.height
                cell_width: ((container.width - 10) / 3)
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
                                    selected_month
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
            width: container.width
            anchors.top: action_bar.bottom
            anchors.topMargin: 16
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
            anchors.left: container.left
            anchors.right: container.right
            anchors.bottom: container.bottom
            orientation: ListView.Horizontal
            highlightFollowsCurrentItem: true
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange

            onModelChanged:
            {
                if (!show_current_month)
                    return 0;
                const today = control.system.today();
                const index = control.model.index_of(today.year, today.month);
                listview.positionViewAtIndex(index, ListView.snapMode);
            }

            delegate: MonthGrid {
                id: month_grid
                clip: true
                year: model.year
                month: model.month
                width: container.width
                height: container.height - (footer.height + control.bottomPadding)
                system: control.system
                padding: 0
                cell_width: (container.width / 7) - 0.1
                cell_height: cell_width

                property bool is_current_item: ListView.isCurrentItem

                onIs_current_itemChanged:
                {
                    if (!is_current_item)
                    {
                        return;
                    }

                    if (model.year === selected_year && model.month === selected_month && selected_day > -1)
                    {
                        month_grid.select_day(control.selected_day, true);
                        return;
                    }

                    if (selected_year === -1 && selected_month === -1 && selected_day === -1)
                    {
                        const today = control.system.today();
                        if (today.year !== month_grid.year && today.month !== month_grid.month)
                            return;
                        month_grid.select_day(today.day, true);
                        selected_day_index = month_grid.index_of_day(today.day);
                        selected_month = today.month;
                        selected_year = today.year;
                        selected_day = today.day;
                    }
                }

                highlight: Rectangle {
                    radius: (width / 2)
                    color: Material.accent
                    width: month_grid.cell_width
                    height: month_grid.cell_height
                }

                delegate: Rectangle {
                    width: month_grid.cell_width
                    height: month_grid.cell_height
                    opacity: (dataModel.in_month) ? 1 : 0
                    radius: (width /2)
                    color: "transparent"
                    border.color: Material.foreground
                    border.width: (
                                      month_grid.is_current_item &&
                                      !dataModel.selected &&
                                      control.today.year === month_grid.year &&
                                      control.today.month === month_grid.month &&
                                      control.today.day === dataModel.day
                                      )
                    Label
                    {
                        anchors.centerIn: parent
                        text: dataModel.day
                        color: (dataModel.selected) ? "white" : Material.foreground
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: {
                            if (!dataModel.in_month)
                                return;
                            control.selected_day = dataModel.day;
                            control.selected_month = dataModel.month;
                            control.selected_year = dataModel.year;
                            control.selected_day_index = dataModel.index;
                            month_grid.select_day(control.selected_day, true);
                        }
                    }
                }
            }
        }
    }
}
