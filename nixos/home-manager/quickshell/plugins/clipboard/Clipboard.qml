import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string fuziPath: Quickshell.env("FUZI_PATH")
  property bool opened: false
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property bool clearConfirmOpen: false
  property var rawItems: []

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(875), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(600), panel.height - Style.gapsOut * 2)
  property int rowHeight: Math.max(Style.space(50), Style.font.body + Style.font.caption + Style.spacing.rowPaddingX * 2)
  property int historyLimit: 300
  property string cacheDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/fuzi-clipboard"
  property int imagePrefetch: 30
  property var imageFiles: ({})
  property var imageQueue: []
  property var rawLineById: ({})

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.cancelClearHistory()
    root.opened = false
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open("{}")
  }

  function refresh() {
    if (!listProc.running) listProc.running = true
  }

  // decode image entries to the cache dir, newest first
  function queueImages(ids) {
    var next = root.imageQueue.slice()
    for (var i = 0; i < ids.length; i++) {
      var id = String(ids[i])
      if (!root.imageFiles[id] && next.indexOf(id) === -1) next.push(id)
    }
    root.imageQueue = next
    root.runImageQueue()
  }

  function runImageQueue() {
    if (decodeProc.running || root.imageQueue.length === 0) return
    var batch = root.imageQueue.slice(0, 8)
    root.imageQueue = root.imageQueue.slice(8)
    // Pass: cacheDir, then for each id: id, rawLine (so cliphist gets the full list line)
    var args = [root.cacheDir]
    for (var i = 0; i < batch.length; i++) {
      var id = batch[i]
      args.push(id)
      args.push(root.rawLineById[id] || id)
    }
    decodeProc.command = ["bash", "-c", root.decodeScript, "bash"].concat(args)
    decodeProc.running = true
  }

  function imageDecoded(id, path) {
    var next = Object.assign({}, root.imageFiles)
    next[id] = "file://" + path
    root.imageFiles = next
  }

  function ensureSelectedImage() {
    if (root.selectedIndex < 0 || root.selectedIndex >= displayModel.count) return
    var row = displayModel.get(root.selectedIndex)
    if (row.entryType === "image") root.queueImages([row.clipId])
  }

  onSelectedIndexChanged: root.ensureSelectedImage()

  // $1 = cacheDir, then pairs: id rawLine id rawLine ...
  // Pass full list line into cliphist decode (works on all versions). Save as .png — Qt Image sniffs content.
  readonly property string decodeScript: 'dir="$1"; shift; mkdir -p "$dir"; while [ $# -ge 2 ]; do id="$1"; rawline="$2"; shift 2; f="$dir/$id.png"; if [ -s "$f" ]; then echo "$id	$f"; continue; fi; printf "%s\\n" "$rawline" | cliphist decode > "$f" 2>/dev/null; if [ -s "$f" ]; then echo "$id	$f"; else rm -f "$f"; fi; done'

  function parseCliphistList(output) {
    var lines = String(output || "").split("\n")
    var items = []
    var lineMap = {}
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (!line) continue
      var tabIndex = line.indexOf("\t")
      if (tabIndex === -1) continue
      var id = line.substring(0, tabIndex).trim()
      var text = line.substring(tabIndex + 1)
      if (!id) continue
      var isImg = text.indexOf("[[ binary data") === 0
      items.push({
        id: id,
        rawLine: line,
        preview: text,
        isImage: isImg
      })
      lineMap[id] = line
    }
    root.rawItems = items
    root.rawLineById = lineMap
    root.rebuildDisplay()
    var imageIds = []
    for (var k = 0; k < items.length && imageIds.length < root.imagePrefetch; k++) {
      if (items[k].isImage) imageIds.push(items[k].id)
    }
    root.queueImages(imageIds)
  }

  function rebuildDisplay() {
    var needle = String(root.filterText || "").trim().toLowerCase()
    displayModel.clear()
    var count = 0
    for (var i = 0; i < root.rawItems.length && count < root.historyLimit; i++) {
      var item = root.rawItems[i]
      if (needle && item.preview.toLowerCase().indexOf(needle) === -1) continue
      displayModel.append({
        clipId: item.id,
        rawLine: item.rawLine,
        entryType: item.isImage ? "image" : "text",
        previewText: item.preview,
        fullText: item.preview
      })
      count++
    }

    if (displayModel.count === 0) selectedIndex = 0
    else if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    else if (selectedIndex < 0) selectedIndex = 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    })
  }

  function select(delta) {
    if (displayModel.count === 0) return
    root.disarmPointer()
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      selectedIndex = (selectedIndex + delta + displayModel.count) % displayModel.count
    }
    resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function selectAbsolute(index) {
    if (displayModel.count === 0) return
    root.disarmPointer()
    root.cursorActive = true
    root.selectedIndex = Math.max(0, Math.min(index, displayModel.count - 1))
    resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
  }

  function disarmPointer() {
    pointerGate.reset()
  }

  function selectFromPointer(index, item, mouse) {
    if (!pointerGate.moved(item, mouse)) return
    root.cursorActive = true
    root.selectedIndex = index
  }

  function activateIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.applySelected(row)
  }

  function copyIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.copySelected(row)
  }

  function openIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.openSelected(row)
  }

  function applySelected(row) {
    root.copySelected(row)
  }

  function copySelected(row) {
    if (!row) return
    root.opened = false
    Quickshell.execDetached([
      "bash", "-lc",
      "printf '%s\\n' " + Util.shellQuote(row.rawLine) + " | cliphist decode | wl-copy"
    ])
  }

  function openSelected(row) {
    if (!row) return
    root.opened = false
    Quickshell.execDetached([root.fuziPath + "/bin/fuzi-clipboard-open", "--clip-id", String(row.clipId)])
  }

  function removeDisplayIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    Quickshell.execDetached([
      "bash", "-lc",
      "printf '%s\\n' " + Util.shellQuote(row.rawLine) + " | cliphist delete"
    ])

    for (var i = 0; i < root.rawItems.length; i++) {
      if (root.rawItems[i].rawLine === row.rawLine) {
        root.rawItems.splice(i, 1)
        break
      }
    }

    if (displayModel.count <= 1) {
      root.selectedIndex = 0
      root.cursorActive = false
    } else if (root.selectedIndex >= displayModel.count - 1) {
      root.selectedIndex = displayModel.count - 2
    }

    root.disarmPointer()
    root.rebuildDisplay()
  }

  function requestClearHistory() {
    if (root.rawItems.length === 0) return
    clearConfirm.selectedIndex = 1
    root.clearConfirmOpen = true
  }

  function cancelClearHistory() {
    root.clearConfirmOpen = false
    root.disarmPointer()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmClearHistory() {
    Quickshell.execDetached(["cliphist", "wipe"])
    Quickshell.execDetached(["rm", "-rf", root.cacheDir])
    root.imageFiles = ({})
    root.imageQueue = []
    root.rawLineById = ({})
    root.rawItems = []
    root.selectedIndex = 0
    root.cursorActive = false
    root.disarmPointer()
    root.clearConfirmOpen = false
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  Component.onCompleted: initProc.running = true

  ListModel { id: displayModel }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  Process {
    id: listProc
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseCliphistList(text)
    }
  }

  Process {
    id: decodeProc
    stdout: SplitParser {
      onRead: function(line) {
        var s = String(line).trim()
        if (!s) return
        var tab = s.indexOf("\t")
        if (tab === -1) return
        var id = s.substring(0, tab)
        var path = s.substring(tab + 1)
        if (id && path) root.imageDecoded(id, path)
      }
    }
    onExited: root.runImageQueue()
  }

  Process {
    id: initProc
    command: ["pkill", "-f", "wl-paste .*--watch cliphist store"]
    onExited: {
      textWatchProc.running = true
      imageWatchProc.running = true
    }
  }

  Process {
    id: textWatchProc
    command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "text", "--watch", "cliphist", "store"]
    onExited: watchRestartTimer.restart()
  }

  Process {
    id: imageWatchProc
    command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "image", "--watch", "cliphist", "store"]
    onExited: watchRestartTimer.restart()
  }

  Timer {
    id: watchRestartTimer
    interval: 1000
    repeat: false
    onTriggered: {
      if (!textWatchProc.running) textWatchProc.running = true
      if (!imageWatchProc.running) imageWatchProc.running = true
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "fuzi-clipboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        z: root.clearConfirmOpen ? 20 : 0
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.clearConfirmOpen) {
            if (clearConfirm.handleKey(event)) event.accepted = true
            return
          }

          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.close()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            if (event.modifiers & Qt.ShiftModifier) root.requestClearHistory()
            else root.removeDisplayIndex(root.selectedIndex)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.select(-6)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.select(6)
            event.accepted = true
          } else if (event.key === Qt.Key_Home) {
            root.selectAbsolute(0)
            event.accepted = true
          } else if (event.key === Qt.Key_End) {
            root.selectAbsolute(displayModel.count - 1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.cursorActive && (event.modifiers & Qt.AltModifier)) root.openIndex(root.selectedIndex)
            else if (root.cursorActive && (event.modifiers & Qt.ShiftModifier)) root.copyIndex(root.selectedIndex)
            else if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }

        ConfirmDialog {
          id: clearConfirm

          anchors.fill: parent
          opened: root.clearConfirmOpen
          z: 10
          message: "Delete entire clipboard history?"
          confirmText: "Delete"
          background: root.background
          foreground: root.foreground
          scrim: root.scrim
          selectedBackground: root.selectedBackground
          selectedText: root.selectedText
          fontFamily: root.fontFamily
          cornerRadius: root.cornerRadius
          onCanceled: root.cancelClearHistory()
          onConfirmed: root.confirmClearHistory()
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Rectangle {
          width: parent.width
          height: root.headerHeight
          radius: root.cornerRadius
          color: "transparent"

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || Style.searchPlaceholder
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.contentSpacing

          Row {
            anchors.fill: parent
            spacing: 0

            Item {
              width: parent.width / 2
              height: parent.height
              clip: true

              ListView {
                id: resultList
                anchors.fill: parent
                anchors.rightMargin: root.contentMargin
                model: displayModel
                clip: true
                spacing: Style.space(4)
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                  id: row
                  required property int index
                  required property string entryType
                  required property string previewText
                  required property string fullText
                  required property string clipId

                  readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

                  width: ListView.view.width
                  height: root.rowHeight
                  radius: root.cornerRadius
                  color: hasCursor ? root.selectedBackground : "transparent"

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(12)
                    anchors.rightMargin: Style.space(12)
                    anchors.topMargin: Style.space(8)
                    anchors.bottomMargin: Style.space(8)
                    spacing: Style.space(10)

                    Image {
                      id: thumb
                      visible: status === Image.Ready
                      width: visible ? parent.height * 1.6 : 0
                      height: parent.height
                      source: parent.parent.entryType === "image" ? (root.imageFiles[parent.parent.clipId] || "") : ""
                      sourceSize.height: 96
                      fillMode: Image.PreserveAspectCrop
                      asynchronous: true
                      cache: false
                    }

                    Text {
                      width: parent.width - (thumb.visible ? thumb.width + parent.spacing : 0)
                      height: parent.height
                      text: parent.parent.previewText
                      color: parent.parent.hasCursor ? root.selectedText : root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.title
                      opacity: parent.parent.entryType === "image" ? 0.72 : 1.0
                      elide: Text.ElideRight
                      wrapMode: Text.NoWrap
                      verticalAlignment: Text.AlignVCenter
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: function(mouse) {
                      root.selectFromPointer(row.index, row, mouse)
                    }
                    onClicked: {
                      root.cursorActive = true
                      root.selectedIndex = row.index
                      root.copyIndex(row.index)
                    }
                  }
                }
              }
            }

            Item {
              width: parent.width / 2
              height: parent.height
              clip: true

              property var activeRow: displayModel.count > 0 && root.selectedIndex >= 0 && root.selectedIndex < displayModel.count ? displayModel.get(root.selectedIndex) : null
              readonly property string activeImage: activeRow && activeRow.entryType === "image" ? (root.imageFiles[activeRow.clipId] || "") : ""

              Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Style.normalBorderWidth
                color: Util.alpha(root.border, 0.28)
              }

              Image {
                visible: status === Image.Ready
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                source: parent.activeImage
                sourceSize.width: 1600
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignTop
                asynchronous: true
                cache: false
              }

              Text {
                visible: parent.activeRow !== null && parent.activeImage === ""
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                text: parent.activeRow ? parent.activeRow.fullText : ""
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                verticalAlignment: Text.AlignTop
              }
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰅌"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              text: root.rawItems.length === 0 ? "Clipboard is empty" : "No matches for “" + root.filterText + "”"
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }
          }
        }
      }
    }
  }
}