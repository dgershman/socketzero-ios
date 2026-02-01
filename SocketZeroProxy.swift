import Foundation
import Network

class SocketZeroProxy: ObservableObject {
    @Published var status: ProxyStatus = .stopped
    @Published var isRunning = false
    @Published var logs: [String] = []
    
    let port: UInt16 = 8080
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private var webSocket: URLSessionWebSocketTask?
    
    // For demo, we'll just log. In production, connect to receiver
    private let receiverURL = "ws://localhost:9997/ws" // Change to your receiver
    
    func start() {
        log("🚀 Starting proxy on localhost:\(port)")
        status = .starting
        
        do {
            let params = NWParameters.tcp
            listener = try NWListener(using: params, on: NWEndpoint.Port(integerLiteral: port))
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            listener?.stateUpdateHandler = { [weak self] state in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        self.status = .running
                        self.isRunning = true
                        self.log("✅ Proxy listening on localhost:\(self.port)")
                        
                    case .failed(let error):
                        self.status = .error
                        self.isRunning = false
                        self.log("❌ Failed: \(error.localizedDescription)")
                        
                    case .cancelled:
                        self.status = .stopped
                        self.isRunning = false
                        self.log("⏹️ Proxy stopped")
                        
                    default:
                        break
                    }
                }
            }
            
            listener?.start(queue: .main)
            
        } catch {
            log("❌ Failed to create listener: \(error.localizedDescription)")
            status = .error
        }
    }
    
    func stop() {
        log("⏹️ Stopping proxy...")
        listener?.cancel()
        connections.forEach { $0.cancel() }
        connections.removeAll()
        webSocket?.cancel(with: .normalClosure, reason: nil)
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        connections.append(connection)
        connection.start(queue: .main)
        
        log("📥 New connection from client")
        
        // Read the initial request
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self, let data = data else {
                if let error = error {
                    self?.log("❌ Read error: \(error.localizedDescription)")
                }
                return
            }
            
            if let request = String(data: data, encoding: .utf8) {
                self.handleRequest(request, on: connection)
            }
        }
    }
    
    private func handleRequest(_ request: String, on connection: NWConnection) {
        let lines = request.split(separator: "\r\n")
        guard let requestLine = lines.first else { return }
        
        log("📨 \(requestLine)")
        
        if requestLine.hasPrefix("CONNECT ") {
            // HTTPS tunnel
            handleCONNECT(request: request, on: connection)
        } else {
            // Plain HTTP
            handleHTTP(request: request, on: connection)
        }
    }
    
    private func handleCONNECT(request: String, on connection: NWConnection) {
        // Parse "CONNECT example.com:443 HTTP/1.1"
        let components = request.split(separator: " ")
        guard components.count >= 2 else {
            sendError(on: connection)
            return
        }
        
        let target = String(components[1]) // "example.com:443"
        log("🔒 HTTPS tunnel to \(target)")
        
        // For demo: respond OK, but we won't actually forward (no receiver yet)
        let response = "HTTP/1.1 200 Connection Established\r\n\r\n"
        
        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.log("❌ Send error: \(error.localizedDescription)")
            } else {
                self?.log("✅ CONNECT tunnel established to \(target)")
                // In production, now pipe bytes to/from receiver
                // For demo, just close after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.log("⚠️ Demo: closing tunnel (no receiver connected)")
                    connection.cancel()
                }
            }
        })
    }
    
    private func handleHTTP(request: String, on connection: NWConnection) {
        // Parse HTTP request
        let lines = request.split(separator: "\r\n")
        guard let requestLine = lines.first else {
            sendError(on: connection)
            return
        }
        
        log("🌐 HTTP: \(requestLine)")
        
        // For demo: send simple response
        let html = """
        <!DOCTYPE html>
        <html>
        <head><title>SocketZero Proxy Demo</title></head>
        <body>
            <h1>🦝 SocketZero Proxy Works!</h1>
            <p>This response came from your iPhone proxy.</p>
            <p>Request: <code>\(requestLine)</code></p>
            <hr>
            <p><em>In production, this would forward to SocketZero receiver.</em></p>
        </body>
        </html>
        """
        
        let response = """
        HTTP/1.1 200 OK\r
        Content-Type: text/html\r
        Content-Length: \(html.utf8.count)\r
        Connection: close\r
        \r
        \(html)
        """
        
        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.log("❌ Send error: \(error.localizedDescription)")
            }
            connection.cancel()
        })
    }
    
    private func sendError(on connection: NWConnection) {
        let response = "HTTP/1.1 400 Bad Request\r\n\r\n"
        connection.send(content: response.data(using: .utf8), completion: .idempotent)
        connection.cancel()
    }
    
    private func log(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            self.logs.append("[\(timestamp)] \(message)")
            
            // Keep last 50 logs
            if self.logs.count > 50 {
                self.logs.removeFirst()
            }
        }
    }
}
