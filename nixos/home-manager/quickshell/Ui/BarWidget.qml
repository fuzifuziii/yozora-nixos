import QtQuick
import qs.Commons

// base item for bar widgets
Item {
  id: root

  property QtObject bar: null
  property string moduleName: ""
  property var settings: ({})

  // bar geometry lifted off the host
  readonly property bool vertical: bar ? bar.vertical : false
  readonly property int barSize: bar ? bar.barSize : Style.bar.sizeHorizontal

  // run method on every live instance of this widget
  function broadcast(method) {
    var items = bar && typeof bar.moduleWidgets === "function"
      ? bar.moduleWidgets(moduleName) : [root]
    for (var i = 0; i < items.length; i++) {
      if (items[i] && typeof items[i][method] === "function") items[i][method]()
    }
  }

  // read a setting from the inline shell.json entry
  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }
}
