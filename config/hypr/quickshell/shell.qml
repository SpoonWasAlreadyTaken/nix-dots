import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects




ShellRoot {
    id: root

    property color colorBG: "#040405"                
    property color colorFG: "#f38ba8"           
    property color colorFGL: "#f2a9be"          
    property color colorDim: "#424242"        
    property color colorPink: "#f24878"        
    property color colorPinkDim: "#7f4858"    
    property color colorPinkDark: "#3f242c"  
    property color colorAccent: "#ff7c36"    
    property color colorSecondary: "#938bb4" 
    property color colorTertiary: "#ff005d"  
    property color colorDark: "#16161c"         

    property string fontFamily: "Cascadia Mono"
    property string fontIcon: "JetBrainsMono Nerd Font"
    property string fontIconSmall: "Hack Nerd Font Mono"
    property int fontSize: 17
    property int iconSize: 27


    // system vars
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    property int gpuUsage: 0

    property int memUsed: 0
    property int memTotal: 0
    property bool showMemoryPrecentage: true


    property bool isOnline: false
    property bool showNetworkSpeed: false
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property real lastRx: 0
    property real lastTx: 0
    property double lastTime: 0
    function formatNetworkSpeed(bytes) {
        if (bytes < 1024) return Math.round(bytes) + " B/s"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(2) + " KiB/s"
        return (bytes / 1024 / 1024).toFixed(2) + "MiB/s"
    }

    property int volumeLevel: Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
    function volumeIcon (muted, volume) { return muted ? "" : (volume >= 50 ? "" : (volume > 0 ? "" : "")) }

    property string clock: Qt.formatDateTime(new Date(), "HH:mm")

    property string systemIcon: ""
    property string activeWindow: systemIcon
    function getIcon(activeWindow) {
        switch (activeWindow) {
            case "com.mitchellh.ghostty":
            return "󰊠"
            break
            case "firefox":
            return "󰈹"
            break
            case "steam":
            return ""
            break
            case "vesktop":
            return ""
            break
            default:
            return systemIcon
        }
    }

    function getIconPadding(activeWindow) {
        switch (activeWindow) {
            case "com.mitchellh.ghostty":
            return 4
            break
            case "firefox":
            return 6
            break
            case "steam":
            return 6
            break
            case "vesktop":
            return 13
            break
            default:
            return 11
        }
    }


    property var audioStreams: []
    function setVolume(id, value) {
        Quickshell.execDetached(["wpctl", "set-volume", id.toString(), value.toString()])
    }


    Process {
        id: cpuProcess
        command: [ "sh", "-c", "head -1 /proc/stat " ]
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)

                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                }
                lastCpuTotal = total
                lastCpuIdle = idle
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: gpuProcess
        command: [ "sh", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits " ]
        stdout: SplitParser {
            onRead: data => {
                gpuUsage = parseInt(data.trim()) || 0
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: memProcess
        command: [ "sh", "-c", "free | grep Mem " ]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/)
                memTotal = parseInt(parts[1]) || 1
                memUsed = parseInt(parts[2]) || 0
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: networkProcess
        command: [ "sh", "-c", "ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1 && echo online || echo offline" ]
        stdout: SplitParser {
            onRead: data => {
                isOnline = data.trim() === "online"
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: networkSpeedProcess
        command: [ "cat", "/proc/net/dev" ]
        stdout: StdioCollector {
            onStreamFinished: {
                let rx = 0
                let tx = 0

                let lines = text.split("\n")

                for (let line of lines) {
                    if (!line.includes(":")) continue

                    let parts = line.trim().split(/\s+/)
                    let iface = parts[0].replace(":", "")

                    if (iface === "lo") continue

                    rx += Number(parts[1])
                    tx += Number(parts[9])
                }

                let now = Date.now()

                if (lastTime !== 0) {
                    let seconds = (now - lastTime) / 1000
                    downloadSpeed = (rx - lastRx) / seconds
                    uploadSpeed = (tx - lastTx) / seconds
                }

                lastRx = rx
                lastTx = tx
                lastTime = now
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: windowProcess
        command: [ "sh", "-c", "hyprctl activewindow -j | jq -r '.class'" ]
        stdout: SplitParser {
            onRead: data => {
                activeWindow = data.trim()
            }
        }

        Component.onCompleted: running = true
    }

    Process {
        id: audioService
        command: [ "pactl", "-f", "json", "list", "sink-inputs" ]
        stdout: StdioCollector {
            onStreamFinished: {
                let streams = JSON.parse(text)
                audioStreams = streams.map(stream => ({
                    id: stream.properties["object.id"],
                    name: stream.properties["media.name"],
                    volume: stream.volume["front-left"].value / 65536,
                }))
            }
        }

        Component.onCompleted: running = true
    }


    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: { 
            cpuProcess.running = true 
            memProcess.running = true 
            gpuProcess.running = true 
            networkProcess.running = true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock = Qt.formatDateTime(new Date(), "HH:mm")
    }

    Timer {
        id: audioTimer
        interval: 1000
        repeat: true
        running: audioWindow.visible

        onTriggered: if (!audioService.running) audioService.running = true
    }

    Timer {
        id: networkSpeedTimer
        interval: 1000
        repeat: true
        running: showNetworkSpeed && isOnline

        onTriggered: if (!networkSpeedProcess.running) networkSpeedProcess.running = true

    }

    Connections {
        target: Hyprland 

        function onRawEvent(event) { 
            if (event.name === "activewindow") {
                if (!windowProcess.running) windowProcess.running = true
            }
        }
    }


    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }


    Variants {
        model: Quickshell.screens

        // actual bar
        PanelWindow {
            property var modelData
            screen: modelData

            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 32
            color: colorBG


            Item {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                RowLayout { /* LEFT */
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    anchors.leftMargin: 12

                    Text { /* CPU */
                        text: cpuUsage + "%"
                        color: root.colorFGL
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        Layout.alignment: Qt.AlignBaseline
                    } 

                    Text { /* ICON */
                        text: ""
                        color: root.colorFGL
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }
                    }

                    Rectangle {
                        Layout.preferredWidth: 2
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colorDark
                    }

                    Text { /* MEMORY */
                        text: showMemoryPrecentage ? Math.round(100 * memUsed / memTotal) + "%" : (memUsed / 1024 / 1024).toFixed(2) + "G"
                        color: root.colorFGL
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showMemoryPrecentage = !showMemoryPrecentage
                        }
                    }

                    Text { /* ICON */
                        text: ""
                        color: root.colorFGL
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showMemoryPrecentage = !showMemoryPrecentage
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 2
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colorDark
                    }

                    Text { /* GPU */
                        text: gpuUsage + "%"
                        color: root.colorFGL
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    } 

                    Text { /* ICON */
                        text: "󰩪"
                        color: root.colorFGL
                        font { family: root.fontIcon; pixelSize: root.fontSize; bold: true }
                    }
                }


                RowLayout { /* CENTER */
                    anchors.centerIn: parent
                    Layout.alignment: Qt.AlignHCenter

                    spacing: 8

                    RowLayout {           
                        Repeater {
                            model: 5

                            Text { /* WORKSPACES 1-5 */
                                property int wsID: index + 1
                                property var ws: Hyprland.workspaces.values.find(w => w.id === wsID)
                                property bool isActive: Hyprland.focusedWorkspace?.id === (wsID)
                                property bool isUrgent: ws?.urgent ?? false

                                text: isActive ? "" : ""
                                color: isActive ? root.colorFG : (ws ? (isUrgent ? root.colorAccent : root.colorPinkDim) : colorDim)
                                font { family: root.fontIconSmall; pixelSize: root.fontSize; bold: true }

                                Layout.preferredWidth: 12

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (wsID) + "})")
                                }
                            }
                        }
                    }

                    Item {
                        width: 30
                        height: parent.height

                        Text { /* ACTIVE WINDOW */
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            rightPadding: getIconPadding(activeWindow)

                            text: getIcon(activeWindow)
                            color: colorFG
                            font { family: root.fontIcon; pixelSize: root.iconSize; bold: true }
                        }
                    }

                    RowLayout {
                        Repeater {
                            model: 5

                            Text { /* WORKSPACES 6-10 */
                                property int wsID: 5 + index + 1
                                property var ws: Hyprland.workspaces.values.find(w => w.id === wsID)
                                property bool isActive: Hyprland.focusedWorkspace?.id === (wsID)
                                property bool isUrgent: ws?.urgent ?? false

                                text: isActive ? "" : ""
                                color: isActive ? root.colorFG : (ws ? (isUrgent ? root.colorAccent : root.colorPinkDim) : colorDim)
                                font { family: root.fontIconSmall; pixelSize: root.fontSize; bold: true }

                                Layout.preferredWidth: 12

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (wsID) + "})")
                                }
                            }
                        }
                    }
                }


                RowLayout { /* RIGHT */
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    anchors.rightMargin: 12

                    Text { /* NETWORK */
                        text: isOnline ? (showNetworkSpeed ? formatNetworkSpeed(downloadSpeed) + " 󰇚" + " | " + formatNetworkSpeed(uploadSpeed) + " 󰕒" : "online") : "offline"
                        color: isOnline ? root.colorFGL : root.colorDim
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showNetworkSpeed = !showNetworkSpeed
                        }
                    }



                    Rectangle {
                        Layout.preferredWidth: 2
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colorDark
                    }

                    Item {
                        implicitWidth: audioRow.implicitWidth
                        implicitHeight: audioRow.implicitHeight

                        RowLayout {
                            id: audioRow
                            anchors.centerIn: parent
                            spacing: 8

                            Text { /* AUDIO */
                                text: volumeLevel + "%"
                                color: root.colorFGL
                                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                            }

                            Text { /* ICON */
                                text: volumeIcon(Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.muted : 0, volumeLevel)
                                color: root.colorFGL
                                font { family: root.fontIcon; pixelSize: root.fontSize; bold: true } 
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: { audioWindow.visible = !audioWindow.visible }
                            onWheel: (event) => {
                                Pipewire.defaultAudioSink.audio.volume += event.angleDelta.y > 0 ? (Pipewire.defaultAudioSink.audio.volume < 0.99 ? 0.01 : 0) : -0.01
                            }
                        }

                        Rectangle {
                            visible: audioWindow.visible
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom

                            width: parent.width * 1.2
                            height: 2
                            radius: 2
                            color: colorDark
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 2
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colorDark
                    }

                    Text { /* CLOCK */
                        text: clock
                        color: root.colorFGL
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }

                        MouseArea {
                            anchors.fill: parent
                            anchors.centerIn: parent

                            onPressed: (mouse) => { timeWindow.visible = true }
                            onReleased: (mouse) => { timeWindow.visible = false }
                        }
                    }


                }
            }
        }
    }

    PanelWindow { /* FOCUS REMOVER */
        id: focusRemover
        visible: audioWindow.visible

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: { audioWindow.visible = false }
        }
    }

    // popup windows

    PanelWindow { /* AUDIO PANEL */
        id: audioWindow
        visible: false
        focusable: true

        implicitWidth: 600
        implicitHeight: 300

        anchors.top: true
        anchors.right: true

        color: "transparent"

        property bool maxValueRaised: false
        property double maxValue: maxValueRaised ? 1.5 : 1

        Shortcut {
            sequence: "Escape"
            onActivated: { audioWindow.visible = false }
        }

        onVisibleChanged: { if (visible) { audioService.running = true } }

        Rectangle {
            anchors.fill: parent
            radius: 11
            anchors.margins: 4

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: colorFG
                }
                GradientStop {
                    position: 1.0
                    color: colorTertiary
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            anchors.margins: 5

            color: colorDark

            Rectangle {
                id: volumeButton
                anchors.margins: 10
                anchors.right: parent.right
                anchors.top: parent.top

                border.width: 2
                border.color: audioWindow.maxValueRaised ? root.colorBG : root.colorTertiary

                property bool focused: false

                width: 15
                height: 15
                radius: volumeButton.height / 2

                color: audioWindow.maxValueRaised ? root.colorTertiary : root.colorBG

                Rectangle {
                    id: volumeButtonGlow

                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: root.colorTertiary

                    visible: false
                }

                MultiEffect {
                    anchors.fill: volumeButtonGlow
                    source: volumeButtonGlow

                    blurEnabled: true
                    blur: 0.8

                    opacity: volumeButton.focused ? 0.5 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -2

                    hoverEnabled: true

                    onEntered: volumeButton.focused = true
                    onExited: volumeButton.focused = false

                    onClicked: audioWindow.maxValueRaised = !audioWindow.maxValueRaised
                }
            }

            Flickable {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 20
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                contentHeight: streamColumn.height + 15
                clip: true

                Column {
                    id: streamColumn
                    width: parent.width
                    spacing: 15

                    x: 8

                    Repeater { 
                        model: audioStreams

                        delegate: Item {
                            id: slider

                            property bool focused: false

                            property real value: modelData.volume
                            property int streamId: modelData.id
                            width: parent.width * 0.84
                            height: 40

                            Column {
                                spacing: 8

                                Text {
                                    text: modelData.name
                                    color: colorFGL
                                    font { family: root.fontFamily; pixelSize: 14; bold: true }
                                    width: slider.width
                                    elide: Text.ElideRight
                                }

                                RowLayout {

                                    Item {
                                        width: slider.width
                                        height: track.height


                                        Rectangle {
                                            id: glowSource

                                            anchors.fill: parent
                                            anchors.margins: -2
                                            radius: parent.radius + 2
                                            color: root.colorTertiary

                                            visible: false
                                        }

                                        MultiEffect {
                                            anchors.fill: glowSource
                                            source: glowSource

                                            blurEnabled: true
                                            blur: 0.8

                                            opacity: slider.focused ? 0.5 : 0
                                            Behavior on opacity {
                                                NumberAnimation { duration: 180 }
                                            }

                                        }


                                        Rectangle {
                                            id: track
                                            width: slider.width
                                            height: 6
                                            radius: 3
                                            color: colorBG



                                            Rectangle {
                                                width: (track.width * slider.value) / audioWindow.maxValue
                                                height: parent.height
                                                radius: parent.radius
                                                gradient: Gradient {
                                                    orientation: Gradient.Horizontal
                                                    GradientStop {
                                                        position: 0.0
                                                        color: colorSecondary
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: colorTertiary
                                                    }
                                                }

                                            }
                                        }

                                        Rectangle {
                                            id: handle
                                            width: 14
                                            height: 14
                                            radius: 7
                                            color: colorBG
                                            border.width: 2
                                            border.color: colorTertiary
                                            x: (slider.value * (parent.width - width)) / audioWindow.maxValue
                                            y: (parent.height - height) / 2
                                        }

                                        MouseArea {
                                            anchors.centerIn: parent

                                            width: parent.width
                                            height: parent.height * 2

                                            preventStealing: true
                                            hoverEnabled: true

                                            onEntered: slider.focused = true
                                            onExited: slider.focused = false

                                            onPressed: (mouse) => { updateValue(mouse.x); audioTimer.running = false; slider.focused = true; }
                                            onReleased: (mouse) => { audioTimer.running = audioWindow.visible; slider.focused = false; }
                                            onPositionChanged: (mouse) => { if (pressed) updateValue(mouse.x) }

                                            onWheel: (event) => {
                                                slider.value = Math.max(0, Math.min(audioWindow.maxValue, slider.value + (event.angleDelta.y > 0 ? 0.01 : -0.01)))
                                                setVolume(slider.streamId, slider.value)
                                            }

                                            function updateValue(x) { 
                                                slider.value = Math.max(0, Math.min(1, x / slider.width)) * audioWindow.maxValue
                                                slider.value = Math.round(slider.value * 100) / 100
                                                rateLimiter.restart()
                                            }
                                        }

                                        Timer {
                                            id: rateLimiter

                                            interval: 50
                                            repeat: false

                                            onTriggered: {
                                                setVolume(slider.streamId, slider.value)
                                            }
                                        }
                                    }

                                    Text {
                                        text: Math.round(slider.value * 100) + "%"
                                        color: slider.value > 1 ? root.colorTertiary : colorFGL
                                        font { family: root.fontFamily; pixelSize: 14; bold: true }
                                        Layout.preferredWidth: 50
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        text: volumeIcon(false, slider.value * 100)
                                        color: slider.value > 1 ? root.colorTertiary : root.colorFGL
                                        font { family: root.fontIcon; pixelSize: 14; bold: true } 
                                        Layout.preferredWidth: 15
                                    }
                                }

                            }
                        }
                    }


                }

            }


        }
    }

    PanelWindow {
        id: timeWindow
        anchors.top: true
        anchors.right: true

        implicitWidth: timeWindowText.width + 30
        implicitHeight: timeWindowText.height + 20
        color: "transparent"

        visible: false

        onVisibleChanged: { if (visible) { timeWindowText.text = Qt.formatDateTime(new Date(), "yyyy MMMM d dddd HH:mm:ss") } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4

            radius: 11

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: colorFG
                }
                GradientStop {
                    position: 1.0
                    color: colorTertiary
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1

                radius: 10
                color: root.colorDark

                Text {
                    id: timeWindowText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(new Date(), "yyyy MMMM d dddd HH:mm:ss")
                    color: root.colorFGL
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                }
            }
        }

        Timer {
            interval: 1000
            running: timeWindow.visible
            repeat: true
            onTriggered: timeWindowText.text = Qt.formatDateTime(new Date(), "yyyy MMMM d dddd HH:mm:ss")
        }
    }


}

