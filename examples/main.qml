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
    Material.accent: Material.theme === Material.Light ? Material.color(Material.DeepPurple, Material.Shade700)
                                                       : Material.color(Material.Red, Material.Shade400)

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

        DatePickerPage
        { }

        YearMonthPage
        { }

        onCurrentIndexChanged:
        {
            switch (currentIndex)
            {
            case 0:
                root.title_value = "Calendar Dialog";
                break;
            case 1:
                root.title_value = "YearMonth Dialog";
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
