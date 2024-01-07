import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

import yacalendar 1.0

Item
{
    ColumnLayout
    {
        anchors.centerIn: parent
        width: parent.width

        Button
        {
            text: "Open YearPicker Dialog"
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                year_picker_dialog.open()
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

   CalendarSystem
   {
        id: calendar_system
        type: CalendarSystem.Jalali
   }

    YearPickerDialog
    {
        id: year_picker_dialog
        from: 1350
        to: 2030
        selected_year: calendar_system.today().year

        onFinished:
        {
            if (result === YearMonthDialog.Accepted)
                output.text = selected_year;
        }
    }
}
