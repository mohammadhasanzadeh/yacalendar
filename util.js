.pragma library

function find_in_model(model, criteria, return_object=false)
{
    for (let counter = 0; counter < model.count; ++counter)
    {
        if (criteria(model.get(counter)))
            return (return_object) ? model.get(counter) : counter;
    }
    return (return_object) ? null : -1;
}


function get_day_headers(locale)
{
    let first_day_of_week = locale.firstDayOfWeek;
    const days = []
    while (days.length < 7)
    {
        days.push(first_day_of_week);
        first_day_of_week = (first_day_of_week === 6) ? 0 : first_day_of_week + 1;
    }
    return days;
}

function is_lower_equal_than(system, first_date, second_date)
{
    let temp = system.to_gregorian(first_date.year, first_date.month, first_date.day);
    const qdate_first_date = new Date(temp.year, (temp.month - 1), temp.day);
    temp = system.to_gregorian(second_date.year, second_date.month, second_date.day);
    const qdate_second_date = new Date(temp.year, (temp.month), temp.day);
    return (qdate_first_date <= qdate_second_date);
}

function is_valid_date_object(date)
{
    return ("year" in date && "month" in date && "day" in date);
}

function is_date_valid(date, system)
{
    if (!is_valid_date_object(date))
        return false;

    return system.is_date_valid(date.year, date.month, date.day);
}
