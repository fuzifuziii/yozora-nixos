import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Commons

import "components"
import "NotificationLogic.js" as NotificationLogic

Item {
  id: service

  property var shell: null

  property string fuziPath: Quickshell.env("FUZI_PATH")
  readonly property string home: Quickshell.env("HOME")
  // persistent history under the state dir
  readonly property string stateDir: home + "/.local/share/fuzi/"
  readonly property string historyPath: stateDir + "notifications.json"
  readonly property string cacheDir: home + "/.cache/fuzi/"
  readonly property string imageCacheDir: cacheDir + "notification-images/"
  readonly property int cornerRadius: Style.cornerRadius
  readonly property string barPosition: shell && shell.barConfig ? String(shell.barConfig.position || "top") : "top"
  readonly property bool barVertical: barPosition === "left" || barPosition === "right"
  readonly property int defaultBarSize: barVertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal
  readonly property int liveBarSize: shell && shell.bar && !shell.bar.barHidden ? Math.max(0, shell.bar.barSize) : defaultBarSize
  readonly property int barClearance: liveBarSize + Style.gapsOut

  property var liveRefs: ({})

  PersistentProperties {
    id: persisted
    reloadableId: "fuzi-notifications"
    property bool doNotDisturb: false
    property bool doNotDisturbFullscreen: false
    onDoNotDisturbChanged: {
      if (service._hydrating) return
      service.scheduleHistorySave()
    }
  }

  property bool _hydrating: false

  readonly property alias doNotDisturb: persisted.doNotDisturb
  readonly property alias doNotDisturbFullscreen: persisted.doNotDisturbFullscreen
  property var fullscreenMonitors: ({})
  property var fullscreenMonitorIds: ({})

  function monitorIsFullscreen(name) {
    return !!fullscreenMonitors[String(name || "")]
  }

  function screenIsFullscreen(screen) {
    if (!screen) return false
    if (fullscreenMonitorIds[String(screen.id)] === true) return true
    return monitorIsFullscreen(screen.name)
  }

  function setDoNotDisturb(value) {
    persisted.doNotDisturb = !!value
  }

  function setDoNotDisturbFullscreen(value) {
    persisted.doNotDisturbFullscreen = !!value
  }

  property alias popupModel: popupModel
  property alias pendingModel: pendingModel
  property alias pastModel: pastModel
  ListModel { id: popupModel }
  ListModel { id: pendingModel }
  ListModel { id: pastModel }

  readonly property int historyCap: 100
  readonly property int historyReplayLimit: 5
  property var imageCacheQueue: []

  readonly property int lowPopupDuration: 5000
  readonly property int normalPopupDuration: 8000
  readonly property int maxPopupDuration: 30000

  function durationFor(urgency, expireTimeout) {
    switch (urgency) {
    case NotificationUrgency.Critical:
      return 0
    case NotificationUrgency.Low:
      return Math.min(maxPopupDuration, Math.max(lowPopupDuration, requestedDuration(expireTimeout)))
    default:
      return Math.min(maxPopupDuration, Math.max(normalPopupDuration, requestedDuration(expireTimeout)))
    }
  }

  function requestedDuration(expireTimeout) {
    var ms = Number(expireTimeout || 0)
    if (!isFinite(ms) || ms <= 0) return 0
    return Math.round(ms)
  }

  function shouldBypassDnd(notification) {
    return NotificationLogic.shouldBypassDnd(notification, NotificationUrgency.Critical)
  }

  function snapshotOf(notification) {
    return NotificationLogic.snapshotOf(notification, Date.now())
  }

  function handleNotification(notification) {
    notification.tracked = true
    var snapshot = snapshotOf(notification)
    liveRefs[snapshot.originalId] = notification
    notification.closed.connect(function() {
      if (service.liveRefs[snapshot.originalId] === notification)
        delete service.liveRefs[snapshot.originalId]
    })

    var transient = false
    try {
      transient = !!(notification.hints && notification.hints["transient"])
    } catch (e) { transient = false }
    var appName = String(notification.appName || "")
    var ephemeralApp = NotificationLogic.isEphemeralApp(appName)
    if (transient || ephemeralApp) {
      if (service.doNotDisturb && !shouldBypassDnd(notification)) {
        delete liveRefs[snapshot.originalId]
        notification.tracked = false
        return
      }
      Qt.callLater(function() {
        removeByOriginalId(popupModel, snapshot.originalId)
        popupModel.insert(0, snapshot)
      })
      return
    }

    addToPending(snapshot)
    maybeCacheImage(snapshot)

    if (service.doNotDisturb && !shouldBypassDnd(notification)) {
      delete liveRefs[snapshot.originalId]
      notification.tracked = false
      return
    }

    Qt.callLater(function() {
      removeByOriginalId(popupModel, snapshot.originalId)
      popupModel.insert(0, snapshot)
    })
  }

  function removeByOriginalId(model, originalId) {
    for (var i = model.count - 1; i >= 0; i--) {
      var row = model.get(i)
      if (row && row.originalId === originalId) model.remove(i)
    }
  }

  function addToPending(snapshot) {
    Qt.callLater(function() {
      removeByOriginalId(pendingModel, snapshot.originalId)
      pendingModel.insert(0, snapshot)
      while (pendingModel.count > service.historyCap) {
        pendingModel.remove(pendingModel.count - 1)
      }
      service.scheduleHistorySave()
    })
  }

  function markSeenByOriginalId(originalId) {
    Qt.callLater(function() {
      for (var i = 0; i < pendingModel.count; i++) {
        var entry = pendingModel.get(i)
        if (!entry || entry.originalId !== originalId) continue
        var snapshot = service.snapshotFromRow(entry)
        pendingModel.remove(i)
        pastModel.insert(0, snapshot)
        while (pastModel.count > service.historyCap) {
          pastModel.remove(pastModel.count - 1)
        }
        service.scheduleHistorySave()
        return
      }
    })
  }

  function snapshotFromRow(row) {
    return {
      id: row.id,
      originalId: row.originalId,
      app: row.app,
      appIcon: row.appIcon,
      summary: row.summary,
      body: row.body,
      image: row.image,
      glyph: row.glyph || "",
      urgency: row.urgency,
      expireTimeout: row.expireTimeout || 0,
      timestamp: row.timestamp
    }
  }

  function markAllSeen() {
    Qt.callLater(function() {
      while (pendingModel.count > 0) {
        var entry = pendingModel.get(0)
        var snapshot = service.snapshotFromRow(entry)
        pendingModel.remove(0)
        pastModel.insert(0, snapshot)
      }
      while (pastModel.count > service.historyCap) {
        pastModel.remove(pastModel.count - 1)
      }
      service.scheduleHistorySave()
    })
  }

  function dismissPopup(index) {
    removePopup(index, "dismiss")
  }

  function expirePopup(index) {
    removePopup(index, "expire")
  }

  function removePopup(index, reason) {
    if (index < 0 || index >= popupModel.count) return
    var entry = popupModel.get(index)
    var originalId = entry ? entry.originalId : -1
    var ref = originalId >= 0 ? liveRefs[originalId] : null
    popupModel.remove(index)
    if (ref) {
      try {
        if (ref.tracked) {
          if (reason === "expire" && typeof ref.expire === "function") ref.expire()
          else ref.dismiss()
        }
      } catch (e) {
      }
    }
    if (originalId >= 0) markSeenByOriginalId(originalId)
  }

  function clearPopups() {
    while (popupModel.count > 0) dismissPopup(0)
  }

  function rowsFromModel(model) {
    var rows = []
    for (var i = 0; i < model.count; i++) {
      var entry = model.get(i)
      if (entry) rows.push(snapshotFromRow(entry))
    }
    return rows
  }

  function showRecentHistory() {
    var rows = NotificationLogic.recentHistoryRows(
      rowsFromModel(pendingModel),
      rowsFromModel(pastModel),
      service.historyReplayLimit,
      NotificationUrgency.Normal)

    if (rows.length === 0) {
      popupModel.insert(0, {
        id: -1,
        originalId: -1,
        app: "fuzi-action",
        appIcon: "",
        summary: "No recent notifications",
        body: "",
        image: "",
        glyph: "󰂚",
        urgency: NotificationUrgency.Low,
        expireTimeout: 0,
        timestamp: Date.now()
      })
      return "none"
    }

    clearPopups()
    for (var i = 0; i < rows.length; i++) {
      popupModel.append(rows[i])
    }
    return "ok"
  }

  function dismissPending(index) {
    if (index < 0 || index >= pendingModel.count) return
    var entry = pendingModel.get(index)
    if (entry) maybeDeleteCachedImage(entry.image)
    pendingModel.remove(index)
    scheduleHistorySave()
  }

  function dismissPast(index) {
    if (index < 0 || index >= pastModel.count) return
    var entry = pastModel.get(index)
    if (entry) maybeDeleteCachedImage(entry.image)
    pastModel.remove(index)
    scheduleHistorySave()
  }

  function clearPending() {
    for (var i = 0; i < pendingModel.count; i++) {
      var entry = pendingModel.get(i)
      if (entry) maybeDeleteCachedImage(entry.image)
    }
    pendingModel.clear()
    scheduleHistorySave()
  }

  function clearPast() {
    for (var i = 0; i < pastModel.count; i++) {
      var entry = pastModel.get(i)
      if (entry) maybeDeleteCachedImage(entry.image)
    }
    pastModel.clear()
    scheduleHistorySave()
  }

  function invokePopupDefault(index) {
    if (index < 0 || index >= popupModel.count) return
    var entry = popupModel.get(index)
    var ref = entry ? liveRefs[entry.originalId] : null
    var invoked = false
    try {
      if (ref && ref.actions) {
        for (var i = 0; i < ref.actions.length; i++) {
          var action = ref.actions[i]
          if (action && action.identifier === "default") {
            action.invoke()
            invoked = true
            break
          }
        }
      }
    } catch (e) {
      console.warn("invoke default failed:", e)
    }
    if (!invoked) focusApp(entry)
    dismissPopup(index)
  }

  function focusApp(entry) {
    if (!entry || !entry.app) return
    focusAppProc.command = [
      "mmsg", "dispatch", "focusclient," + String(entry.app)
    ]
    focusAppProc.running = true
  }

  Process { id: focusAppProc; running: false }

  property string activeWindowClass: ""
  property string activeWindowTitle: ""
  property bool activeWindowFullscreen: false

  function normalizedApp(value) {
    return String(value || "").toLowerCase()
      .replace(/\.desktop$/g, "")
      .replace(/[^a-z0-9]+/g, "")
  }

  function activeAppMatches(entry) {
    if (!entry) return false
    var klass = normalizedApp(activeWindowClass)
    var title = normalizedApp(activeWindowTitle)
    var candidates = [entry.app, entry.appIcon]
    for (var i = 0; i < candidates.length; i++) {
      var app = normalizedApp(candidates[i])
      if (!app) continue
      if (klass && (klass === app || klass.indexOf(app) !== -1 || app.indexOf(klass) !== -1)) return true
      if (title && title.indexOf(app) !== -1) return true
    }
    return false
  }

  function dismissPopupsForActiveApp() {
    for (var i = popupModel.count - 1; i >= 0; i--) {
      var row = popupModel.get(i)
      if (activeAppMatches(row)) dismissPopup(i)
    }
  }

  Process {
    id: activeWindowProc
    command: ["mmsg", "get", "focusing-client"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var window = JSON.parse(String(text || "{}"))
          service.activeWindowClass = String(window.appid || window.app_id || window.class || "")
          service.activeWindowTitle = String(window.title || "")
          service.activeWindowFullscreen = Boolean(window.is_fullscreen !== undefined ? window.is_fullscreen : window.fullscreen)
          service.dismissPopupsForActiveApp()
        } catch (e) {
          service.activeWindowClass = ""
          service.activeWindowTitle = ""
          service.activeWindowFullscreen = false
        }
      }
    }
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!activeWindowProc.running) activeWindowProc.running = true
  }

  Process {
    id: monitorProc
    command: ["bash", "-lc", "printf '{\"all_tags\":'; mmsg get all-tags 2>/dev/null || echo '[]'; printf ',\"clients\":'; (mmsg get clients 2>/dev/null || mmsg get all-clients 2>/dev/null || echo '[]'); printf '}'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var snapshot = JSON.parse(String(text || "{}"))
          var monitors = Array.isArray(snapshot.monitors) ? snapshot.monitors : (Array.isArray(snapshot.all_tags) ? snapshot.all_tags : [])
          var clients = Array.isArray(snapshot.clients) ? snapshot.clients : []
          var namesById = ({})
          var activeWorkspaceByMonitor = ({})
          for (var m = 0; m < monitors.length; m++) {
            var mon = monitors[m]
            if (mon && mon.name !== undefined) {
              var mId = String(mon.id !== undefined ? mon.id : m)
              namesById[mId] = String(mon.name)
              if (mon.activeWorkspace) {
                activeWorkspaceByMonitor[mId] = Number(mon.activeWorkspace.id)
              }
            }
          }
          var next = ({})
          var nextIds = ({})
          for (var i = 0; i < clients.length; i++) {
            var client = clients[i]
            if (!client || !client.fullscreen) continue
            var monKey = String(client.monitor !== undefined ? client.monitor : "")
            var name = namesById[monKey]
            if (name) next[name] = true
            if (monKey) nextIds[monKey] = true
          }
          service.fullscreenMonitors = next
          service.fullscreenMonitorIds = nextIds
        } catch (e) {
          service.fullscreenMonitors = ({})
          service.fullscreenMonitorIds = ({})
        }
      }
    }
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!monitorProc.running) monitorProc.running = true
  }

  function imageExtension(srcPath) {
    return NotificationLogic.imageExtension(srcPath)
  }

  function maybeCacheImage(snapshot) {
    var image = String(snapshot.image || "")
    if (!image) return
    if (image.indexOf("image://") === 0) return
    if (image.indexOf("file:///tmp/") !== 0) return

    var srcPath = decodeURIComponent(image.substring(7))
    var ext = imageExtension(srcPath)
    var destPath = imageCacheDir + snapshot.timestamp + "-" + snapshot.originalId + "." + ext
    var destUri = Util.fileUrl(destPath)

    imageCacheQueue = imageCacheQueue.concat([{
      srcPath: srcPath,
      destPath: destPath,
      targetUri: destUri,
      originalId: snapshot.originalId,
      timestamp: snapshot.timestamp
    }])
    runNextImageCacheJob()
  }

  function runNextImageCacheJob() {
    if (imageCacheProc.running || imageCacheQueue.length === 0) return

    var job = imageCacheQueue[0]
    imageCacheQueue = imageCacheQueue.slice(1)
    imageCacheProc.targetUri = job.targetUri
    imageCacheProc.matchOriginalId = job.originalId
    imageCacheProc.matchTimestamp = job.timestamp
    imageCacheProc.command = ["cp", "-f", job.srcPath, job.destPath]
    imageCacheProc.running = true
  }

  function rewriteCachedImage(targetUri, originalId, timestamp) {
    function rewrite(model) {
      for (var i = 0; i < model.count; i++) {
        var row = model.get(i)
        if (row && row.originalId === originalId && row.timestamp === timestamp) {
          model.setProperty(i, "image", targetUri)
          return true
        }
      }
      return false
    }

    return rewrite(pendingModel) || rewrite(pastModel)
  }

  function maybeDeleteCachedImage(image) {
    var path = String(image || "")
    if (!path) return
    if (path.indexOf("file://") !== 0) return
    var local = decodeURIComponent(path.substring(7))
    if (local.indexOf(imageCacheDir) !== 0) return
    deleteImageProc.command = ["rm", "-f", local]
    deleteImageProc.running = true
  }

  Process {
    id: ensureDirsProc
    command: ["mkdir", "-p", service.stateDir, service.imageCacheDir]
    running: false
  }

  Process {
    id: imageCacheProc
    property string targetUri: ""
    property int matchOriginalId: -1
    property double matchTimestamp: 0
    onExited: function(exitCode) {
      if (exitCode === 0 && targetUri && rewriteCachedImage(targetUri, matchOriginalId, matchTimestamp))
        scheduleHistorySave()
      targetUri = ""
      matchOriginalId = -1
      matchTimestamp = 0
      runNextImageCacheJob()
    }
  }

  Process { id: deleteImageProc; running: false }

  FileView {
    id: historyFile
    path: service.historyPath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: service.loadHistory(text())
    onLoadFailed: service.loadHistory("")
  }

  Timer {
    id: historySaveTimer
    interval: 200
    repeat: false
    onTriggered: service.flushHistory()
  }

  readonly property int pastTtlMs: 15 * 60 * 1000

  Timer {
    interval: 60 * 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: service.prunePast()
  }

  function prunePast() {
    if (pastModel.count === 0) return
    var cutoff = Date.now() - service.pastTtlMs
    var removed = false
    for (var i = pastModel.count - 1; i >= 0; i--) {
      var entry = pastModel.get(i)
      if (entry && entry.timestamp && entry.timestamp < cutoff) {
        if (entry.image) maybeDeleteCachedImage(entry.image)
        pastModel.remove(i)
        removed = true
      }
    }
    if (removed) scheduleHistorySave()
  }

  function scheduleHistorySave() {
    if (!service.historyLoaded) return
    historySaveTimer.restart()
  }

  property bool historyLoaded: false

  function loadHistory(raw) {
    if (service.historyLoaded) return

    var parsed = NotificationLogic.parseHistory(raw, NotificationUrgency.Normal, service.historyCap)
    if (parsed.empty) {
      service.historyLoaded = true
      return
    }
    if (parsed.error) {
      console.warn("notifications: history parse failed:", parsed.errorMessage || "")
      service.historyLoaded = true
      return
    }

    if (parsed.dnd !== null) {
      service._hydrating = true
      persisted.doNotDisturb = parsed.dnd
      if (parsed.fullscreenDnd !== null) persisted.doNotDisturbFullscreen = parsed.fullscreenDnd
      service._hydrating = false
    }

    Qt.callLater(function() {
      for (var i = 0; i < parsed.pending.length; i++) pendingModel.append(parsed.pending[i])
      for (var j = 0; j < parsed.past.length; j++) pastModel.append(parsed.past[j])
      service.historyLoaded = true
      if (parsed.hadDuplicates) service.scheduleHistorySave()
    })
  }

  function flushHistory() {
    function dump(model) {
      var out = []
      for (var i = 0; i < model.count; i++) {
        var r = model.get(i)
        if (!r) continue
        out.push({
          id: r.id,
          originalId: r.originalId,
          app: r.app,
          appIcon: r.appIcon,
          summary: r.summary,
          body: r.body,
          image: r.image,
          glyph: r.glyph || "",
          urgency: r.urgency,
          expireTimeout: r.expireTimeout || 0,
          timestamp: r.timestamp
        })
      }
      return out
    }
    var payload = {
      version: 2,
      dnd: persisted.doNotDisturb,
      fullscreenDnd: persisted.doNotDisturbFullscreen,
      pending: dump(pendingModel),
      past: dump(pastModel)
    }
    historyFile.setText(JSON.stringify(payload, null, 2) + "\n")
  }

  Component.onCompleted: {
    ensureDirsProc.running = true
    Qt.callLater(function() { historyFile.reload() })
  }

  IpcHandler {
    target: "notifications"

    function dndState(): string {
      return service.doNotDisturb ? "on" : "off"
    }

    function toggleDnd(): string {
      service.setDoNotDisturb(!service.doNotDisturb)
      return dndState()
    }

    function setDnd(value: string): string {
      var v = String(value || "").toLowerCase()
      var on = v === "true" || v === "1" || v === "on" || v === "yes"
      service.setDoNotDisturb(on)
      return dndState()
    }

    function isDnd(): string {
      return dndState()
    }

    function showHistory(): string {
      return service.showRecentHistory()
    }

    function clear(): string {
      service.clearPast()
      return "ok"
    }

    function clearPending(): string {
      service.clearPending()
      return "ok"
    }

    function markAllSeen(): string {
      service.markAllSeen()
      return "ok"
    }

    function dismissAll(): string {
      service.clearPopups()
      service.clearPending()
      service.clearPast()
      return "ok"
    }

    function dismissOne(): string {
      if (popupModel.count > 0) {
        service.dismissPopup(0)
        return "ok"
      }
      if (pendingModel.count > 0) {
        service.dismissPending(0)
        return "ok"
      }
      if (pastModel.count > 0) {
        service.dismissPast(0)
        return "ok"
      }
      return "none"
    }

    function invokeLast(): string {
      if (popupModel.count === 0) return "none"
      service.invokePopupDefault(0)
      return "ok"
    }

    function dismiss(summary: string): string {
      var needle = String(summary || "")
      if (!needle) return "none"
      var hit = false
      function sweep(model, dismissFn) {
        for (var i = model.count - 1; i >= 0; i--) {
          var row = model.get(i)
          if (row && String(row.summary || "").indexOf(needle) !== -1) {
            dismissFn(i)
            hit = true
          }
        }
      }
      sweep(pendingModel, service.dismissPending)
      sweep(pastModel, service.dismissPast)
      sweep(popupModel, service.dismissPopup)
      return hit ? "ok" : "none"
    }

    function ping(): string { return "ok" }
  }

  NotificationServer {
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    persistenceSupported: true

    onNotification: function(notification) {
      service.handleNotification(notification)
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: popupModel.count > 0 && !(service.doNotDisturbFullscreen && service.screenIsFullscreen(modelData))

      WlrLayershell.namespace: "fuzi-notifications"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"

      readonly property var popupPlacement: NotificationLogic.popupPlacement(
        service.barPosition, service.barClearance, Style.gapsOut)

      anchors {
        top: popupPlacement.anchors.top
        bottom: popupPlacement.anchors.bottom
        left: popupPlacement.anchors.left
        right: popupPlacement.anchors.right
      }
      margins {
        top: popupPlacement.margins.top
        bottom: popupPlacement.margins.bottom
        left: popupPlacement.margins.left
        right: popupPlacement.margins.right
      }

      implicitWidth: Math.max(1, popupColumn.implicitWidth)
      implicitHeight: Math.max(1, popupColumn.implicitHeight)

      ColumnLayout {
        id: popupColumn
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: Style.space(8)

        Repeater {
          model: popupModel

          delegate: Item {
            id: cardSlot
            required property int index
            required property string app
            required property string appIcon
            required property string summary
            required property string body
            required property string image
            required property string glyph
            required property int urgency
            required property double expireTimeout
            required property double timestamp

            Layout.preferredWidth: card.implicitWidth
            Layout.alignment: Qt.AlignRight
            implicitHeight: card.implicitHeight

            readonly property real lifetime: service.durationFor(cardSlot.urgency, cardSlot.expireTimeout)
            property real remainingLifetime: 1.0
            readonly property bool ticking: cardSlot.lifetime > 0 && !card.hovered

            Timer {
              interval: 50
              repeat: true
              running: cardSlot.ticking
              onTriggered: {
                if (cardSlot.lifetime <= 0) return
                cardSlot.remainingLifetime -= 50.0 / cardSlot.lifetime
                if (cardSlot.remainingLifetime <= 0) {
                  cardSlot.remainingLifetime = 0
                  service.expirePopup(cardSlot.index)
                }
              }
            }

            NotificationCard {
              id: card
              anchors.right: parent.right
              app: cardSlot.app
              appIcon: cardSlot.appIcon
              summary: cardSlot.summary
              body: cardSlot.body
              image: cardSlot.image
              urgency: cardSlot.urgency
              timestamp: cardSlot.timestamp
              cornerRadius: service.cornerRadius
              fontFamily: service.shell && service.shell.bar ? service.shell.bar.fontFamily : ""
              glyph: cardSlot.glyph

              onCloseRequested: service.dismissPopup(cardSlot.index)
              onCardClicked: service.invokePopupDefault(cardSlot.index)
            }
          }
        }
      }
    }
  }
}
