import Quickshell
import QtQuick
import qs.Commons
import qs.Ui

// Cascading submenu drawn inside the fullscreen host window (no xdg_popup).
// Rows are TrayMenuRow, so nesting works to any depth.
Item {
  id: subRoot
  required property QtObject ownerRoot
  required property Item anchorItem
  required property var menuEntry
  required property real rowWidth
  readonly property bool pointerInside: subHover.hovered
  property bool open: false

  // Attached contentItem is the real window root (PopupCard shadows window.contentItem)
  readonly property Item hostRoot: anchorItem && anchorItem.QsWindow ? anchorItem.QsWindow.contentItem : null
  readonly property real cardPad: Style.space(8)

  visible: open
  z: 1000
  width: rowWidth
  height: subCard.contentHeightHint

  // Reparent into the host window so coordinates are window-local
  parent: hostRoot

  // Place the card to the left of the parent card, aligned with the row
  function reposition() {
    if (!anchorItem || !hostRoot) return
    var p = anchorItem.mapToItem(hostRoot, 0, 0)
    var nx = p.x - cardPad - width + 1
    var ny = p.y - cardPad
    // Flip to the right side if there is no room on the left
    if (nx < 0) nx = p.x + anchorItem.width + cardPad - 1
    ny = Math.max(0, Math.min(ny, hostRoot.height - height))
    x = Math.round(nx)
    y = Math.round(ny)
  }

  Component.onCompleted: Qt.callLater(reposition)
  onOpenChanged: if (open) Qt.callLater(reposition)
  onHeightChanged: if (open) Qt.callLater(reposition)

  QsMenuOpener {
    id: subOpener
    menu: subRoot.menuEntry
  }

  BorderSurface {
    id: subCard
    anchors.fill: parent
    color: Color.popups.background
    borderSpec: Border.localOrSurfaceSpec("popups", "border", Color.popups.border, Color.popups.border, Math.max(1, Style.space(2)))
    padding: Style.space(8)
    radius: Style.cornerRadius

    readonly property real contentHeightHint: subColumn.implicitHeight + padding * 2

    // Swallow clicks so the outside-click catcher does not close the menu
    MouseArea {
      anchors.fill: parent
      onClicked: {}
    }

    Column {
      id: subColumn
      width: subRoot.rowWidth - Style.space(16)
      x: Style.space(8)
      y: Style.space(8)
      spacing: 0

      Repeater {
        model: subOpener.children
        delegate: TrayMenuRow {
          rowWidth: subColumn.width
          ownerRoot: subRoot.ownerRoot
          applyTitleDedup: false
        }
      }
    }
  }

  HoverHandler {
    id: subHover
  }
}
