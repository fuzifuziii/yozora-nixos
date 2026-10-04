import QtQuick
import qs.Commons

// label that introduces a panel section
Text {
  id: root

  property color foreground: Color.foreground
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.caption

  color: Qt.darker(foreground, 1.4)
  font.family: fontFamily
  font.pixelSize: fontSize
  font.bold: true

  // glyphs can paint above the text box, pad the header
  topPadding: Math.ceil(fontSize * 0.15)
}
