import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

import "util.js" as UTIL

Control
{
    id: control
    width: 200
    height: 200

    property var system: null
    property int year
    property int month: 1
    property Component delegate: Item {}
    property Component highlight: Item {}
    property double cell_width: 48
    property double cell_height: 48
    property int selected_days: 0

    property var start_date: ({})
    property var end_date: ({})

    function index_of_day(day)
    {
        return UTIL.find_in_model(day_model, (item) => {
                                      return item.day === day;
                                  });
    }

    function select_day(day, single_select=false)
    {
        const index = index_of_day(day);
        if (index > -1)
        {
            if (single_select)
                deselect();
            day_model.setProperty(index, "selected", true);
            control.selected_days += 1;
        }

    }


    function select_range(start, end)
    {
        const start_index = index_of_day(start);
        const end_index = index_of_day(end);
        for (let counter = start_index; counter <= end_index; counter++)
        {
            day_model.setProperty(counter, "selected", true);
        }
        control.selected_days += (end_index - start_index);
    }

    function deselect()
    {
        for (let counter = 0; counter < day_model.count; counter++)
            day_model.setProperty(counter, "selected", false);
        control.selected_days = 0;
    }

    function calculate_select()
    {
        const days_in_month = system.days_in_month(month, year);
        let temp = system.to_gregorian(control.start_date.year, control.start_date.month, control.start_date.day);
        const qdate_start_date = new Date(temp.year, temp.month, temp.day);
        temp = system.to_gregorian(control.end_date.year, control.end_date.month, control.end_date.day);
        const qdate_end_date = new Date(temp.year, temp.month, temp.day);
        temp = system.to_gregorian(control.year, control.month, 1);
        const qdate_source_date = new Date(temp.year, temp.month, temp.day);

        if (control.year === control.start_date.year &&
                control.year === control.end_date.year &&
                control.month === control.start_date.month &&
                control.month === control.end_date.month)
        {
            select_range(control.start_date.day, control.end_date.day);
            return;
        }

        if (control.year === control.start_date.year &&
            control.month === control.start_date.month)
        {
            select_range(control.start_date.day, days_in_month);
            return;
        }

        if (control.year === control.end_date.year &&
            control.month === control.end_date.month)
        {
            select_range(1, control.end_date.day);
            return;
        }

        if (system.is_between(qdate_source_date, qdate_start_date, qdate_end_date))
        {
            select_range(1, days_in_month);
            return;
        }
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
                                     id: counter,
                                     selected: false
                                 });
                counter++;
            }
        }

        if (Object.keys(start_date).length && Object.keys(end_date).length)
            calculate_select();
    }

    Component.onCompleted:
    {
        if (day_model.count)
            deselect();
        get_model();
    }

    onStart_dateChanged:
    {
        if (day_model.count)
            deselect();
    }

    onEnd_dateChanged:
    {
        if (day_model.count && Object.keys(control.end_date).length)
            calculate_select();
    }

    ListModel
    {
        id: day_model
    }

    GridView
    {
        id: grid
        cellWidth: control.cell_width
        cellHeight: control.cell_height
        anchors.fill: parent
        model: day_model
        delegate: Item {
            Loader
            {
                sourceComponent: control.highlight
                active: model.selected
                property var dataModel: model
            }
            Loader
            {
                sourceComponent: control.delegate
                property var dataModel: model
            }
        }
    }
}
