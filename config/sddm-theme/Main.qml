import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import SddmComponents 2.0

Rectangle {
    id: root
    focus: true

    property color colorBG: "#040405"
    property color colorFG: "#f38ba8"
    property color colorText: "#f1cfff"
    property color colorAccent: "#ff005d"
    property color colorSecondary: "#938bb4"
    property color colorWarning: "#ff7c36"
    property color colorDark: "#16161c"
    property color colorDim: "#424242"

    property string fontFamily: "Cascadia Mono"
    property string fontIcon: "JetBrainsMono Nerd Font Mono"
    property int fontSize: 17
    property int iconSize: 21

    Image {
        anchors.fill: parent
        source: "bg.png"
        fillMode: Image.PreserveAspectCrop
    }

    property int currentField: 0
    property var fields: [ userBorder, input, loginBorder ]
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            currentField = (currentField + 1) % fields.length
            fields[currentField].forceActiveFocus()
            event.accepted = true
        }

        if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
            currentField = (currentField - 1) % fields.length
            if (currentField < 0) currentField = fields.length - 1
            fields[currentField].forceActiveFocus()
            event.accepted = true
        }

        if (event.key === Qt.Key_Escape) root.forceActiveFocus()
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            loginText.color = colorWarning
            input.enabled = false
            input.text = ""
            passwordText.text = "Fuck You"
            lockoutTimer.restart()
        }

        function onLoginSucceeded() {
            loginText.color = root.colorAccent
            loginTimer.restart()
        }
    }

    Timer {
        id: lockoutTimer
        interval: 3000
        running: true
        repeat: false
        onTriggered: {
            input.enabled = true
            passwordText.text = "Password"
            loginText.color = root.colorText
        }
    }

    Timer {
        id: loginTimer
        interval: 1000
        running: true
        repeat: false
        onTriggered: loginText.color = root.colorText
    }

    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 75
        spacing: 10



        Row {
            id: textRow
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter



            Rectangle {
                id: userBorder

                focus: false
                onFocusChanged: focused = userBorder.focus

                property bool focused: false
                property var users: []
                property int currentUser: userModel.lastIndex
                property string username: userModel.lastUser

                Repeater {
                    id: userRepeater
                    model: userModel

                    delegate: Item {
                        Component.onCompleted: {
                            userBorder.users.push(name)
                            if (userBorder.users.length === 1) userBorder.username = name
                        }
                    }
                }

                function cycleUser(direction) {
                    if (users.length === 0) return

                    currentUser = (currentUser + direction) % users.length
                    if (currentUser < 0) currentUser = users.length - 1
                    username = users[currentUser]
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Up || event.key === Qt.Key_J) cycleUser(1)
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_K) cycleUser(-1)
                }


                implicitWidth: userText.width + 25
                implicitHeight: userText.height + 15
                radius: userBorder.height * 0.2

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: colorSecondary
                    }
                    GradientStop {
                        position: 1.0
                        color: colorAccent
                    }
                }

                Rectangle {
                    id: userGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: root.colorAccent

                    visible: false
                }

                MultiEffect {
                    anchors.fill: userGlow
                    source: userGlow

                    blurEnabled: true
                    blur: 0.8

                    opacity: userBorder.focused ? 0.5 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                }


                Rectangle {
                    id: userField

                    property alias text: userText.text

                    anchors.fill: parent
                    anchors.margins: 1

                    color: userBorder.focused ? root.colorDark : root.colorBG
                    radius: parent.radius - 1


                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true

                        onEntered: userBorder.focused = true
                        onExited: userBorder.focused = false

                        onClicked: userBorder.cycleUser(1)
                    }


                    Text {
                        id: userText

                        text: userBorder.username
                        color: root.colorText
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }

                        anchors.centerIn: parent
                    }
                }
            }


            Rectangle {
                id: passwordBorder

                property bool focused: false

                implicitWidth: (!passwordText.visible ? input.width : passwordText.width) + 25
                implicitHeight: (!passwordText.visible ? input.height : passwordText.height) + 15
                radius: passwordBorder.height * 0.2

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: colorSecondary
                    }
                    GradientStop {
                        position: 1.0
                        color: colorAccent
                    }
                }

                Rectangle {
                    id: passwordGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: root.colorAccent

                    visible: false
                }

                MultiEffect {
                    anchors.fill: passwordGlow
                    source: passwordGlow

                    blurEnabled: true
                    blur: 0.8

                    opacity: passwordBorder.focused ? 0.5 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                }


                Rectangle {
                    id: passwordField

                    property alias text: input.text

                    anchors.fill: parent
                    anchors.margins: 1

                    color: passwordBorder.focused ? root.colorDark : root.colorBG
                    radius: parent.radius - 1


                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true

                        onClicked: input.forceActiveFocus()

                        onEntered: passwordBorder.focused = true
                        onExited: passwordBorder.focused = false
                    }


                    Text {
                        id: passwordText

                        text: "Password"
                        color: root.colorDim
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true; italic: true }

                        anchors.centerIn: parent

                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter

                        visible: input.text.length === 0
                    }

                    TextInput {
                        id: input

                        focus: false
                        onFocusChanged: passwordBorder.focused = input.focus

                        Keys.onPressed: function(event) { 
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Y) sddm.login(userField.text, passwordField.text, sessionModel.lastIndex) 
                        }


                        width: passwordText.width
                        height: passwordText.height

                        anchors.centerIn: parent
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter

                        color: root.colorText
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }

                        echoMode: TextInput.Password

                        passwordCharacter: ""

                        clip: true
                    }
                }
            }


            Rectangle {
                id: loginBorder

                focus: false
                onFocusChanged: focused = loginBorder.focus

                property bool focused: false

                Keys.onPressed: function(event) { 
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Y) sddm.login(userField.text, passwordField.text, sessionModel.lastIndex) 
                }

                implicitWidth: loginText.width + 25
                implicitHeight: loginText.height + 15
                radius: loginBorder.height * 0.2

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: colorSecondary
                    }
                    GradientStop {
                        position: 1.0
                        color: colorAccent
                    }
                }

                Rectangle {
                    id: loginGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: root.colorAccent

                    visible: false
                }

                MultiEffect {
                    anchors.fill: loginGlow
                    source: loginGlow

                    blurEnabled: true
                    blur: 0.8

                    opacity: loginBorder.focused ? 0.5 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                }


                Rectangle {
                    id: loginButton

                    anchors.fill: parent
                    anchors.margins: 1

                    color: loginBorder.focused ? root.colorDark : root.colorBG
                    radius: parent.radius - 1

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true

                        onEntered: loginBorder.focused = true
                        onExited: loginBorder.focused = false

                        onClicked: sddm.login(userField.text, passwordField.text, sessionModel.lastIndex)
                    }

                    Text {
                        id: loginText

                        text: "Login"
                        color: root.colorText
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }

                        anchors.centerIn: parent
                    }
                }

            }
        }

        Rectangle {
            id: bar

            width: textRow.width * 1.05 + 5
            height: 5
            radius: 2
            anchors.horizontalCenter: parent.horizontalCenter

            property bool focused

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: colorSecondary
                }
                GradientStop {
                    position: 1.0
                    color: colorAccent
                }
            }


            Rectangle {
                id: barGlow

                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius + 2
                color: root.colorAccent

                visible: false
            }

            MultiEffect {
                anchors.fill: barGlow
                source: barGlow

                blurEnabled: true
                blur: 0.8

                opacity: bar.focused ? 0.5 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: 180 }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true

                onEntered: bar.focused = true
                onExited: bar.focused = false
            }
        }

    }
}
