import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "fuzi.keyboard-layout"

  property string layoutLabel: ""
  property string layoutFull: ""

  function refresh() {
    if (!queryProc.running) queryProc.running = true
  }

  // Ответ может быть строкой, JSON-строкой или объектом
  function applyLayout(text) {
    var raw = String(text || "").trim()
    if (!raw) return
    var value = raw
    try { value = JSON.parse(raw) } catch (e) {}
    if (value !== null && typeof value === "object") value = value.layout || value.keyboardlayout || ""
    var full = String(value).trim()
    if (!full) return
    root.layoutFull = full
    root.layoutLabel = full.split(/\s+/)[0].substring(0, 3).toUpperCase()
  }

  function cycleLayout() {
    Quickshell.execDetached(["mmsg", "dispatch", "switch_keyboard_layout"])
    refreshTimer.restart()
  }

  Component.onCompleted: refresh()

  Process {
    id: queryProc
    command: ["mmsg", "get", "keyboardlayout"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyLayout(text)
    }
  }

  // Любое событие раскладки запускает повторный запрос
  Process {
    id: watchProc
    command: ["mmsg", "watch", "keyboardlayout"]
    running: true
    stdout: SplitParser {
      onRead: function(line) { refreshTimer.restart() }
    }
  }

  Timer {
    id: refreshTimer
    interval: 100
    onTriggered: root.refresh()
  }

  // Перезапуск watch, если процесс упал
  Timer {
    interval: 3000
    running: !watchProc.running
    repeat: true
    onTriggered: watchProc.running = true
  }

  visible: layoutLabel !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.layoutLabel
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: root.layoutFull
    onPressed: function() { root.cycleLayout() }
  }
}
