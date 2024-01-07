import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

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

    property alias from: range_model.from
    property alias to: range_model.to
    property int selected_year
    signal finished(int result, int year)

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
            text: qsTr("SELECT A YEAR")
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
            text: (grid_view.currentIndex > -1) ? range_model.get(grid_view.currentIndex).number : ""
        }
    }

    RangeModel
    {
        id: range_model
        from: 1980
        to: 2030
    }

    GridView
    {
        id: grid_view
        anchors.fill: parent
        clip: true
        implicitHeight: contentHeight
        cellWidth: ((grid_view.width - 10) / 3)
        cellHeight: 35
        highlightFollowsCurrentItem: true
        ScrollIndicator.vertical: ScrollIndicator { }
        model: range_model
        delegate: ItemDelegate {
            width: grid_view.cellWidth
            height: grid_view.cellHeight
            background: Rectangle {
                color: "transparent"
            }
            Label
            {
                anchors.centerIn: parent
                text: model.number
                color: (grid_view.currentIndex === model.index) ? "white" : Material.foreground
            }

            onClicked:
            {
                grid_view.currentIndex = model.index;
            }
        }

        highlight: Rectangle {
            color: Material.accent
            radius: (width / 4)
        }
    }


    onOpened:
    {
        if (control.opened)
        {
            if (control.selected_year < control.from || control.selected_year > control.to)
                return;
            const year_index = UTIL.find_in_model(range_model, (item) => {return item.number === control.selected_year});
            grid_view.currentIndex = year_index;
            grid_view.positionViewAtIndex(year_index, GridView.Center);
        }
    }

    onAccepted:
    {
        control.selected_year = range_model.get(grid_view.currentIndex).number;
        control.finished(control.result, control.selected_year);
    }
}
