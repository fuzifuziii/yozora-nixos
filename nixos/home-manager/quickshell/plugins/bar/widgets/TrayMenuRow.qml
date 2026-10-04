import Quickshell
import QtQuick
import qs.Commons

// one row of a possibly nested context menu
Item {
  id: menuRow
  required property var modelData
  property int index: -1
  required property QtObject ownerRoot
  property var activeTrayItem: null
  property bool applyTitleDedup: false
  required property real rowWidth

  readonly property string rowText: String(modelData.text || "")
  readonly property string activeTitle: activeTrayItem ? String(activeTrayItem.title || activeTrayItem.id || "") : ""
  readonly property bool rootTitleEntry: applyTitleDedup && index === 0 && modelData.hasChildren && rowText.toLowerCase() === activeTitle.toLowerCase()
  readonly property bool leadingSeparator: applyTitleDedup && modelData.isSeparator && index <= 1
  readonly property bool hiddenRow: rootTitleEntry || leadingSeparator
  readonly property bool hasChildrenVisible: !modelData.isSeparator && modelData.hasChildren

  visible: !hiddenRow
  width: rowWidth
  implicitHeight: hiddenRow ? 0 : (modelData.isSeparator ? Style.space(11) : Style.space(30))
  opacity: modelData.enabled ? 1.0 : 0.45

  Rectangle {
    visible: menuRow.modelData.isSeparator
    anchors.left: parent.left
    anchors.leftMargin: Style.space(10)
    anchors.right: parent.right
    anchors.rightMargin: Style.space(10)
    anchors.verticalCenter: parent.verticalCenter
    height: 1
    color: Color.popups.border
    opacity: 0.45
  }

  Rectangle {
    visible: !menuRow.modelData.isSeparator
    anchors.fill: parent
    radius: Math.max(2, Style.cornerRadius)
    color: (rowMouse.containsMouse || menuRow.hasChildrenVisible && submenuLoader.active) && menuRow.modelData.enabled
      ? Style.hoverFillFor(menuRow.ownerRoot.foreground, menuRow.ownerRoot.foreground)
      : "transparent"
  }

  Text {
    visible: !menuRow.modelData.isSeparator && menuRow.modelData.buttonType !== QsMenuButtonType.None
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    width: Style.space(22)
    horizontalAlignment: Text.AlignHCenter
    text: menuRow.modelData.checkState === Qt.Checked ? "\uf00c" : ""
    color: menuRow.ownerRoot.foreground
    font.family: menuRow.ownerRoot.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  Image {
    id: menuIcon
    visible: !menuRow.modelData.isSeparator && String(menuRow.modelData.icon || "") !== ""
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Style.space(24)
    width: Style.space(16)
    height: Style.space(16)
    fillMode: Image.PreserveAspectFit
    sourceSize.width: width * Screen.devicePixelRatio
    sourceSize.height: height * Screen.devicePixelRatio
    source: menuRow.modelData.icon
  }

  Text {
    visible: !menuRow.modelData.isSeparator
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: menuIcon.visible ? Style.space(46) : Style.space(28)
    anchors.right: parent.right
    anchors.rightMargin: Style.space(8)
    text: menuRow.rowText
    color: menuRow.ownerRoot.foreground
    font.family: menuRow.ownerRoot.fontFamily
    font.pixelSize: Style.font.bodySmall
    elide: Text.ElideRight
  }

  Text {
    visible: !menuRow.modelData.isSeparator && menuRow.modelData.hasChildren
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Style.space(10)
    text: "\u2039"
    color: menuRow.ownerRoot.foreground
    font.family: menuRow.ownerRoot.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  Timer {
    id: submenuOpenTimer
    interval: 180
    onTriggered: submenuLoader.active = true
  }

  Timer {
    id: submenuCloseTimer
    interval: 250
    onTriggered: {
      if (!rowMouse.containsMouse && !(submenuLoader.item && submenuLoader.item.pointerInside)) {
        submenuLoader.active = false
      }
    }
  }

  // tear down the submenu when the whole menu closes
  Connections {
    target: menuRow.ownerRoot
    function onTrayMenuOpenChanged() {
      if (!menuRow.ownerRoot.trayMenuOpen) submenuLoader.active = false
    }
  }

  Loader {
    id: submenuLoader
    active: false
    onActiveChanged: {
      if (active) {
        // load by URL to avoid a QML type cycle
        setSource("TraySubmenu.qml", {
          ownerRoot: menuRow.ownerRoot,
          anchorItem: menuRow,
          menuEntry: menuRow.modelData,
          rowWidth: menuRow.rowWidth
        })
      } else {
        source = ""
      }
    }
    onLoaded: {
      item.open = true
      item.pointerInsideChanged.connect(function() {
        if (item.pointerInside) submenuCloseTimer.stop()
        else submenuCloseTimer.restart()
      })
    }
  }

  MouseArea {
    id: rowMouse
    anchors.fill: parent
    hoverEnabled: true
    enabled: !menuRow.modelData.isSeparator && menuRow.modelData.enabled
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onEntered: {
      submenuCloseTimer.stop()
      if (menuRow.hasChildrenVisible) submenuOpenTimer.restart()
    }
    onExited: {
      submenuOpenTimer.stop()
      if (menuRow.hasChildrenVisible) submenuCloseTimer.restart()
    }
    onClicked: {
      if (menuRow.hasChildrenVisible) {
        submenuOpenTimer.stop()
        submenuLoader.active = true
      } else {
        menuRow.modelData.triggered()
        menuRow.ownerRoot.close()
      }
    }
  }
}
