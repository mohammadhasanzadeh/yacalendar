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
