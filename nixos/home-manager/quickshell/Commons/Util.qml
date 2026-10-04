pragma Singleton
import Quickshell
import QtQuick

// pure shared helpers, no state
QtObject {
  id: root

  function clamp(value, min, max) {
    var n = Number(value)
    if (!isFinite(n)) return min
    return Math.max(min, Math.min(max, n))
  }

  function clampAlpha(value) {
    return clamp(value, 0, 1)
  }

  function wheelSteps(accumulator, delta) {
    // one wheel event is one step, accumulate touchpad deltas
    delta = Math.max(-120, Math.min(120, delta))
    if (accumulator * delta < 0) accumulator = 0
    var total = accumulator + delta
    var steps = total < 0 ? Math.ceil(total / 120) : Math.floor(total / 120)
    return { steps: steps, remainder: total - steps * 120 }
  }

  // compose a color with an opacity
  function alpha(c, opacity) {
    var a = clampAlpha(opacity)
    if (!c) return Qt.rgba(0, 0, 0, a)
    if (typeof c === "string") c = Qt.color(c)
    return Qt.rgba(c.r, c.g, c.b, a)
  }

  // file:// URL with percent-encoded path segments
  function fileUrl(path) {
    if (!path) return ""
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
  }

  // single-quote a string for bash
  function shellQuote(value) {
    return "'" + String(value || "").replace(/'/g, "'\\''") + "'"
  }

  function execDetached(command) {
    Quickshell.execDetached(["bash", "-lc", command])
  }

  function isPlainObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value)
  }

  function canonicalWidgetId(id) {
    return String(id || "")
  }

  // best-effort base64 decode
  function decodeBase64(value) {
    var s = String(value || "")
    if (!s) return ""
    try { return Qt.atob(s) } catch (e) { return "" }
  }

  function cloneJson(value) {
    return JSON.parse(JSON.stringify(value === undefined ? null : value))
  }

  // parse the last output line as waybar-style JSON
  function parseModuleJson(raw) {
    var text = String(raw || "").trim()
    if (!text) return {}
    var lines = text.split("\n")
    try {
      return JSON.parse(lines[lines.length - 1])
    } catch (e) {
      return { text: text }
    }
  }

  // text-editing keys shared by filter fields
  function editsFilter(event, text) {
    if (!text) return false
    // leave Alt/Meta sequences to other shortcuts
    if (event.modifiers & (Qt.AltModifier | Qt.MetaModifier)) return false
    if (event.key === Qt.Key_U)                     // Ctrl+U only (not Ctrl+Shift+U → Unicode input)
      return event.modifiers === Qt.ControlModifier
    return event.key === Qt.Key_Backspace           // plain, Shift, or Ctrl Backspace
  }

  // new filter text after an edit key
  function editedFilter(event, text) {
    if (event.key === Qt.Key_U) return ""                        // Ctrl+U: clear
    if (event.modifiers & Qt.ControlModifier)                    // Ctrl+Backspace: word
      return text.replace(/\s+$/, "").replace(/\S+$/, "")
    return text.slice(0, -1)                                     // Backspace: char
  }

  // normalize bar layout, deep-clone entries
  function normalizeLayoutEntry(entry) {
    if (typeof entry === "string") return { id: canonicalWidgetId(entry) }
    if (isPlainObject(entry) && entry.id) {
      var copy = cloneJson(entry)
      copy.id = canonicalWidgetId(copy.id)
      return copy
    }
    return null
  }

  function normalizeLayoutSection(list) {
    if (!Array.isArray(list)) return []
    var out = []
    for (var i = 0; i < list.length; i++) {
      var e = normalizeLayoutEntry(list[i])
      if (e) out.push(e)
    }
    return out
  }

  function normalizeLayout(layout) {
    var src = isPlainObject(layout) ? layout : {}
    return {
      left:   normalizeLayoutSection(src.left),
      center: normalizeLayoutSection(src.center),
      right:  normalizeLayoutSection(src.right)
    }
  }
}
