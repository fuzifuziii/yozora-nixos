import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "fuzi.workspaces"

  property var tagState: ({})

  function stateOf(id) {
    return root.tagState[String(id)] || { occupied: false, focused: false }
  }

  function applyTags(text) {
    var data
    try { data = JSON.parse(String(text || "")) } catch (e) { return }
    var monitors = Array.isArray(data.all_tags) ? data.all_tags : []
    var state = {}
    for (var m = 0; m < monitors.length; m++) {
      var list = Array.isArray(monitors[m].tags) ? monitors[m].tags : []
      for (var i = 0; i < list.length; i++) {
        var tag = list[i]
        var key = String(tag.index)
        var prev = state[key] || { occupied: false, focused: false }
        state[key] = {
          occupied: prev.occupied || tag.client_count > 0,
          focused: prev.focused || tag.is_active === true
        }
      }
    }
    root.tagState = state
  }

  function refresh() {
    if (!queryProc.running) queryProc.running = true
  }

  function focusTag(id) {
    if (!root.bar) return
    root.bar.run("mmsg dispatch view," + id)
  }

  Component.onCompleted: refresh()

  Process {
    id: queryProc
    command: ["mmsg", "get", "all-tags"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyTags(text)
    }
  }

  Process {
    id: watchProc
    command: ["mmsg", "watch", "all-tags"]
    running: true
    stdout: SplitParser {
      onRead: function(line) { debounce.restart() }
    }
  }

  Timer {
    id: debounce
    interval: 50
    onTriggered: root.refresh()
  }

  Timer {
    interval: 3000
    running: !watchProc.running
    repeat: true
    onTriggered: watchProc.running = true
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : 10
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      WidgetButton {
        required property int modelData

        readonly property bool occupied: root.stateOf(modelData).occupied
        readonly property bool focused: root.stateOf(modelData).focused

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: root.vertical ? 2 : 6
        verticalPadding: root.vertical ? 2 : 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.vertical ? Style.space(20) : root.barSize
        onPressed: function() { root.focusTag(modelData) }
      }
    }
  }
}
