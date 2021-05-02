import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.14

import yacalendar 1.0

Item
{
    ListModel
    {
        id: calendar_system_model
        ListElement { name: "Gregorian";    system: CalendarSystem.Gregorian }
        ListElement { name: "Julian";       system: CalendarSystem.Julian }
        ListElement { name: "Milankovic";   system: CalendarSystem.Milankovic }
        ListElement { name: "Jalali";       system: CalendarSystem.Jalali }
        ListElement { name: "IslamicCivil"; system: CalendarSystem.IslamicCivil }
    }

    ListModel
    {
        id: locale_model
        ListElement { name:"fa_IR" }
        ListElement { name:"de_DE" }
        ListElement { name:"fr_FR" }
        ListElement { name:"en_US" }
    }

    ColumnLayout
    {
        anchors.centerIn: parent
        width: parent.width
        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            ComboBox
            {
                id: calendar_system_combo
                Layout.preferredWidth: 200
                model: calendar_system_model
                textRole: "name"
                valueRole: "system"
            }

            ComboBox
            {
                id: locale_combo
                Layout.preferredWidth: 100
                model: locale_model
                textRole: "name"
                valueRole: "name"
                onCurrentValueChanged: {
                    range_dialog.locale = Qt.locale(currentValue);
                }
            }
        }

        Button
        {
            text: "Open Calendar"
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                range_dialog.open()
            }
        }

        Label
        {
            id: range_lbl
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.pointSize: 20
            text: "Range: -"
        }
    }

    RangeCalendarDialog
    {
        id: range_dialog
        model: CalendarModel {
            from: new Date(1350, 1, 1)
            to: new Date(2040, 12, 1)
        }

        system: CalendarSystem {
            id: calendar_system
            type: calendar_system_combo.currentValue
            locale: range_dialog.locale
        }

        onFinished:
        {
            if (result === CalendarDialog.Accepted)
            {
                range_lbl.text = `${range_dialog.start_date.year}-\
${range_dialog.start_date.month}-${range_dialog.start_date.day} 🡢 ${range_dialog.end_date.year}-\
${range_dialog.end_date.month}-${range_dialog.end_date.day}`;
            }
        }
    }
}
