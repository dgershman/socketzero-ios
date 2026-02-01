import SwiftUI

struct ContentView: View {
    @StateObject private var proxy = SocketZeroProxy()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "network")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("SocketZero Proxy")
                .font(.title)
                .bold()
            
            Text("localhost:\(proxy.port)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            StatusView(status: proxy.status)
            
            if proxy.isRunning {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Configure iOS Proxy:")
                        .font(.headline)
                    
                    Text("Settings → Wi-Fi → (i) → Configure Proxy")
                        .font(.caption)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Server:")
                            Text("Port:")
                        }
                        .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading) {
                            Text("127.0.0.1")
                            Text("\(proxy.port)")
                        }
                        .bold()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                
                Button(action: { proxy.stop() }) {
                    Text("Stop Proxy")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            } else {
                Button(action: { proxy.start() }) {
                    Text("Start Proxy")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Connection log
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(proxy.logs, id: \.self) { log in
                        Text(log)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .frame(height: 150)
            .background(Color.black.opacity(0.05))
        }
        .padding()
    }
}

struct StatusView: View {
    let status: ProxyStatus
    
    var body: some View {
        HStack {
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)
            
            Text(status.rawValue)
                .font(.subheadline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(status.color.opacity(0.1))
        .cornerRadius(20)
    }
}

enum ProxyStatus: String {
    case stopped = "Stopped"
    case starting = "Starting..."
    case running = "Running"
    case error = "Error"
    
    var color: Color {
        switch self {
        case .stopped: return .gray
        case .starting: return .orange
        case .running: return .green
        case .error: return .red
        }
    }
}

#Preview {
    ContentView()
}
