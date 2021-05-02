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
                onCurrentValueChanged:
                {
                    year_month_dialog.locale = Qt.locale(currentValue);
                }
            }
        }

        Button
        {
            text: "Open Year Month Dialog"
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                year_month_dialog.open()
            }
        }

        Label
        {
            id: output
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            font.pointSize: 20
        }
    }

    YearMonthDialog
    {
        id: year_month_dialog
        from: 1350
        to: 2030

        system: CalendarSystem {
            id: calendar_system
            type: calendar_system_combo.currentValue
            locale: year_month_dialog.locale
        }

        onFinished:
        {
            if (result === YearMonthDialog.Accepted)
                output.text = `${selected_date.year}/${selected_date.month}, ${selected_date.month_name}`;
        }
    }
}
