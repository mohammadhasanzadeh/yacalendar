import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import yacalendar 1.0

Item
{
    id: control
    width: row.width
    height: 50
    z: 1000

    property RangeCalendarDialog target: parent
    property int selected_quarter: -1

    enum Range {
        Q1 = 1,
        Q2 = 2,
        Q3 = 3,
        Q4 = 4
    }

    // q represent of Quarter of year
    function calculate_range(q)
    {
        const current_year = target.system.today().year;
        const end_month = calculate_end_month(q);
        const start_date = {
            year: current_year,
            month: end_month - 2,
            day: 1
        };

        const end_date = {
            year: current_year,
            month: end_month,
            day: target.system.days_in_month(end_month, current_year)
        };
        target.select_range(start_date, end_date);
    }

    // return end_month based on quarter of year
    function calculate_end_month(q) {
        switch(q)
        {
        case QuarterRangeAccess.Range.Q1:
            return 3;
        case QuarterRangeAccess.Range.Q2:
            return 6;
        case QuarterRangeAccess.Range.Q3:
            return 9;
        case QuarterRangeAccess.Range.Q4:
            return 12;
        default:
            throw 'is not valid value for quarter!\nA quarter refers to one-fourth of a year.';
        }
    }

    function quarter_none()
    {
        control.selected_quarter = -1
    }

    Row
    {
        id: row

        Repeater
        {
            id: repeater
            model: ["Q1", "Q2", "Q3", "Q4"]
            delegate: RoundButton {
                width: 50
                height: 48
                text: modelData
                Material.background: Material.color(index, Material.Shade200)
                highlighted: true
                flat: false
                onClicked:
                {
                    calculate_range(index + 1);
                    control.selected_quarter = index;
                }
            }
        }
    }
}
