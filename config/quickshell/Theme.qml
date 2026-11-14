pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io


Singleton {
    id: root

    signal reloaded

    property bool ready: false

    property QtObject colors: QtObject {
        property color colorBG: "#040405";
        property color colorFG: "#e2e2e2";
        property color colorDim: "#040405";
        property color colorSaturated: "#e2e2e2";
        property color colorAccent: "#e2e2e2";
        property color colorSecondary: "#e2e2e2";
        property color colorTertiary: "#e2e2e2";
        property color colorDark: "#040405";

        property color colorFGDark: "#e2e2e2";
        property color colorFGDarker: "#e2e2e2";
        property color colorFGVeryDark: "#e2e2e2";
        property color colorFGLight: "#e2e2e2";
        property color colorFGLighter: "#e2e2e2";
        property color colorFGVeryLight: "#e2e2e2";

        property color colorSaturatedPrimary: "#e2e2e2";
        property color colorSaturatedSecondary: "#e2e2e2";
        property color colorSaturatedTertiary: "#e2e2e2";

        property color colorDarker: "#040405";
    }

    function loadColors(target, obj) {
        for (const [key, value] of Object.entries(obj)) {
            if (!target.hasOwnProperty(key)) continue
            target[key] = value 
        }
    }

    function _load(content) {
        const parsed = JSON.parse(content)
        loadColors(root.colors, parsed)
        root.ready = true
        root.reloaded()
    }

    FileView {
        id: file
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/theme/colors.json"

        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: (error) => { console.debug(error.toString()) }
        onLoaded: root._load(text())
    }
}
