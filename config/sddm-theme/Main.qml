import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import SddmComponents 2.0

import "colors.js" as Theme

Rectangle {
    id: root
    focus: true
    anchors.fill: parent
    width: Screen.width
    height: Screen.height

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
    property var fields: [ userBorder, input, optionsBorder ]
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
            optionsText.color = Theme.colorAccent
            input.enabled = false
            input.text = ""
            passwordText.text = "Fuck You"
            lockoutTimer.restart()
        }

        function onLoginSucceeded() {
            optionsText.color = Theme.colorTertiary
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
            optionsText.color = Theme.colorFGLighter
        }
    }

    Timer {
        id: loginTimer
        interval: 1500
        running: true
        repeat: false
        onTriggered: optionsText.color = Theme.colorFGLighter
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
                        color: Theme.colorSecondary
                    }
                    GradientStop {
                        position: 1.0
                        color: Theme.colorTertiary
                    }
                }

                Rectangle {
                    id: userGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: Theme.colorTertiary

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

                    color: userBorder.focused ? Theme.colorDark : Theme.colorBG
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
                        color: Theme.colorFGLighter
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
                        color: Theme.colorSecondary
                    }
                    GradientStop {
                        position: 1.0
                        color: Theme.colorTertiary
                    }
                }

                Rectangle {
                    id: passwordGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: Theme.colorTertiary

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

                    color: passwordBorder.focused ? Theme.colorDark : Theme.colorBG
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
                        color: Theme.colorDim
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

                        color: Theme.colorFGLighter
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }

                        echoMode: TextInput.Password

                        passwordCharacter: ""

                        clip: true
                    }
                }
            }


            Rectangle {
                id: optionsBorder

                focus: false
                onFocusChanged: focused = optionsBorder.focus
                property int currentOption: 0
                property var options: [ "Login", "Shutdown" ]

                property bool focused: false

                function cycleOptions(direction) {
                    if (options.length === 0) return

                    currentOption = (currentOption + direction) % options.length
                    if (currentOption < 0) currentOption = options.length - 1
                    optionsText.text = options[currentOption]
                }

                Keys.onPressed: function(event) { 
                    if (event.key === Qt.Key_Up || event.key === Qt.Key_J) cycleOptions(1)
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_K) cycleOptions(-1)
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Y) {
                        if (options[currentOption] === "Login") sddm.login(userField.text, passwordField.text, sessionModel.lastIndex) 
                        if (options[currentOption] === "Shutdown") sddm.powerOff()
                    }
                }

                implicitWidth: optionsText.width + 25
                implicitHeight: optionsText.height + 15
                radius: optionsBorder.height * 0.2

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: Theme.colorSecondary
                    }
                    GradientStop {
                        position: 1.0
                        color: Theme.colorTertiary
                    }
                }

                Rectangle {
                    id: optionsGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: Theme.colorTertiary

                    visible: false
                }

                MultiEffect {
                    anchors.fill: optionsGlow
                    source: optionsGlow

                    blurEnabled: true
                    blur: 0.8

                    opacity: optionsBorder.focused ? 0.5 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                }


                Rectangle {
                    id: optionsButton

                    anchors.fill: parent
                    anchors.margins: 1

                    color: optionsBorder.focused ? Theme.colorDark : Theme.colorBG
                    radius: parent.radius - 1

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true

                        onEntered: optionsBorder.focused = true
                        onExited: optionsBorder.focused = false

                        onClicked: sddm.login(userField.text, passwordField.text, sessionModel.lastIndex)
                    }

                    Text {
                        id: optionsText

                        text: "Login"
                        color: Theme.colorFGLighter
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
                    color: Theme.colorSecondary
                }
                GradientStop {
                    position: 1.0
                    color: Theme.colorTertiary
                }
            }


            Rectangle {
                id: barGlow

                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius + 2
                color: Theme.colorTertiary

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
