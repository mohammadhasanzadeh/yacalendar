import QtQuick 2.12
import QtQml.Models 2.14

Item
{
    id: control
    property alias model: private_props.model
    property date from: new Date (1950, 1, 1)
    property date to: new Date (2050, 12, 1)

    Component.onCompleted:
    {
        init();
    }

    function index_of(year, month)
    {
        return private_props.find_in_model(private_props.model, (item) => {
                                                return (item.year === year && item.month === month);
                                           });
    }

    QtObject
    {
        id: private_props
        property ListModel model: ListModel {}
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

    function init()
    {
        if (!(from) || !(to) || (from > to))
            return;

        private_props.model.clear();
        const start_year  = from.getFullYear();
        const end_year    = to.getFullYear();


        for (let year = start_year; year <= end_year; year++)
        {
            const end_month = (year === end_year) ?  to.getMonth() : 12;
            const start_month = (year === start_year) ? from.getMonth() : 1;
            for (let month = start_month; month <= end_month; month++)
            {
                private_props.model.append({
                                               year: year,
                                               month: month
                                           });
            }
        }
    }
}
