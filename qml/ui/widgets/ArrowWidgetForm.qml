import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0
import QtQuick.Shapes 1.0

import OpenHD 1.0

BaseWidget {
    id: arrowWidget
    width: 64
    height: 48
    defaultYOffset: 85

    visible: settings.show_arrow

    widgetIdentifier: "arrow_widget"

    defaultHCenter: true
    defaultVCenter: false

    hasWidgetDetail: true
    widgetDetailComponent: Column {
        Item {
            width: parent.width
            height: 32
            Text {
                id: opacityTitle
                text: qsTr("Transparency")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: arrow_opacity_Slider
                orientation: Qt.Horizontal
                from: .1
                value: settings.arrow_opacity
                to: 1
                stepSize: .1
                height: parent.height
                anchors.rightMargin: 0
                anchors.right: parent.right
                width: parent.width - 96

                onValueChanged: {
                    settings.arrow_opacity = arrow_opacity_Slider.value
                }
            }
        }
        Item {
            width: parent.width
            height: 32
            Text {
                text: qsTr("Invert Arrow")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels;
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Switch {
                width: 32
                height: parent.height
                anchors.rightMargin: 6
                anchors.right: parent.right
                checked: settings.arrow_invert
                onCheckedChanged: settings.arrow_invert = checked
            }
        }
    }

    Item {
        id: widgetInner
        anchors.fill: parent

        Shape {
            id: arrow
            anchors.fill: parent
            antialiasing: true
            opacity: settings.arrow_opacity

            ShapePath {
                capStyle: ShapePath.RoundCap
                strokeColor: settings.color_glow
                fillColor: settings.color_shape
                strokeWidth: 1
                strokeStyle: ShapePath.SolidLine

                startX: 32
                startY: 0
                PathLine { x: 44;                 y: 12  }//right edge of arrow
                PathLine { x: 38;                 y: 12  }//inner right edge
                PathLine { x: 38;                 y: 24 }//bottom right edge
                PathLine { x: 26;                  y: 24 }//bottom left edge
                PathLine { x: 26;                  y: 12  }//inner left edge
                PathLine { x: 20;                  y: 12  }//outer left
                PathLine { x: 32;                  y: 0  }//back to start
            }

            transform: Rotation {
                origin.x: 32;
                origin.y: 12;
                angle: settings.arrow_invert ? OpenHD.home_course : OpenHD.home_course-180
            }
        }

    }
}
