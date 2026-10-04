import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

PanelWindow {
  id: root

  required property Item anchorItem
  required property QtObject bar
  property var owner: null
  property int margin: Style.gapsOut
  property int padding: Style.spacing.popupPadding
  property int contentWidth: Style.space(280)
  property int contentHeight: Style.space(200)
  property real cardRadius: Style.cornerRadius
  property color borderColor: Color.popups.border
  property var borderSpec: Border.localOrSurfaceSpec("popups", "border", borderColor, Color.popups.border, Math.max(1, Style.space(2)))
  property bool open: false
  property bool centerOnBar: false
  property string triggerMode: "click"

  readonly property var coordinatorKey: owner || root
  readonly property var anchorWindow: anchorItem ? anchorItem.QsWindow.window : null
  readonly property var popupScreen: anchorWindow ? anchorWindow.screen : null
  readonly property bool containsMouse: cardHover.hovered
  readonly property real screenW: popupScreen ? popupScreen.width : (screen ? screen.width : 0)
  readonly property real screenH: popupScreen ? popupScreen.height : (screen ? screen.height : 0)
  readonly property real barW: anchorWindow ? anchorWindow.width : 0
  readonly property real barH: anchorWindow ? anchorWindow.height : 0
  readonly property real availableCardWidth: screenW > 0
    ? Math.max(120, screenW - ((bar && (bar.position === "left" || bar.position === "right")) ? barW : 0) - root.margin * 2)
    : 0
  readonly property real availableCardHeight: screenH > 0
    ? Math.max(120, screenH - ((bar && (bar.position === "top" || bar.position === "bottom")) ? barH : 0) - root.margin * 2)
    : 0
  readonly property real verticalContentInset: padding * 2 + Border.top(borderSpec) + Border.bottom(borderSpec)

  function fittedContentWidth(width, cap) {
    var desired = Math.max(1, Number(width) || 1)
    var maxWidth = root.availableCardWidth > 0 ? root.availableCardWidth : desired
    if (cap !== undefined && Number(cap) > 0) maxWidth = Math.min(maxWidth, Number(cap))
    return Math.round(Math.min(desired, maxWidth))
  }

  function fittedContentHeight(implicitHeight, cap) {
    var desired = Math.max(root.verticalContentInset, (Number(implicitHeight) || 0) + root.verticalContentInset)
    var maxHeight = root.availableCardHeight > 0 ? root.availableCardHeight : desired
    if (cap !== undefined && Number(cap) > 0) maxHeight = Math.min(maxHeight, Number(cap))
    return Math.round(Math.min(desired, maxHeight))
  }

  function cappedContentHeight(height) {
    var desired = Math.max(root.padding * 2, Number(height) || root.padding * 2)
    var maxHeight = root.availableCardHeight > 0 ? root.availableCardHeight : desired
    return Math.round(Math.min(desired, maxHeight))
  }

  function anchoredRect() {
    if (!anchorItem || !bar || !anchorItem.QsWindow || !anchorItem.QsWindow.window)
      return { x: 0, y: 0 }

    var window = anchorItem.QsWindow.window
    var popupWidth = root.contentWidth
    var popupHeight = root.contentHeight
    var localX = anchorItem.width / 2 - popupWidth / 2
    var localY = anchorItem.height + margin

    if (bar.position === "bottom") {
      localY = -popupHeight - margin
    } else if (bar.position === "left") {
      localX = anchorItem.width + margin
      localY = anchorItem.height / 2 - popupHeight / 2
    } else if (bar.position === "right") {
      localX = -popupWidth - margin
      localY = anchorItem.height / 2 - popupHeight / 2
    }

    if (centerOnBar) {
      var cx = 0
      var cy = 0
      if (bar.position === "top" || bar.position === "bottom") {
        cx = window.width / 2 - popupWidth / 2
        cy = bar.position === "bottom" ? -popupHeight - margin : window.height + margin
        cx = Math.max(margin, Math.min(cx, window.width - popupWidth - margin))
      } else {
        cx = bar.position === "left" ? window.width + margin : -popupWidth - margin
        cy = window.height / 2 - popupHeight / 2
        cy = Math.max(margin, Math.min(cy, window.height - popupHeight - margin))
      }
      return { x: Math.round(cx), y: Math.round(cy) }
    }

    var point = anchorItem.mapToItem(window.contentItem, localX, localY)
    if (bar.position === "top" || bar.position === "bottom")
      point.x = Math.max(margin, Math.min(point.x, window.width - popupWidth - margin))
    else
      point.y = Math.max(margin, Math.min(point.y, window.height - popupHeight - margin))
    return { x: Math.round(point.x), y: Math.round(point.y) }
  }

  readonly property var _anchoredRect: anchoredRect()

  readonly property real barScreenX: {
    if (!anchorWindow) return 0
    var m = anchorWindow.margins
    var ml = (m && m.left) ? m.left : 0
    var mr = (m && m.right) ? m.right : 0
    if (bar && bar.position === "right") {
      return root.screenW - anchorWindow.width - mr
    }
    return ml
  }

  readonly property real barScreenY: {
    if (!anchorWindow) return 0
    var m = anchorWindow.margins
    var mt = (m && m.top) ? m.top : 0
    var mb = (m && m.bottom) ? m.bottom : 0
    if (bar && bar.position === "bottom") {
      return root.screenH - anchorWindow.height - mb
    }
    return mt
  }

  readonly property int cardScreenX: {
    var x = Math.round(barScreenX + _anchoredRect.x)
    return Math.max(margin, Math.min(x, Math.max(margin, root.screenW - root.contentWidth - margin)))
  }

  readonly property int cardScreenY: {
    var y = Math.round(barScreenY + _anchoredRect.y)
    return Math.max(margin, Math.min(y, Math.max(margin, root.screenH - root.contentHeight - margin)))
  }

  function close() {
    if (owner && "close" in owner) owner.close()
    else root.open = false
  }

  default property alias contentItem: contentHolder.children

  implicitWidth: contentWidth
  implicitHeight: contentHeight
  screen: root.popupScreen
  visible: open || card.opacity > 0
  color: "transparent"

  WlrLayershell.namespace: "fuzi-popup"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  onOpenChanged: {
    if (!bar) return
    if (open) bar.requestPopout(coordinatorKey)
    else if (bar.activePopout === coordinatorKey) bar.releasePopout(coordinatorKey)
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.open && root.triggerMode === "click"
    onClicked: root.close()
  }

  BorderSurface {
    id: card
    x: root.cardScreenX
    y: root.cardScreenY
    width: root.contentWidth
    height: root.contentHeight
    color: Color.popups.background
    borderSpec: root.borderSpec
    padding: root.padding
    radius: root.cardRadius
    opacity: root.open ? 1.0 : 0

    Behavior on opacity {
      NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {}
    }

    Item {
      id: contentHolder
      anchors.fill: parent
      anchors.topMargin: card.contentTopInset
      anchors.rightMargin: card.contentRightInset
      anchors.bottomMargin: card.contentBottomInset
      anchors.leftMargin: card.contentLeftInset
    }

    HoverHandler {
      id: cardHover
    }
  }
}
