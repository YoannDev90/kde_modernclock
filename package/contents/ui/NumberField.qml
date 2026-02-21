import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0

RowLayout {
    id: numberField
    property alias label: numberField_label.text;
    property alias value: numberField_spinbox.value
    property alias from: numberField_spinbox.from
    property alias to: numberField_spinbox.to

    Label {
        id: numberField_label
    }
    SpinBox {
        id: numberField_spinbox
        from: 0
        to: 999
    }
}

