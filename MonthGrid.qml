import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

Control
{
    id: control
    property var system: null
    property int year
    property int month: 1
    property Component delegate
    property Component highlight
    property double cell_wdith: 48
    property double cell_height: 48
    property alias current_index: grid.currentIndex

    function index_of_day(day)
    {
        return private_props.find_in_model(day_model, (item) => {
                                        return (item.day === day)
                                    });
    }

    function select_day(day)
    {
        const index = index_of_day(day);
        if (index > -1)
            grid.currentIndex = index;
    }

    width: 200
    height: 200

    ListModel
    {
        id: day_model
    }

    QtObject
    {
        id: private_props
        function find_in_model(model, criteria, return_object=false)
        {
            for (let counter = 0; counter < model.count; ++counter)
            {
                if (criteria(model.get(counter)))
                    return (return_object) ? model.get(counter) : counter;
            }
            return (return_object) ? null : -1;
        }
    }

    Component.onCompleted:
    {
        get_model();
    }

    function get_offset(first_day_of_week, first_day_of_month)
    {
        let offset = 0
        while (first_day_of_week !== first_day_of_month)
        {
            first_day_of_week = (first_day_of_week === 6) ? 0 : first_day_of_week += 1;
            offset++;
        }
        return offset;
    }

    function get_model()
    {
        if (!system)
            return;
        day_model.clear();
        const first_day_of_month = control.system.first_day_of_month(month, year).getDay();
        const first_day_of_week = control.locale.firstDayOfWeek;
        const days_in_month = system.days_in_month(month, year);
        const offset = get_offset(first_day_of_week, first_day_of_month);
        const max_days_in_month = (days_in_month + (offset - 1));

        let counter = 0;
        for (let row_count = 1; row_count <= 6; row_count++)
        {
            for (let day_count = 1; day_count <= 7; day_count++)
            {
                day_model.append({
                                in_month: (counter >= offset && counter <= max_days_in_month),
                                year: control.year,
                                month: control.month,
                                start_day: (counter === offset),
                                day: (counter - offset) + 1,
                           });
                counter++;
            }
        }
    }

    GridView
    {
        id: grid
        delegate: control.delegate
        cellWidth: control.cell_wdith
        cellHeight: control.cell_height
        anchors.fill: parent
        model: day_model
        highlight: control.highlight
    }
}
