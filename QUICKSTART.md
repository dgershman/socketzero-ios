# Quick Start

## Open in Xcode (2 options)

### Option 1: Create New Project (Manual)

1. Open Xcode
2. File → New → Project
3. iOS → App
4. Product Name: **SocketZeroProxy**
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Delete the generated Swift files
8. Add these files to your project:
   - `SocketZeroProxyApp.swift`
   - `ContentView.swift`
   - `SocketZeroProxy.swift`

### Option 2: Command Line (Quick)

```bash
cd ~/Projects/socketzero-ios-demo

# Create Xcode project
mkdir -p SocketZeroProxy/SocketZeroProxy

# Move files
cp *.swift SocketZeroProxy/SocketZeroProxy/

# Open in Xcode
open -a Xcode SocketZeroProxy
```

## Build & Run

1. Select iPhone simulator or device
2. Press **Cmd+R** (or click ▶️ Play button)
3. Wait for app to launch

## Test It

1. **In the app:** Tap "Start Proxy"
2. **On iPhone:** Settings → Wi-Fi → (i) → Configure Proxy
   - Manual
   - Server: `127.0.0.1`
   - Port: `8080`
3. **Open Safari:** Go to `http://example.com`
4. **Back to app:** See logs showing the request!

## What You'll See

```
📥 New connection from client
📨 GET / HTTP/1.1
🌐 HTTP: GET / HTTP/1.1
✅ Response sent
```

Safari will show a custom HTML page proving the proxy intercepted the request.

For HTTPS (`https://google.com`):
```
📥 New connection from client
📨 CONNECT google.com:443 HTTP/1.1
🔒 HTTPS tunnel to google.com:443
✅ CONNECT tunnel established
```

---

**That's it!** You now have a working HTTP proxy on iOS. 🦝

Next: Connect it to SocketZero receiver (see README.md for details).
