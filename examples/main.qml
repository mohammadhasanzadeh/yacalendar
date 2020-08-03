import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

import yacalendar 1.0

Window
{
    visible: true
    width: 420
    height: 680
    title: qsTr("Hello World")

    Column
    {
        Label
        {
            text: "Convert Jalali to gregorian:"
        }

        Row
        {
            Button
            {
                id: jalali_calendar_btn
                text: "Select Date"

                onClicked:
                {
                    jalali_calendar.open();
                }
            }

            Label
            {
                id: jalali_date_lbl
                anchors.verticalCenter: jalali_calendar_btn.verticalCenter
                onTextChanged:
                {
                    gregorian_result_lbl.text = `Result: ${jalali_system.to_gregorian(jalali_date_lbl.text, '-', "yyyy-MM-dd")}`;
                }
            }
        }

        Label
        {
            id: gregorian_result_lbl
            color: "red"
        }


        Label
        {
            text: "Convert Gregorian to Jalali:"
        }

        Row
        {
            Button
            {
                id: gregorian_calendar_btn
                text: "Select Date"

                onClicked:
                {
                    gregorian_calendar.open();
                }
            }

            Label
            {
                id: gregorian_date_lbl
                anchors.verticalCenter: gregorian_calendar_btn.verticalCenter
                onTextChanged:
                {
                    jalali_result_lbl.text = `Result: ${jalali_system.to_system_date(gregorian_date_lbl.text, "yyyy-M-d", '/')}`;
                }
            }
        }

        Label
        {
            id: jalali_result_lbl
            color: "red"
        }
    }

    CalendarDialog
    {
        id: jalali_calendar
        locale: Qt.locale("fa_IR")
        model: CalendarModel {
            from: new Date(1350, 1, 1)
            to: new Date(1450, 12, 1)
        }

        system: CalendarSystem {
            id: jalali_system
            type: CalendarSystem.Jalali
            locale: jalali_calendar.locale
        }

        onFinished:
        {
            if (result === CalendarDialog.Accepted)
                jalali_date_lbl.text = `${selected_date.year}-${selected_date.month}-${selected_date.day}`;
        }
    }


    CalendarDialog
    {
        id: gregorian_calendar
        locale: Qt.locale("en_US")
        Material.theme: Material.Dark

        model: CalendarModel {
            from: new Date(2000, 1, 1)
            to: new Date(2020, 12, 1)
        }

        system: CalendarSystem {
            type: CalendarSystem.Gregorian
            locale: gregorian_calendar.locale
        }

        onFinished:
        {
            if (result === CalendarDialog.Accepted)
                gregorian_date_lbl.text = `${selected_date.year}-${selected_date.month}-${selected_date.day}`;
        }
    }
}
