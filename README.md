# SocketZero iOS Proxy Demo

A minimal iOS app demonstrating a local HTTP/HTTPS proxy for SocketZero.

## What It Does

- Runs a local HTTP proxy on `localhost:8080`
- Handles `CONNECT` tunneling for HTTPS (no MITM, just byte forwarding)
- Shows connection logs in real-time
- Demonstrates the core concept for SocketZero mobile

## How to Test

### 1. Build & Run in Xcode

1. Create a new Xcode project:
   - File → New → Project
   - iOS → App
   - Product Name: `SocketZeroProxy`
   - Interface: SwiftUI
   - Language: Swift

2. Replace the generated files with these:
   - `SocketZeroProxyApp.swift`
   - `ContentView.swift`
   - `SocketZeroProxy.swift`

3. Run on iPhone or Simulator (Cmd+R)

### 2. Configure iOS Proxy

On your iPhone:

1. Go to **Settings**
2. Tap **Wi-Fi**
3. Tap **(i)** next to your connected network
4. Scroll down to **Configure Proxy**
5. Select **Manual**
6. Enter:
   - **Server:** `127.0.0.1`
   - **Port:** `8080`
7. Tap **Save**

### 3. Test It

**Plain HTTP:**
- Open Safari
- Go to `http://example.com`
- You'll see the demo response from the proxy

**HTTPS:**
- Go to `https://example.com`
- The proxy will log the CONNECT request
- (In this demo, it returns 200 OK but doesn't forward - see notes below)

**Check Logs:**
- Return to the SocketZero Proxy app
- See real-time connection logs at the bottom

## What's Missing (For Production)

This is a **proof of concept**. To make it production-ready for SocketZero:

### 1. WebSocket to Receiver

Add WebSocket connection to your SocketZero receiver:

```swift
private func connectToReceiver() {
    var request = URLRequest(url: URL(string: receiverURL)!)
    request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    
    let session = URLSession(configuration: .default)
    webSocket = session.webSocketTask(with: request)
    webSocket?.resume()
    
    receiveMessages()
}
```

### 2. Forward Requests

In `handleCONNECT` and `handleHTTP`, instead of sending demo responses:

```swift
// Send request to receiver
let message = [
    "type": "tunnel_request",
    "target": target,
    "data": data.base64EncodedString()
]
sendWebSocketMessage(message)
```

### 3. Pipe Bytes for CONNECT

After `200 Connection Established`, pipe encrypted bytes:

```swift
connection.receive(...) { data, _, _, _ in
    // Send bytes to receiver via WebSocket
    self.forwardToReceiver(data)
}

// When bytes come back from receiver:
connection.send(content: receiverData, ...)
```

### 4. Background Persistence

For production, you'd need:
- **Network Extension** (VPN capability) for background operation
- Or accept foreground-only operation

### 5. OAuth Flow

Add authentication via Universal Links:

```swift
// Handle deep link callback
func handleAuthCallback(url: URL) {
    // Extract token from socketzero://auth/callback?token=...
    let token = extractToken(from: url)
    saveToKeychain(token)
    connectToReceiver()
}
```

## Architecture

```
iOS Safari
    ↓ (HTTP/CONNECT requests)
Local Proxy (localhost:8080)
    ↓ (WebSocket - TODO)
SocketZero Receiver
    ↓
Target Services
```

## Limitations

- **Foreground only** - proxy stops when app backgrounds
- **Manual proxy config** - user must configure in Settings
- **No receiver integration** - demo responses only
- **HTTPS works but doesn't forward** - needs WebSocket implementation

## Next Steps

1. **Add WebSocket to receiver** (reuse Go protocol)
2. **Implement byte forwarding** for CONNECT tunnels
3. **Add OAuth flow** via Universal Links
4. **Test with real SocketZero receiver**
5. **Consider Network Extension** for background operation

## Files

- `SocketZeroProxyApp.swift` - App entry point
- `ContentView.swift` - SwiftUI interface
- `SocketZeroProxy.swift` - Proxy server implementation

## License

Same as SocketZero parent project.

---

Built by Rocky 🦝 for Danny @ Radius Method
