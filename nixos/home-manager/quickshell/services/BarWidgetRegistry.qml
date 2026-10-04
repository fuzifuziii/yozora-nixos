import QtQuick

// instance, not a singleton, injected by shell.qml
QtObject {
  id: registry

  // { widgetId: { component: Component, metadata: var } }
  property var widgets: ({})
  property int revision: 0

  signal changed()

  function register(id, component, metadata) {
    var key = String(id)
    if (!key) return
    var next = {}
    for (var k in widgets) next[k] = widgets[k]
    next[key] = { component: component, metadata: metadata || {} }
    widgets = next
    revision++
    changed()
  }

  function unregister(id) {
    var key = String(id)
    if (!widgets[key]) return
    var next = {}
    for (var k in widgets) if (k !== key) next[k] = widgets[k]
    widgets = next
    revision++
    changed()
  }

  function availableIds() {
    return Object.keys(widgets)
  }

  function has(id) {
    return widgets[String(id)] !== undefined
  }
}
