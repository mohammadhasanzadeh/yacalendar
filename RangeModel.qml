import QtQuick 2.14
import QtQml.Models 2.14

ListModel
{
    id: control
    property int from: 0
    property int to: 100

    Component.onCompleted:
    {
        init();
    }

    function init()
    {
        for (let counter = from; counter <= to; counter++)
        {
            append({"number": counter});
        }
    }
}
