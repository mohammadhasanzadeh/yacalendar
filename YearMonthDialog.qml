import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import Qt.labs.calendar 1.0 as LAB
import QtQuick.Layouts 1.12

import yacalendar 1.0

import "util.js" as UTIL

Dialog
{
    id: control

    width: {
        const width_size = parent.width * 0.6;
        if (width_size <= 300)
            return 300;
        else if (width_size >= 400)
            return 400;
        return width_size;
    }

    height: {
        const height_size = parent.height * 0.5;
        if (height_size <= 350)
            return 350;
        else if (height_size >= 450)
            return 450;
        return height_size;
    }

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    dim: true
    modal: true
    clip: true
    topPadding: 0
    leftPadding: 5
    rightPadding: 5
    bottomPadding: 5
    closePolicy: Dialog.CloseOnEscape
    standardButtons: Dialog.Ok | Dialog.Cancel

    property CalendarSystem system: CalendarSystem {
        type: CalendarSystem.Gregorian
        locale: control.locale
    }

    property var today: control.system.today();
    property ListModel month_range: ListModel {}
    property int from: 1980
    property int to: 2030
    property int selected_month: -1
    property int selected_year: -1

    signal finished(int result, var selected_date)

    Component.onCompleted:
    {
        generate_month_range(today.year);
    }

    function generate_month_range(year)
    {
        month_range.clear();
        const numbers_of_month = control.system.months_in_year(year);
        for (let counter = 1; counter <= numbers_of_month;  counter++)
        {
            let month_name = control.system.month_name(counter, year);
            month_range.append({
                                   "id": counter,
                                   "name": month_name
                               });
        }
        const index_month = UTIL.find_in_model(month_gridview.model, (item) => {
                                                   let key = (selected_month < 0) ? today.month : selected_month
                                                   return item.id ===  key;
                                               });
        month_gridview.currentIndex = index_month;
    }

    header: Rectangle {
        id: header
        height: parent.height * 0.25
        color: Material.accent

        Label
        {
            id: title
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 8
            color: "white"
            text: qsTr("SELECT A DATE")
            font.pointSize: 9
        }

        Label
        {
            id: date_lbl
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 8
            anchors.leftMargin: 16
            font.pointSize: 15
            font.bold: true
            color: "white"
            text:
            {
                if (!control.opened)
                    return "";
                const year = year_combo.currentText;
                const month_name = month_gridview.model.get(month_gridview.currentIndex).name;
                return `${year}, ${month_name}`;
            }
        }
    }

    ColumnLayout
    {
        id: container
        anchors.fill: parent
        spacing: 0

        GridCombobox
        {
            id: year_combo
            flat: true
            width: 170
            padding: 0
            popup.width: container.width
            popup.height: container.height
            cell_width: ((container.width - 10) / 3)
            cell_height: 35
            textRole: "number"
            indicator.rotation: (down) ? 180 : 0
            Material.theme: control.Material.Dark

            model: RangeModel {
                from: control.from
                to: control.to
            }

            delegate: ItemDelegate {
                width: year_combo.cell_width
                height: year_combo.cell_height
                background: Rectangle {
                    color: "transparent"
                }

                Label
                {
                    anchors.centerIn: parent
                    text: model.number
                    color: (year_combo.highlightedIndex === index) ? "white" : Material.foreground
                }
            }

            highlight: Rectangle {
                color: Material.accent
                radius: (width / 4)
            }

            onCurrentIndexChanged:
            {
                const year = year_combo.model.get(currentIndex).number;
                generate_month_range(year);
                year_combo.displayText = year;
            }
        }

        GridView
        {
            id: month_gridview
            model: month_range
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: ((container.width - 10) / 3)
            cellHeight: 35
            clip: true

            delegate: ItemDelegate
            {
                width: month_gridview.cellWidth
                height: month_gridview.cellHeight
                Label
                {
                    anchors.centerIn: parent
                    text: model.name
                }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: {
                        month_gridview.currentIndex = index;
                        control.selected_month = index + 1;
                    }
                }
            }

            highlight: Rectangle {
                color: Material.accent
                radius: (width / 4)
            }
        }
    }

    onOpened:
    {
        if (control.opened)
        {
            const index_year = year_combo.find((selected_year < 0 ) ? today.year : selected_year);
            year_combo.currentIndex = index_year;
            year_combo.displayText = year_combo.model.get(year_combo.currentIndex).number;

            const index_month = UTIL.find_in_model(month_gridview.model, (item) => {
                                                       let key = (selected_month < 0) ? today.month : selected_month
                                                       return item.id ===  key;
                                                   });
            month_gridview.currentIndex = index_month;
        }
    }

    onAccepted:
    {
        control.selected_year = year_combo.model.get(year_combo.currentIndex).number;
        control.selected_month = month_gridview.model.get(month_gridview.currentIndex).id;
        const month_name = month_gridview.model.get(month_gridview.currentIndex).name
        const selected_date = {
            year: control.selected_year,
            month: control.selected_month,
            month_name: month_name
        }
        finished(control.result, selected_date);
    }
}
