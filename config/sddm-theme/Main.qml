import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080



    property color colorBG: "#040405"
    property color colorFG: "#f38ba8"
    property color colorText: "#f1cfff"
    property color colorAccent: "#ff005d"
    property color colorDark: "#16161c"

    Image {
        anchors.fill: parent
        source: "bg.png"
        fillMode: Image.PreserveAspectCrop
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Row {
            id: textRow
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter


            TextField {
                id: userField
                color: root.colorText
                placeholderText: "Username"
            }

            TextField {
                id: passField
                color: root.colorText
                placeholderText: "Password"
                echoMode: TextInput.Password

                Keys.onReturnPressed: loginButton.clicked()
            }

        }

        Rectangle {
            width: textRow.width + 5
            height: 10
            radius: 5

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: colorFG
                }
                GradientStop {
                    position: 1.0
                    color: colorAccent
                }
            }

        }

        Button {
            id: loginButton
            text: "Login"

            color: root.colorDark

            onClicked: {
                sddm.login(userField.text, passField.text, session.index)
            }
        }

    }
}
