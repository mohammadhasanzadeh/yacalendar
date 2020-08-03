import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14

ComboBox
{
    id: control

    property int cell_width: 100
    property int cell_height: 100
    property alias highlight: grid_view.highlight

    popup: Popup {
        y: control.height - 8
        width: control.parent.width
        height: control.parent.height * 0.9
        padding: 5
        Material.elevation: 0
        Material.theme: control.Material.theme

        contentItem: GridView {
            id: grid_view
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            cellWidth: control.cell_width
            cellHeight: control.cell_height
            highlightFollowsCurrentItem: true
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }
}
