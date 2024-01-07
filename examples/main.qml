import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.12

import yacalendar 1.0

ApplicationWindow
{
    id: root
    visible: true
    width: 420
    height: 680
    title: qsTr("Example")

    property string title_value: "Calendar Dialog"
    Material.theme: themeSwitch.checked ? Material.Dark : Material.Light

    header: ToolBar {
        Label
        {
            text: root.title_value
            elide: Label.ElideRight
            anchors.centerIn: parent
        }
        Switch
        {
            id: themeSwitch
            anchors.right: parent.right
            text: "Dark"
        }
    }

    SwipeView
    {
        id: swipe_view
        currentIndex: 0
        anchors.fill: parent

        DatePickerPage {}
        DateRangePickerPage {}
        YearMonthPage {}
        YearPickerPage{}

        onCurrentIndexChanged:
        {
            switch (currentIndex)
            {
            case 0:
                root.title_value = "CalendarDialog";
                break;
            case 1:
                root.title_value = "RangeDialog";
                break;
            case 2:
                root.title_value = "YearMonthDialog";
                break;
            case 3:
                root.title_value = "YearPickerDialog";
                break;
            default:
                root.title_value = "undefined";
                break;
            }
        }
    }

    PageIndicator
    {
        count: swipe_view.count
        currentIndex: swipe_view.currentIndex
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
