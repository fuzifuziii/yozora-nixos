import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Ui
import qs.Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "fuzi.network"
  ipcTarget: "fuzi.network"
  // manageIpc false so the panel owns the single IpcHandler
  manageIpc: false

  // central close so the passphrase prompt is dropped
  readonly property bool overlayVisible: qrVisible || speedTestModalOpen

  // shadow open() to dismiss an open card first
  function open() {
    if (overlayVisible) {
      hideWifiQr()
      hideSpeedTest()
      return
    }
    root.controller.show()
  }

  function close() {
    root.controller.hide()
    cancelPasswordPrompt()
    // close must not leave a centered card behind
    hideWifiQr()
    hideSpeedTest()
  }

  function cancelPasswordPrompt() {
    passwordSsid = ""
    passwordText = ""
    identityText = ""
  }

  // live connection details from `ip` / /sys / iw
  property var info: ({})  // iface, type, ip, gateway, speed, signal, pings

  // throughput as deltas between status samples
  property real prevRxBytes: 0
  property real prevTxBytes: 0
  property real prevSampleTime: 0
  property string prevIface: ""
  property real downloadRate: 0  // bytes/sec
  property real uploadRate: 0    // bytes/sec
  property string pingIface: ""
  property var routerPingSamples: []
  property var internetPingSamples: []
  property real routerPingLatency: -1
  property real internetPingLatency: -1
  property int internetPingPacketLoss: 0
  readonly property int pingHistoryWindow: 24
  readonly property int pingAverageWindow: 5
  readonly property bool hasInternetPing: internetPingSamples.length > 0
  // whether the stat numbers are real yet
  readonly property bool hasTransferStats: info.rx_bytes !== undefined
  property int connectionPhraseIndex: 0
  readonly property var connectionPhrases: [
    "Wiring bits",
    "Handling packets",
    "Sorting frames",
    "Hauling bytes",
    "Routing crumbs",
    "Counting collisions",
    "Bending light",
  ]
  readonly property string connectionPhrase: connectionPhrases[connectionPhraseIndex % connectionPhrases.length]
  readonly property bool networkManagerAvailable: Networking.backend === NetworkBackendType.NetworkManager
  readonly property var networkDevices: Networking.devices ? Networking.devices.values : []
  readonly property var wifiDevice: findDevice(DeviceType.Wifi)
  readonly property var wifiNetworkObjects: wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
  readonly property var connectedWifiNetwork: findConnectedWifiNetwork()
  property var wifiNetworks: []
  property bool scanning: false
  property bool wifiStationAvailable: false
  property string dnsProvider: ""
  property string pendingDnsProvider: ""
  // band from fuzi-network-band, current vs selected
  property string bandCurrent: ""
  property string bandSelected: "auto"
  property var bandAvailable: []
  property string pendingBand: ""
  property bool speedTestRunning: false
  property bool speedTestModalOpen: false
  property bool speedTestExpectedStop: false
  property bool pendingSpeedRun: false
  property string speedTestPhase: ""
  property string speedTestStderr: ""
  property string speedTestDownloadMbps: ""
  property string speedTestUploadMbps: ""
  property string speedTestError: ""

  // per-row in-flight state
  property string actionSsid: ""
  property string actionKind: ""  // "connect" | "disconnect" | "forget"
  property string failureSsid: ""
  property string failureReason: ""
  property string passwordSsid: ""
  property string passwordText: ""
  property string identityText: ""

  property var qrRows: []
  property int qrSize: 0
  property string qrError: ""
  property bool qrLoading: false
  property bool qrExpectedStop: false
  property bool pendingQrShow: false
  property bool pendingQrDetect: false
  property string qrPassword: ""
  property bool qrPasswordVisible: false
  property string qrPasswordError: ""
  readonly property bool qrVisible: qrLoading || qrSize > 0 || qrError !== ""

  // true while any wifi action runs
  readonly property bool busy: actionKind !== ""

  // keyboard index into wifiNetworks, -1 is none
  property int selectedIndex: -1
  property bool wifiActionFocused: false
  property bool cursorActive: false

  // keyboard focus zone, j/k crosses rows, h/l moves within
  property string focusSection: "dns"  // "header" | "band" | "dns" | "wifi"
  property int headerIndex: 0
  readonly property bool canDisconnect: !!connectedWifiNetwork
  readonly property bool canShareWifi: info.type === "wifi" && canShareNetwork(connectedWifiNetwork)
  // hero switch exists only with a Wi-Fi radio
  readonly property bool canToggleWifi: networkManagerAvailable && wifiStationAvailable
  readonly property int qrHeaderIndex: canShareWifi ? 0 : -1
  readonly property int speedHeaderIndex: canRunSpeedTest ? (canShareWifi ? 1 : 0) : -1
  readonly property int toggleHeaderIndex: canToggleWifi ? (canShareWifi ? 1 : 0) + (canRunSpeedTest ? 1 : 0) : -1
  readonly property int headerActionCount: (canShareWifi ? 1 : 0) + (canRunSpeedTest ? 1 : 0) + (canToggleWifi ? 1 : 0)
  readonly property bool qrHeaderHasCursor: cursorActive && focusSection === "header" && headerIndex === qrHeaderIndex
  readonly property bool speedHeaderHasCursor: cursorActive && focusSection === "header" && headerIndex === speedHeaderIndex
  readonly property bool toggleHeaderHasCursor: cursorActive && focusSection === "header" && headerIndex === toggleHeaderIndex
  readonly property string toggleHint: Networking.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
  readonly property var dnsProviders: ["DHCP", "Cloudflare", "Google", "Custom"]
  property int dnsIndex: 0
  // bands to choose from, Wi-Fi only
  readonly property bool canSelectBand: (kind === "wifi" || bandBusy)
    && (bandAvailable.length > 1 || bandPinned)
  // show the requested state while a change is in flight
  readonly property string bandEffective: pendingBand !== "" ? pendingBand : bandSelected
  readonly property bool bandPinned: bandEffective !== "auto"
  // pills collapse under Automatic, header shows the band
  readonly property bool bandPillsVisible: canSelectBand && bandPinned
  readonly property string bandSectionTitle: Model.bandSectionTitle(bandEffective, bandCurrent)
  readonly property bool bandBusy: pendingBand !== ""
  // speed test needs an interface
  readonly property bool canRunSpeedTest: !!info.iface
  property int bandIndex: 0
  // band section cursor rows, same shape as wifiActionFocused
  property bool bandAutoFocused: true

  onHeaderActionCountChanged: clampHeaderIndex()

  // clamp the index and leave the section if it vanishes
  onBandAvailableChanged: {
    if (bandIndex > bandAvailable.length - 1) bandIndex = Math.max(0, bandAvailable.length - 1)
  }

  onCanSelectBandChanged: {
    if (!canSelectBand && focusSection === "band") {
      focusSection = "dns"
      bandAutoFocused = true
    }
  }

  // move the cursor up when the pills collapse
  onBandPillsVisibleChanged: {
    if (!bandPillsVisible) bandAutoFocused = true
  }

  function clampHeaderIndex() {
    var max = Math.max(0, headerActionCount - 1)
    if (headerIndex > max) headerIndex = max
    if (headerIndex < 0) headerIndex = 0
  }

  function selectHeaderByDelta(delta) {
    headerIndex = Math.max(0, Math.min(headerActionCount - 1, headerIndex + delta))
  }

  function toggleNetwork() {
    if (!networkManagerAvailable) return
    Networking.wifiEnabled = !Networking.wifiEnabled
    Qt.callLater(function() { root.refresh(true) })
  }

  IpcHandler {
    target: "fuzi.network"

    function open() { root.open() }
    function close() { root.close() }
    function show() { root.open() }
    function hide() { root.close() }
    function toggle() { root.toggle() }
    function toggleNetwork() { root.toggleNetwork() }
    // menu routes summon the centered cards directly
    function showQr() {
      root.refresh()
      root.showWifiQr(true)
    }
    function speedTest() {
      root.refresh()
      root.showSpeedTest()
    }
  }

  function activateHeader() {
    if (headerIndex === qrHeaderIndex) showWifiQr()
    else if (headerIndex === speedHeaderIndex) showSpeedTest()
    else if (headerIndex === toggleHeaderIndex) toggleNetwork()
  }

  function setHeaderCursor(index) {
    cursorActive = true
    focusSection = "header"
    headerIndex = index
  }

  function selectDnsByDelta(delta) {
    dnsIndex = Math.max(0, Math.min(dnsProviders.length - 1, dnsIndex + delta))
  }

  function activateDns() {
    if (dnsIndex < 0 || dnsIndex >= dnsProviders.length) return
    setDns(dnsProviders[dnsIndex])
  }

  function selectBandByDelta(delta) {
    bandIndex = Math.max(0, Math.min(bandAvailable.length - 1, bandIndex + delta))
  }

  function activateBand() {
    if (bandAutoFocused) {
      toggleBandAuto()
      return
    }
    if (bandIndex < 0 || bandIndex >= bandAvailable.length) return
    setBand(bandAvailable[bandIndex])
  }

  // pin the current band when Automatic goes off
  function toggleBandAuto() {
    if (bandSelected !== "auto") {
      setBand("auto")
      return
    }
    if (bandCurrent === "") return
    setBand(bandCurrent)
  }

  // park the cursor on the pinned band
  function syncBandIndex() {
    var idx = bandAvailable.indexOf(bandSelected)
    bandIndex = idx >= 0 ? idx : 0
    bandAutoFocused = !bandPillsVisible
  }

  function bandLabel(band) {
    return Model.bandLabel(band)
  }

  function bandTooltip(band) {
    return Model.bandTooltip(band)
  }

  // single cursor model for the whole panel
  readonly property color hoverFill: bar ? Style.hoverFillFor(bar.foreground, Color.accent) : "transparent"
  readonly property color selectedFill: bar ? Style.selectedFillFor(bar.foreground, Color.accent) : "transparent"

  // KeyboardPanel primes focus on open
  onOpenedChanged: {
    if (opened) {
      refresh(true)
      selectedIndex = wifiNetworks.length > 0 ? 0 : -1
      wifiActionFocused = false
      focusSection = wifiNetworks.length > 0 ? "wifi" : "dns"
      var idx = dnsProviders.indexOf(dnsProvider)
      dnsIndex = idx >= 0 ? idx : 0
      syncBandIndex()
      cursorActive = false
    } else {
      // reset throughput tracking to avoid a fake rate
      prevSampleTime = 0
      downloadRate = 0
      uploadRate = 0
      pingIface = ""
      routerPingSamples = []
      internetPingSamples = []
      routerPingLatency = -1
      internetPingLatency = -1
      internetPingPacketLoss = 0
      if (wifiDevice) wifiDevice.scannerEnabled = false
    }
  }

  // restore focus to keyCatcher when the passphrase prompt closes
  onPasswordSsidChanged: {
    if (passwordSsid === "" && opened) {
      passwordText = ""
      Qt.callLater(function() { if (keyCatcher) keyCatcher.forceActiveFocus() })
    }
  }

  // keep selectedIndex valid, bounce to the DNS row if empty
  onWifiNetworksChanged: {
    if (wifiNetworks.length === 0) {
      selectedIndex = -1
      wifiActionFocused = false
      if (focusSection === "wifi") focusSection = "dns"
    } else if (passwordSsid !== "") {
      var passwordIndex = wifiIndexForSsid(passwordSsid)
      if (passwordIndex >= 0) {
        selectedIndex = passwordIndex
        focusSection = "wifi"
      }
    } else if (selectedIndex >= wifiNetworks.length) {
      selectedIndex = wifiNetworks.length - 1
    } else if (selectedIndex < 0 && opened) {
      selectedIndex = 0
    }

    if (selectedIndex < 0 || selectedIndex >= wifiNetworks.length || !canForgetNetwork(wifiNetworks[selectedIndex])) {
      wifiActionFocused = false
    }
  }

  onWifiDeviceChanged: {
    if (wifiDevice) wifiDevice.scannerEnabled = opened
    syncWifiNetworks()
  }

  onWifiNetworkObjectsChanged: syncWifiNetworks()

  function selectByDelta(delta) {
    if (wifiNetworks.length === 0) { selectedIndex = -1; return }
    if (selectedIndex < 0) selectedIndex = delta > 0 ? 0 : wifiNetworks.length - 1
    else selectedIndex = Math.max(0, Math.min(wifiNetworks.length - 1, selectedIndex + delta))
    wifiActionFocused = false
  }

  function canForgetNetwork(net) {
    return !!(net && net.known && isProtected(net.security) && !net.connected)
  }

  function canShareNetwork(net) {
    if (!net || !net.connected) return false
    return net.security !== WifiSecurityType.Wpa2Eap && net.security !== WifiSecurityType.WpaEap
  }

  function selectWifiActionByDelta(delta) {
    if (selectedIndex < 0 || selectedIndex >= wifiNetworks.length) return
    if (!canForgetNetwork(wifiNetworks[selectedIndex])) {
      wifiActionFocused = false
      return
    }
    if (delta > 0) wifiActionFocused = true
    else if (delta < 0) wifiActionFocused = false
  }

  // Enter/Space acts like a row click
  function activateSelected() {
    if (busy || selectedIndex < 0 || selectedIndex >= wifiNetworks.length) return
    var net = wifiNetworks[selectedIndex]
    if (!net) return
    if (wifiActionFocused && canForgetNetwork(net)) { forget(net); return }
    if (net.connected) { disconnect(net.network); return }
    if (isProtected(net.security) && !net.known) { openPasswordPrompt(net.ssid); return }
    connectKnown(net.ssid)
  }

  // bar pill state from NetworkManager, wired preferred
  readonly property var wiredDevice: findDevice(DeviceType.Wired)
  readonly property string kind: {
    if (wiredDevice && wiredDevice.connected) return "ethernet"
    if (connectedWifiNetwork) return "wifi"
    return "disconnected"
  }
  readonly property int signalStrength: connectedWifiNetwork
    ? Math.round((connectedWifiNetwork.signalStrength || 0) * 100)
    : -1

  function copyToClipboard(value) {
    if (!value || !root.bar) return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(value) + " | wl-copy"])
  }

  readonly property string icon: Model.connectionIcon(kind, signalStrength)

  function showWifiQr(forceDetect) {
    if (qrProc.running) {
      // queue the reopen for onExited, SIGTERM is in flight
      if (qrExpectedStop) {
        pendingQrShow = true
        pendingQrDetect = !!forceDetect
      }
      return
    }
    qrSize = 0
    qrRows = []
    qrError = ""
    qrLoading = true
    qrExpectedStop = false
    // IPC route forces self-detection, cached interface can be stale
    qrProc.command = !forceDetect && info.type === "wifi" && info.iface
      ? ["fuzi-network-qr", info.iface]
      : ["fuzi-network-qr"]
    qrProc.running = true

    // leave the compact panel while the share card is open
    controller.hide()
    cancelPasswordPrompt()
  }

  function hideWifiQr() {
    pendingQrShow = false
    if (qrProc.running) {
      qrExpectedStop = true
      qrProc.running = false
    }
    if (pwProc.running) pwProc.running = false
    qrSize = 0
    qrRows = []
    qrError = ""
    qrLoading = false
    qrPassword = ""
    qrPasswordVisible = false
    qrPasswordError = ""
  }

  function updateQr(raw) {
    var matrix = Model.parseQrMatrix(raw)
    qrRows = matrix.rows
    qrSize = matrix.size
  }

  function toggleQrPassword() {
    if (qrPasswordVisible) { qrPasswordVisible = false; return }
    if (qrPassword !== "") { qrPasswordVisible = true; return }
    if (pwProc.running || !info.iface) return
    qrPasswordError = ""
    pwProc.command = ["fuzi-network-password", info.iface]
    pwProc.running = true
  }

  function refresh(scanWifi) {
    if (scanWifi === undefined) scanWifi = false
    if (!detailsProc.running) detailsProc.running = true
    if (!dnsProc.running) {
      dnsProc.command = ["bash", "-c", root.dnsCommand("")]
      dnsProc.running = true
    }
    if (!bandProc.running) {
      bandProc.command = ["fuzi-network-band"]
      bandProc.running = true
    }
    if (wifiDevice) {
      if (scanWifi) {
        scanning = true
        wifiDevice.scannerEnabled = false
        scanRestart.start()
      } else {
        wifiDevice.scannerEnabled = true
      }
    }
    syncWifiNetworks()
  }

  function formatHeaderSpeed(mbps) {
    return Model.formatHeaderSpeed(mbps)
  }

  function formatHeaderFreq(mhz) {
    return Model.formatHeaderFreq(mhz)
  }

  function headerDetail() {
    return Model.headerDetail(info)
  }

  function updateDetails(raw) {
    var next = Model.parseKeyValue(raw)

    // keep the last good sample during a band change
    if (bandBusy && !next.iface) return

    info = next
    updateThroughput(next)
    updatePingLatency(next)
  }

  function updateThroughput(next) {
    var state = Model.throughputState({
      prevIface: prevIface,
      prevRxBytes: prevRxBytes,
      prevTxBytes: prevTxBytes,
      prevSampleTime: prevSampleTime,
      downloadRate: downloadRate,
      uploadRate: uploadRate
    }, next, Date.now() / 1000)

    prevIface = state.prevIface
    prevRxBytes = state.prevRxBytes
    prevTxBytes = state.prevTxBytes
    prevSampleTime = state.prevSampleTime
    downloadRate = state.downloadRate
    uploadRate = state.uploadRate
  }

  function updatePingLatency(next) {
    var state = Model.pingLatencyState({
      pingIface: pingIface,
      routerPingSamples: routerPingSamples,
      internetPingSamples: internetPingSamples
    }, next, pingHistoryWindow, pingAverageWindow)

    pingIface = state.pingIface
    routerPingSamples = state.routerPingSamples
    internetPingSamples = state.internetPingSamples
    routerPingLatency = state.routerPingLatency
    internetPingLatency = state.internetPingLatency
    internetPingPacketLoss = state.internetPingPacketLoss
  }

  function formatBytes(bytes) {
    return Model.formatBytes(bytes)
  }

  function formatRate(bytesPerSec) {
    return Model.formatRate(bytesPerSec)
  }

  function formatPingLatency(ms) {
    return Model.formatPingLatency(ms, hasInternetPing)
  }

  function formatPacketLoss(percent) {
    return Model.formatPacketLoss(percent, hasInternetPing)
  }

  // prefer a connected device among same-type NICs
  function findDevice(type) {
    var devices = networkDevices || []
    var fallback = null
    for (var i = 0; i < devices.length; i++) {
      var device = devices[i]
      if (!device || device.type !== type) continue
      if (device.connected) return device
      if (!fallback) fallback = device
    }
    return fallback
  }

  function findConnectedWifiNetwork() {
    var networks = wifiNetworkObjects || []
    for (var i = 0; i < networks.length; i++) {
      if (networks[i] && networks[i].connected) return networks[i]
    }
    return null
  }

  function syncWifiNetworks() {
    var nets = []
    var networks = wifiNetworkObjects || []

    for (var i = 0; i < networks.length; i++) {
      var network = networks[i]
      if (!network) continue
      checkActionCompletion(network)
      var row = Model.wifiRow(network)
      if (row) nets.push(row)
    }
    wifiNetworks = Model.sortWifiRows(nets)
    wifiStationAvailable = !!wifiDevice
    scanning = false
  }

  function wifiSectionTitle(index) {
    return Model.wifiSectionTitle(wifiNetworks, index)
  }

  function wifiIconFor(strength) {
    return Model.wifiIconFor(strength)
  }

  function updateDns(raw) {
    var value = String(raw || "").trim()
    dnsProvider = value || "DHCP"
  }

  function updateBand(raw) {
    var status = Model.parseBandStatus(raw)

    // keep the option list while reconnecting
    if (bandBusy && status.available.length === 0) return

    bandCurrent = status.band
    bandSelected = status.selected
    bandAvailable = status.available
  }

  // panel stays open while a band pin reconnects
  function setBand(band) {
    if (!band || actionProc.running) return

    root.pendingBand = band
    actionProc.command = ["fuzi-network-band", band]
    actionProc.running = true
  }

  function updateSpeedTestLine(line) {
    var value = parseFloat(line)
    if (!isFinite(value) || value < 0) return

    if (speedTestPhase === "down") speedTestDownloadMbps = String(value)
    else if (speedTestPhase === "up") speedTestUploadMbps = String(value)
    speedTestError = ""
  }

  // speed test modal, dismissing stops the traffic
  function showSpeedTest() {
    if (!speedTestModalOpen) {
      speedTestModalOpen = true
      controller.hide()
      cancelPasswordPrompt()
    }
    runSpeedTest()
  }

  function hideSpeedTest() {
    speedTestModalOpen = false
    pendingSpeedRun = false
    speedTestPhaseTimer.stop()
    // clear the phase before killing, onExited advances it
    speedTestPhase = ""
    speedTestRunning = false
    if (speedTestProc.running) {
      speedTestExpectedStop = true
      speedTestProc.running = false
    }
  }

  function runSpeedTest() {
    if (speedTestProc.running) {
      // queue the fresh run for onExited, SIGTERM is in flight
      if (speedTestExpectedStop) pendingSpeedRun = true
      return
    }
    speedTestError = ""
    speedTestDownloadMbps = ""
    speedTestUploadMbps = ""
    speedTestRunning = true
    startSpeedTestPhase("down")
  }

  function startSpeedTestPhase(phase) {
    speedTestExpectedStop = false
    speedTestPhase = phase
    speedTestStderr = ""
    speedTestProc.command = ["fuzi-network-speedtest", phase]
    speedTestProc.running = true
    speedTestPhaseTimer.restart()
  }

  function stopSpeedTestPhase() {
    speedTestPhaseTimer.stop()
    if (speedTestProc.running) {
      speedTestExpectedStop = true
      speedTestProc.running = false
      return
    }
    finishSpeedTestPhase()
  }

  function finishSpeedTestPhase() {
    if (speedTestPhase === "down") {
      startSpeedTestPhase("up")
      return
    }

    speedTestPhase = ""
    speedTestRunning = false
    speedTestExpectedStop = false
  }

  function dnsCommand(provider) {
    var command = "fuzi-dns"
    if (provider) command += " " + Util.shellQuote(provider)
    return command
  }

  function setDns(provider) {
    if (!root.bar || !provider || actionProc.running) return

    if (provider === "Custom") {
      var launcher = "fuzi-launch-floating-terminal-with-presentation"
      root.bar.run(launcher + " " + Util.shellQuote(root.dnsCommand(provider)))
      root.close()
      return
    }

    root.pendingDnsProvider = provider
    actionProc.command = ["bash", "-c", root.dnsCommand(provider)]
    actionProc.running = true
    root.close()
  }

  function isProtected(security) {
    return Model.isProtected(security, WifiSecurityType.Open)
  }

  function openPasswordPrompt(ssid) {
    if (passwordSsid !== ssid) {
      passwordText = ""
      identityText = ""
    }
    passwordSsid = ssid
  }

  function networkForSsid(ssid) {
    var networks = wifiNetworkObjects || []
    for (var i = 0; i < networks.length; i++) {
      if (networks[i] && networks[i].name === ssid) return networks[i]
    }
    return null
  }

  function wifiIndexForSsid(ssid) {
    for (var i = 0; i < wifiNetworks.length; i++) {
      if (wifiNetworks[i] && wifiNetworks[i].ssid === ssid) return i
    }
    return -1
  }

  function runNetworkAction(kind, network, callback) {
    if (actionKind !== "" || !network) return
    var ssid = network.name || ""
    actionSsid = ssid
    actionKind = kind
    failureSsid = ""
    failureReason = ""
    callback(network)
    // safety net to clear a stuck busy state
    actionTimeout.restart()
  }

  function clearNetworkAction() {
    actionTimeout.stop()
    if (actionKind === "connect") passwordSsid = ""
    failureSsid = ""
    failureReason = ""
    actionSsid = ""
    actionKind = ""
    refresh()
  }

  function failNetworkAction(network, reason) {
    if (!network || actionKind === "" || actionSsid !== (network.name || "")) return
    actionTimeout.stop()
    failureSsid = actionSsid
    failureReason = networkFailureReason(reason)
    actionSsid = ""
    actionKind = ""
    refresh()
  }

  function networkFailureReason(reason) {
    return Model.networkFailureReason(reason, {
      NoSecrets: ConnectionFailReason.NoSecrets,
      WifiAuthTimeout: ConnectionFailReason.WifiAuthTimeout,
      WifiNetworkLost: ConnectionFailReason.WifiNetworkLost,
      WifiClientDisconnected: ConnectionFailReason.WifiClientDisconnected,
      WifiClientFailed: ConnectionFailReason.WifiClientFailed
    })
  }

  function checkActionCompletion(network) {
    if (!network || actionKind === "" || actionSsid !== (network.name || "")) return
    if (actionKind === "connect" && network.connected) clearNetworkAction()
    else if (actionKind === "disconnect" && !network.connected && !network.stateChanging) clearNetworkAction()
    else if (actionKind === "forget" && !network.known && !network.stateChanging) clearNetworkAction()
  }

  function connectKnown(ssid) {
    runNetworkAction("connect", networkForSsid(ssid), function(network) { network.connect() })
  }

  function connectWithPassphrase(ssid, passphrase) {
    runNetworkAction("connect", networkForSsid(ssid), function(network) { network.connectWithPsk(passphrase) })
  }

  function connectEnterprise(ssid, identity, passphrase) {
    runNetworkAction("connect", networkForSsid(ssid), function(network) {
      enterpriseConnect.secret = passphrase
      enterpriseConnect.command = ["bash", "-c", Model.enterpriseConnectScript, "nmcli-eap", ssid, identity]
      enterpriseConnect.running = true
    })
  }

  // create and activate the 802.1X profile, password via stdin
  Process {
    id: enterpriseConnect
    property string secret: ""
    stdinEnabled: true
    onStarted: {
      write(secret + "\n")
      secret = ""
    }
  }

  function disconnect(network) {
    runNetworkAction("disconnect", network || connectedWifiNetwork, function(net) { net.disconnect() })
  }

  function forget(net) {
    runNetworkAction("forget", net ? net.network : null, function(network) { network.forget() })
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: refresh()

  // fetch interface details of the active route in one shot
  Process {
    id: detailsProc
    command: ["fuzi-network-status", "--verbose"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateDetails(text)
    }
  }

  Timer {
    id: scanRestart
    interval: 100
    repeat: false
    onTriggered: {
      if (root.wifiDevice) root.wifiDevice.scannerEnabled = true
      scanDone.start()
    }
  }

  Timer {
    id: scanDone
    interval: 1500
    repeat: false
    onTriggered: root.syncWifiNetworks()
  }

  Process {
    id: qrProc
    // ignore output after a dismissal via qrExpectedStop
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (!root.qrExpectedStop) root.updateQr(text)
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (!root.qrExpectedStop) root.qrError = String(text || "").trim()
    }
    onExited: function(exitCode) {
      root.qrLoading = false
      if (root.pendingQrShow) {
        root.pendingQrShow = false
        root.qrExpectedStop = false
        Qt.callLater(function() { root.showWifiQr(root.pendingQrDetect) })
        return
      }
      if (root.qrExpectedStop) return
      if (exitCode !== 0 || root.qrSize === 0) {
        root.qrSize = 0
        root.qrRows = []
        if (root.qrError === "") root.qrError = "Could not generate the Wi-Fi QR code"
      }
    }
  }

  // Wi-Fi password lives in memory only while revealed
  Process {
    id: pwProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (root.qrVisible) root.qrPassword = String(text || "").trim()
    }
    onExited: function(exitCode) {
      if (!root.qrVisible) return
      if (exitCode === 0 && root.qrPassword !== "") root.qrPasswordVisible = true
      else root.qrPasswordError = "Could not read the Wi-Fi password"
    }
  }

  Process {
    id: dnsProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateDns(text)
    }
  }

  Process {
    id: bandProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateBand(text)
    }
  }

  // slower than detailsPoll, nmcli runs several times
  Timer {
    interval: 4000
    repeat: true
    running: root.opened
    onTriggered: {
      if (bandProc.running) return
      bandProc.command = ["fuzi-network-band"]
      bandProc.running = true
    }
  }

  Process {
    id: speedTestProc
    stdout: SplitParser { onRead: function(line) { root.updateSpeedTestLine(line) } }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.speedTestStderr = String(text || "").trim()
    }
    onExited: function(exitCode) {
      speedTestPhaseTimer.stop()

      if (root.pendingSpeedRun) {
        root.pendingSpeedRun = false
        root.speedTestExpectedStop = false
        if (root.speedTestModalOpen) Qt.callLater(root.runSpeedTest)
        return
      }

      if (!root.speedTestExpectedStop && exitCode !== 0) {
        root.speedTestError = root.speedTestStderr || "Speed test failed"
        root.speedTestPhase = ""
        root.speedTestRunning = false
        return
      }

      root.speedTestExpectedStop = false
      root.finishSpeedTestPhase()
    }
  }

  Timer {
    id: speedTestPhaseTimer
    interval: 11000
    repeat: false
    onTriggered: root.stopSpeedTestPhase()
  }

  // action runner for DNS changes
  Process {
    id: actionProc
    stdout: StdioCollector { id: actionStdout; waitForEnd: true }
    stderr: StdioCollector { id: actionStderr; waitForEnd: true }
    onExited: function(exitCode) {
      if (root.pendingDnsProvider !== "") {
        if (exitCode === 0) root.dnsProvider = root.pendingDnsProvider
        root.pendingDnsProvider = ""
      }
      if (root.pendingBand !== "") {
        // keep bandSelected on a refused pin
        if (exitCode === 0) root.bandSelected = root.pendingBand
        root.pendingBand = ""
        // refresh state now instead of waiting for the next poll
        root.refresh()
      }
    }
  }

  // poll details while the panel is open
  Timer {
    interval: 1500
    repeat: true
    running: root.opened
    onTriggered: if (!detailsProc.running) detailsProc.running = true
  }

  Timer {
    interval: 2800
    running: root.opened && (root.info.type === "ethernet" || (root.info.type === "wifi" && root.canDisconnect))
    repeat: true
    onTriggered: connectionPhraseSwap.restart()
  }

  SequentialAnimation {
    id: connectionPhraseSwap
    PropertyAnimation {
      target: heroMeta; property: "opacity"
      to: 0.0; duration: 180; easing.type: Easing.OutQuad
    }
    ScriptAction {
      script: root.connectionPhraseIndex = (root.connectionPhraseIndex + 1) % root.connectionPhrases.length
    }
    PropertyAnimation {
      target: heroMeta; property: "opacity"
      to: 1.0; duration: 260; easing.type: Easing.InQuad
    }
  }

  Connections {
    target: root
    function onInfoChanged() {
      if (!(root.info.type === "ethernet" || (root.info.type === "wifi" && root.canDisconnect))) {
        connectionPhraseSwap.stop()
        heroMeta.opacity = 1.0
      }
    }
  }

  Timer {
    id: actionTimeout
    interval: 15000
    repeat: false
    onTriggered: {
      if (!root.actionKind) return
      var reason
      if (root.actionKind === "connect") reason = "Timed out connecting"
      else if (root.actionKind === "disconnect") reason = "Timed out disconnecting"
      else reason = "Timed out forgetting"
      root.failureSsid = root.actionSsid
      root.failureReason = reason
      root.actionSsid = ""
      root.actionKind = ""
      root.refresh()
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon

    onPressed: function(b) {
      if (root.opened) root.close()
      else { root.open(); root.refresh() }
    }
  }

  // keyboard-driven popup anchored to the bar icon
  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    // catch unhandled keys, AfterItem lets the passphrase field go first
    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      // freeze the cursor while the password prompt is open
      blocked: root.passwordSsid !== ""

      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) {
          root.cursorActive = true
          if (dy >= 0) return
        }
        if (dy !== 0) {
          // vertical order header, band, DNS, wifi
          if (root.focusSection === "header") {
            if (dy > 0) {
              if (root.canSelectBand) {
                root.focusSection = "band"
                root.bandAutoFocused = true
              } else {
                root.focusSection = "dns"
              }
            }
          } else if (root.focusSection === "band") {
            // Automatic on the header line, then the pills
            if (dy < 0) {
              if (!root.bandAutoFocused) {
                root.bandAutoFocused = true
              } else if (root.headerActionCount > 0) {
                root.focusSection = "header"
                root.headerIndex = 0
              }
            } else if (root.bandAutoFocused && root.bandPillsVisible) {
              root.bandAutoFocused = false
            } else {
              root.focusSection = "dns"
            }
          } else if (root.focusSection === "dns") {
            // k from DNS goes up to band or disconnect, j drops into wifi
            if (dy < 0) {
              if (root.canSelectBand) {
                root.focusSection = "band"
                root.bandAutoFocused = !root.bandPillsVisible
              } else if (root.headerActionCount > 0) {
                root.focusSection = "header"
                root.headerIndex = 0
              }
            } else if (root.wifiNetworks.length > 0) {
              root.focusSection = "wifi"
              if (root.selectedIndex < 0) root.selectedIndex = 0
            }
          } else {  // wifi
            // k from the top row goes back up to DNS
            if (dy < 0 && root.selectedIndex <= 0) {
              root.focusSection = "dns"
              root.wifiActionFocused = false
            }
            else root.selectByDelta(dy)
          }
        }
        if (dx !== 0) {
          if (root.focusSection === "header") root.selectHeaderByDelta(dx)
          else if (root.focusSection === "band") { if (!root.bandAutoFocused) root.selectBandByDelta(dx) }
          else if (root.focusSection === "dns") root.selectDnsByDelta(dx)
          else if (root.focusSection === "wifi") root.selectWifiActionByDelta(dx)
        }
      }
      onActivateRequested: {
        if (root.cursorActive) {
          if (root.focusSection === "header") root.activateHeader()
          else if (root.focusSection === "band") root.activateBand()
          else if (root.focusSection === "dns") root.activateDns()
          else root.activateSelected()
        }
      }
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refresh()
        else if (t === "w" || t === "W") root.toggleNetwork()
      }

    Column {
      id: column
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      spacing: Style.space(12)

      // ---------- Hero: network icon · SSID + state · actions ----------
      Item {
        width: parent.width
        implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, heroActions.implicitHeight)

        // status only, the switch owns toggling
        Text {
          id: heroIcon
          text: root.icon
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.display
          opacity: root.networkManagerAvailable ? 1.0 : 0.5
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
        }

        // sharing belongs to the connected-network hero
        RowLayout {
          id: heroActions
          spacing: Style.space(8)
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter

          Button {
            visible: root.canShareWifi
            iconText: "󰐲"
            tooltipText: "Show QR code"
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
            iconSize: Style.font.subtitle * 1.5
            horizontalPadding: Style.space(5)
            verticalPadding: Style.space(2)
            hasCursor: root.qrHeaderHasCursor
            Layout.alignment: Qt.AlignVCenter
            onHovered: function(on) { if (on) root.setHeaderCursor(root.qrHeaderIndex) }
            onClicked: root.showWifiQr()
          }

          Button {
            visible: root.canRunSpeedTest
            iconText: "󰓅"
            tooltipText: "Run a speed test"
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
            iconSize: Style.font.subtitle * 1.5
            horizontalPadding: Style.space(5)
            verticalPadding: Style.space(2)
            hasCursor: root.speedHeaderHasCursor
            Layout.alignment: Qt.AlignVCenter
            onHovered: function(on) { if (on) root.setHeaderCursor(root.speedHeaderIndex) }
            onClicked: root.showSpeedTest()
          }

          ToggleSwitch {
            id: powerSwitch
            visible: root.canToggleWifi
            checked: Networking.wifiEnabled
            hasCursor: root.toggleHeaderHasCursor
            foreground: root.bar.foreground
            Layout.alignment: Qt.AlignVCenter
            onHovered: function(on) { if (on) root.setHeaderCursor(root.toggleHeaderIndex) }
            onToggled: root.toggleNetwork()

            PanelToolTip {
              visible: powerSwitch.containsMouse
              text: root.toggleHint
              fontFamily: root.bar.fontFamily
            }
          }
        }

        Column {
          id: heroLabels
          anchors.left: heroIcon.right
          anchors.leftMargin: Style.space(14)
          anchors.right: parent.right
          anchors.rightMargin: heroActions.width > 0 ? heroActions.width + Style.space(12) : 0
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(2)

          // link detail inline after the name
          Text {
            id: heroSsid
            width: parent.width

            readonly property string title: {
              if (root.info.type === "wifi") return root.info.ssid || "Wi-Fi"
              if (root.info.type === "ethernet") return "Ethernet"
              return root.info.iface || (root.kind === "disconnected" ? "Disconnected" : "No connection")
            }
            readonly property string detail: root.headerDetail()

            text: heroSsid.detail !== "" ? heroSsid.title + " (" + heroSsid.detail + ")" : heroSsid.title
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            id: heroMeta
            width: parent.width
            text: {
              if (root.info.type === "wifi") {
                if (root.canDisconnect) return root.connectionPhrase.toUpperCase()
                if (root.kind === "disconnected") return "NOT CONNECTED"
                return ""
              }
              if (root.info.type === "ethernet") return root.connectionPhrase.toUpperCase()
              if (root.kind === "disconnected") return "NOT CONNECTED"
              return ""
            }
            visible: text !== ""
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
            elide: Text.ElideRight
          }
        }

      }

      // connection details, transfer metrics first
      Column {
        visible: !!root.info.iface
        width: parent.width
        spacing: Style.spacing.labelGap

        GridLayout {
          width: parent.width
          columns: 4
          columnSpacing: Style.space(20)
          rowSpacing: Style.spacing.labelGap

          // always mounted, read "--" until a sample arrives
          InfoLabel { text: "Ping" }
          DetailValue {
            text: root.formatPingLatency(root.internetPingLatency)
            color: root.internetPingPacketLoss > 0 ? root.bar.urgent : root.bar.foreground
          }
          InfoLabel { text: "Packet Loss" }
          DetailValue {
            text: root.formatPacketLoss(root.internetPingPacketLoss)
            color: root.internetPingPacketLoss > 0 ? root.bar.urgent : root.bar.foreground
          }

          InfoLabel { text: "Receiving" }
          DetailValue { text: root.hasTransferStats ? root.formatRate(root.downloadRate) : "--" }
          InfoLabel { text: "Sending" }
          DetailValue { text: root.hasTransferStats ? root.formatRate(root.uploadRate) : "--" }

          InfoLabel { text: "Downloaded" }
          DetailValue { text: root.hasTransferStats ? root.formatBytes(parseFloat(root.info.rx_bytes || "0")) : "--" }
          InfoLabel { text: "Uploaded" }
          DetailValue { text: root.hasTransferStats ? root.formatBytes(parseFloat(root.info.tx_bytes || "0")) : "--" }

          InfoLabel { text: "IP Address" }
          DetailValue {
            text: root.info.ip || "--"
            copyable: !!root.info.ip
            tooltipText: "Copy IP"
          }
          InfoLabel { text: "Gateway" }
          DetailValue {
            text: root.info.gateway || "--"
            copyable: !!root.info.gateway
            tooltipText: "Copy gateway"
          }
        }
      }

      // Wi-Fi band selection, only with more than one band
      PanelSeparator {
        visible: root.canSelectBand
        foreground: root.bar.foreground
      }

      Column {
        visible: root.canSelectBand
        width: parent.width
        spacing: Style.space(10)

        // Automatic rides on the header line
        Item {
          width: parent.width
          implicitHeight: Math.max(bandHeader.implicitHeight, bandAutoRow.implicitHeight)

          PanelSectionHeader {
            id: bandHeader
            text: root.bandSectionTitle
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Row {
            id: bandAutoRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(6)

            PanelSectionHeader {
              id: bandAutoLabel
              text: "AUTOMATIC"
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              anchors.verticalCenter: parent.verticalCenter
            }

            // size off the label and center on its glyphs
            ToggleSwitch {
              id: bandAutoSwitch
              trackHeight: Math.round(bandAutoLabel.font.pixelSize * 1.2)
              cursorPad: Style.space(3)
              anchors.verticalCenter: bandAutoLabel.verticalCenter
              anchors.verticalCenterOffset: Math.round(bandAutoLabel.topPadding / 2)
              checked: !root.bandPinned
              busy: root.bandBusy
              hasCursor: root.cursorActive && root.focusSection === "band" && root.bandAutoFocused
              foreground: root.bar.foreground
              onToggled: root.toggleBandAuto()

              onHovered: function(isHovered) {
                if (!isHovered) return
                root.cursorActive = true
                root.focusSection = "band"
                root.bandAutoFocused = true
              }

              PanelToolTip {
                visible: bandAutoSwitch.containsMouse
                text: root.bandPinned
                  ? "Let Wi-Fi pick the band"
                  : "Stay on " + root.bandLabel(root.bandCurrent)
                fontFamily: root.bar.fontFamily
              }
            }
          }
        }

        // collapsing container, pills animate their height
        Item {
          width: parent.width
          clip: true
          visible: height > 0
          height: root.bandPillsVisible ? bandRow.implicitHeight : 0
          opacity: root.bandPillsVisible ? 1 : 0

          Behavior on height {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
          }
          Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
          }

          Row {
            id: bandRow
            width: parent.width
            spacing: Style.space(6)

            readonly property int count: Math.max(1, root.bandAvailable.length)
            readonly property real cellWidth: (width - spacing * (count - 1)) / count

            // wrapper passes modelData and index down explicitly
            Repeater {
              model: root.bandAvailable

              delegate: Item {
                required property var modelData
                required property int index
                width: bandRow.cellWidth
                height: bandPill.implicitHeight

                BandPill {
                  id: bandPill
                  band: modelData
                  slot: index
                  width: parent.width
                }
              }
            }
          }
        }

      }

      // DNS provider selection
      PanelSeparator {
        foreground: root.bar.foreground
      }

      Column {
        width: parent.width
        spacing: Style.space(10)

        PanelSectionHeader {
          text: "DNS PROVIDER"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        Row {
          id: dnsRow
          width: parent.width
          spacing: Style.space(6)

          readonly property int count: 4
          readonly property real cellWidth: (width - spacing * (count - 1)) / count

          DnsProviderPill {
            provider: "DHCP"
            index: 0
            tooltipText: "Use DNS from DHCP"
            width: dnsRow.cellWidth
            onClicked: root.setDns(provider)
          }

          DnsProviderPill {
            provider: "Cloudflare"
            index: 1
            tooltipText: "Set DNS to Cloudflare"
            width: dnsRow.cellWidth
            onClicked: root.setDns(provider)
          }

          DnsProviderPill {
            provider: "Google"
            index: 2
            tooltipText: "Set DNS to Google"
            width: dnsRow.cellWidth
            onClicked: root.setDns(provider)
          }

          DnsProviderPill {
            provider: "Custom"
            index: 3
            tooltipText: "Set custom DNS servers"
            width: dnsRow.cellWidth
            onClicked: root.setDns(provider)
          }
        }
      }


      // Wi-Fi networks (only if a Wi-Fi station is available)
      PanelSeparator {
        visible: root.wifiStationAvailable
        foreground: root.bar.foreground
      }

      PanelSectionHeader {
        visible: root.wifiStationAvailable && root.scanning
        text: "SCANNING WI-FI…"
        foreground: root.bar.foreground
        fontFamily: root.bar.fontFamily
      }

      // network list capped in height, ListView for positionViewAtIndex
      ListView {
        visible: root.wifiStationAvailable
        width: parent.width
        height: Math.min(contentHeight, Style.space(240))
        spacing: Style.space(4)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        model: root.wifiStationAvailable ? root.wifiNetworks : []
        currentIndex: root.selectedIndex
        onCurrentIndexChanged: if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)

        // wrapper passes delegate props down explicitly
        delegate: Item {
          required property var modelData
          required property int index
          readonly property string sectionTitle: root.wifiSectionTitle(index)
          width: ListView.view.width
          height: delegateColumn.implicitHeight

          Column {
            id: delegateColumn
            width: parent.width
            spacing: Style.space(4)

            PanelSectionHeader {
              visible: sectionTitle !== ""
              text: sectionTitle
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              height: visible ? implicitHeight : 0
            }

            NetworkRow {
              id: row
              width: parent.width
              net: modelData
              index: parent.parent.index
            }
          }
        }
      }
    }
    }
  }

  WifiQrPanel {
    anchorItem: button
    bar: root.bar
    qrRows: root.qrRows
    qrSize: root.qrSize
    loading: root.qrLoading
    error: root.qrError
    ssid: root.info.ssid || ""
    secured: root.connectedWifiNetwork ? root.isProtected(root.connectedWifiNetwork.security) : false
    password: root.qrPassword
    passwordVisible: root.qrPasswordVisible
    passwordError: root.qrPasswordError
    open: root.qrVisible
    onCloseRequested: root.hideWifiQr()
    onPasswordToggleRequested: root.toggleQrPassword()
  }

  SpeedTestPanel {
    anchorItem: button
    bar: root.bar
    running: root.speedTestRunning
    phase: root.speedTestPhase
    downloadMbps: root.speedTestDownloadMbps
    uploadMbps: root.speedTestUploadMbps
    error: root.speedTestError
    connectionName: {
      if (root.info.type === "wifi") return root.info.ssid || "Wi-Fi"
      if (root.info.type === "ethernet") return "Ethernet"
      return ""
    }
    open: root.speedTestModalOpen
    onCloseRequested: root.hideSpeedTest()
    onRunAgainRequested: root.runSpeedTest()
  }

  // one Wi-Fi band pill
  component BandPill: Button {
    id: pill
    required property string band
    required property int slot

    text: root.bandLabel(band)
    tooltipText: root.bandTooltip(band)
    fontSize: Style.font.bodySmall
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.controlPaddingX
    verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
    bordered: true

    active: root.bandCurrent === band
    selected: root.bandEffective === band
    hasCursor: root.cursorActive && root.focusSection === "band"
      && !root.bandAutoFocused && root.bandIndex === slot

    onClicked: root.setBand(band)

    onHovered: function(isHovered) {
      if (!isHovered) return
      root.cursorActive = true
      root.focusSection = "band"
      root.bandIndex = pill.slot
    }
  }

  // one DNS provider pill
  component DnsProviderPill: Button {
    id: pill
    required property string provider
    required property int index

    text: provider
    fontSize: Style.font.bodySmall
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.controlPaddingX
    verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
    bordered: true

    // map DNS state onto Button's props
    active: root.dnsProvider === provider
    hasCursor: root.cursorActive && root.focusSection === "dns" && root.dnsIndex === index

    onHovered: function(isHovered) {
      if (!isHovered) return
      root.cursorActive = true
      root.focusSection = "dns"
      root.dnsIndex = pill.index
    }
  }

  // single Wi-Fi network entry, expands to a passphrase prompt
  component NetworkRow: CursorSurface {
    id: row
    required property var net
    required property int index

    readonly property bool isConnected: net && net.connected
    readonly property bool isKnown: !!(net && net.known)
    readonly property bool isProtected: net ? root.isProtected(net.security) : false
    readonly property bool isEnterprise: net
      ? (net.security === WifiSecurityType.Wpa2Eap || net.security === WifiSecurityType.WpaEap)
      : false
    readonly property bool canForgetFromLock: isKnown && isProtected && !isConnected
    readonly property bool isSelected: root.focusSection === "wifi" && root.selectedIndex === index
    readonly property bool forgetFocused: isSelected && root.wifiActionFocused && canForgetFromLock
    readonly property bool forgetVisible: canForgetFromLock && (forgetFocused || rightMouse.containsMouse)

    hasCursor: root.cursorActive && isSelected && !root.wifiActionFocused
    current: isConnected
    foreground: root.bar.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill
    // gate on non-empty kind so hidden-SSID rows do not match
    readonly property bool isBusy: root.actionKind !== "" && root.actionSsid === (net ? net.ssid : "")
    readonly property bool isFailed: root.failureReason !== "" && root.failureSsid === (net ? net.ssid : "")
    readonly property bool isPasswordOpen: root.passwordSsid !== "" && root.passwordSsid === (net ? net.ssid : "")

    function submitCredentials() {
      if (!net || root.busy || root.passwordText.length === 0) return
      if (!isEnterprise) return root.connectWithPassphrase(net.ssid, root.passwordText)
      if (root.identityText.length > 0) root.connectEnterprise(net.ssid, root.identityText, root.passwordText)
    }

    Connections {
      target: row.net ? row.net.network : null
      function onConnectionFailed(reason) {
        root.failNetworkAction(row.net.network, reason)
        if (reason === ConnectionFailReason.NoSecrets) root.openPasswordPrompt(row.net.ssid)
      }
      function onConnectedChanged() {
        if (row.net) root.checkActionCompletion(row.net.network)
      }
      function onKnownChanged() {
        if (row.net) root.checkActionCompletion(row.net.network)
      }
      function onStateChangingChanged() {
        if (row.net) root.checkActionCompletion(row.net.network)
      }
    }

    readonly property string statusText: {
      if (!net) return ""
      if (isPasswordOpen) return ""
      if (isBusy && root.actionKind === "connect") return "Connecting…"
      if (isBusy && root.actionKind === "disconnect") return "Disconnecting…"
      if (isBusy && root.actionKind === "forget") return "Forgetting…"
      if (isFailed) return root.failureReason || "Failed"
      if (isConnected) return "Connected"
      return ""
    }

    readonly property color statusColor: {
      if (isFailed) return root.bar.urgent
      if (isBusy) return root.bar.foreground
      if (isConnected) return root.bar.foreground
      return Qt.darker(root.bar.foreground, 1.5)
    }

    implicitHeight: rowBody.implicitHeight + (isPasswordOpen ? passwordPanel.implicitHeight + Style.spacing.md : 0)

    MouseArea {
      id: rowMouse
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: rowBody.implicitHeight
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      enabled: !root.busy

      // move the cursor here on mouse enter
      onContainsMouseChanged: if (containsMouse) { root.cursorActive = true; root.focusSection = "wifi"; root.selectedIndex = row.index; root.wifiActionFocused = false }

      onClicked: {
        if (!row.net) return
        // resync the cursor after keyboard nav moved it away
        root.cursorActive = true
        root.focusSection = "wifi"
        root.selectedIndex = row.index
        root.wifiActionFocused = false
        if (row.isConnected) {
          root.disconnect(row.net.network)
          return
        }
        if (row.isProtected && !row.isKnown) {
          root.openPasswordPrompt(row.net.ssid)
          return
        }
        root.connectKnown(row.net.ssid)
      }
    }

    Item {
      id: rowBody
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      implicitHeight: Math.max(networkIcon.implicitHeight, networkInfo.implicitHeight, rightAction.implicitHeight) + Style.spacing.rowPaddingX

      Text {
        id: networkIcon
        text: row.net ? root.wifiIconFor(row.net.signal) : ""
        color: row.statusColor
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.title
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      // lock glyph for protected networks, forget on hover
      Item {
        id: rightAction
        visible: row.isProtected
        width: Style.space(22)
        implicitHeight: lockIndicator.implicitHeight
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Text {
          id: lockIndicator
          width: parent.width
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignHCenter
          text: row.forgetVisible ? "󰅙" : "󰌾"
          color: row.forgetVisible ? root.bar.urgent : Qt.darker(root.bar.foreground, 1.4)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.subtitle
        }

        BorderSurface {
          anchors.fill: parent
          visible: row.forgetFocused
          color: Style.hoverFillFor(root.bar.urgent, root.bar.urgent)
          borderSpec: Border.controlSpec("hover-cursor", root.bar.urgent, root.bar.urgent)
          radius: Style.cornerRadius
          z: -1
        }

        MouseArea {
          id: rightMouse
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton
          enabled: row.canForgetFromLock && !root.busy
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          onContainsMouseChanged: if (containsMouse) { root.cursorActive = true; root.focusSection = "wifi"; root.selectedIndex = row.index; root.wifiActionFocused = true }
          onClicked: if (row.net) root.forget(row.net)
        }

        PanelToolTip {
          visible: rightMouse.containsMouse || row.forgetFocused
          text: "Forget network"
          fontFamily: root.bar.fontFamily
        }
      }

      Column {
        id: networkInfo
        spacing: Style.space(1)
        anchors.left: networkIcon.right
        anchors.leftMargin: Style.space(10)
        anchors.right: rightAction.visible ? rightAction.left : parent.right
        anchors.rightMargin: rightAction.visible ? Style.space(8) : 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
          text: row.net ? (row.net.ssid || "Hidden") : ""
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
          width: parent.width
        }
        Text {
          // second line carries action status only
          text: row.statusText
          visible: row.statusText !== ""
          height: visible ? implicitHeight : 0
          color: row.statusColor
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
          width: parent.width
        }
      }
    }

    Timer {
      interval: 2000
      running: row.isFailed && row.isPasswordOpen
      onTriggered: {
        root.failureSsid = ""
        root.failureReason = ""
        pwField.forceActiveFocus()
      }
    }

    // inline passphrase prompt for protected networks
    Item {
      id: passwordPanel
      visible: row.isPasswordOpen
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: rowMouse.bottom
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      anchors.topMargin: Style.space(4)
      implicitHeight: (idField.visible ? idField.implicitHeight + Style.space(4) : 0) + pwField.implicitHeight + Style.spacing.rowGap
      height: implicitHeight

      TextField {
        id: idField
        visible: row.isEnterprise && !row.isBusy && !row.isFailed
        anchors.left: parent.left
        anchors.right: connectPwBtn.left
        anchors.top: parent.top
        anchors.rightMargin: Style.space(6)
        placeholderText: "Identity (user@domain)"
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        foreground: root.bar.foreground
        horizontalPadding: Style.spacing.controlGap
        verticalPadding: Style.spacing.controlPaddingY
        enabled: !row.isBusy
        text: row.isPasswordOpen ? root.identityText : ""

        onAccepted: pwField.forceActiveFocus()
        onTextChanged: if (row.isPasswordOpen && text !== root.identityText) root.identityText = text
        Keys.onEscapePressed: root.cancelPasswordPrompt()

        onVisibleChanged: if (visible) Qt.callLater(forceActiveFocus)
        Component.onCompleted: if (visible) Qt.callLater(forceActiveFocus)
      }

      TextField {
        id: pwField
        visible: !row.isBusy && !row.isFailed
        anchors.left: parent.left
        anchors.right: connectPwBtn.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.spacing.rowGap / 2
        anchors.rightMargin: Style.space(6)
        password: true
        placeholderText: "Passphrase"
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        foreground: root.bar.foreground
        horizontalPadding: Style.spacing.controlGap
        verticalPadding: Style.spacing.controlPaddingY
        enabled: !row.isBusy
        text: row.isPasswordOpen ? root.passwordText : ""

        onAccepted: row.submitCredentials()
        onTextChanged: if (row.isPasswordOpen && text !== root.passwordText) root.passwordText = text
        Keys.onEscapePressed: root.cancelPasswordPrompt()

        onVisibleChanged: if (visible && !row.isEnterprise) Qt.callLater(forceActiveFocus)
        Component.onCompleted: if (visible && !row.isEnterprise) Qt.callLater(forceActiveFocus)
      }

      BorderSurface {
        visible: row.isBusy || row.isFailed
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: Style.spacing.controlHeight
        color: Style.normalFillFor(root.bar.foreground)
        borderSpec: Border.controlSpec("normal", root.bar.foreground, Color.accent)
        radius: Style.cornerRadius

        Text {
          anchors.fill: parent
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: row.isFailed ? "Wrong password" : "Connecting..."
          color: row.isFailed ? root.bar.urgent : root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
        }
      }

      // 22x22 right-anchored to line up with lockIndicator
      PanelActionButton {
        id: connectPwBtn
        visible: !row.isBusy && !row.isFailed
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        enabled: row.net && pwField.text.length > 0 && (!row.isEnterprise || idField.text.length > 0)
        iconText: "󰄬"
        tooltipText: "Connect"
        foreground: root.bar.foreground
        fontFamily: root.bar.fontFamily
        onClicked: row.submitCredentials()
      }
    }
  }


  component DetailValue: InfoValue {
    property bool copyable: false
    property string tooltipText: "Copy to clipboard"

    Layout.fillWidth: true
    horizontalAlignment: Text.AlignRight

    MouseArea {
      id: valueMouse
      anchors.fill: parent
      enabled: copyable && parent.text !== ""
      hoverEnabled: enabled
      cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: root.copyToClipboard(parent.text)
    }

    PanelToolTip {
      visible: valueMouse.enabled && valueMouse.containsMouse
      text: tooltipText
      fontFamily: root.bar.fontFamily
    }
  }

  component InfoLabel: Text {
    color: root.bar.foreground
    opacity: 0.6
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  component InfoValue: Text {
    color: root.bar.foreground
    font.family: root.bar.fontFamily
    font.pixelSize: Style.font.bodySmall
  }
}
