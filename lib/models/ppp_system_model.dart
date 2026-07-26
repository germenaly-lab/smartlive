enum ConnectionStatus { connected, connecting, disconnected, error }
enum NetworkAccessMode { local, remote }

class PppSystemConfig {
  final String ipAddress;
  final int port;
  final String gatewayName;
  final String apiKey;
  final ConnectionStatus status;
  final NetworkAccessMode mode; // local (Home Wi-Fi) or remote (Traveling / 5G Cloud)
  final String cloudEndpoint; // Secure Remote Cloud Relay URL
  final bool isEncryptedTls;
  final int latencyMs;
  final double cpuUsage;
  final double memoryUsage;
  final int activeNodesCount;
  final String protocol; // REST / WebSocket / MQTT

  PppSystemConfig({
    required this.ipAddress,
    required this.port,
    required this.gatewayName,
    required this.apiKey,
    this.status = ConnectionStatus.connected,
    this.mode = NetworkAccessMode.local,
    this.cloudEndpoint = 'wss://remote.pppsystem.io/v3/gateway',
    this.isEncryptedTls = true,
    this.latencyMs = 14,
    this.cpuUsage = 19.2,
    this.memoryUsage = 41.5,
    this.activeNodesCount = 14,
    this.protocol = 'WebSocket / MQTT (TLS)',
  });

  PppSystemConfig copyWith({
    String? ipAddress,
    int? port,
    String? gatewayName,
    String? apiKey,
    ConnectionStatus? status,
    NetworkAccessMode? mode,
    String? cloudEndpoint,
    bool? isEncryptedTls,
    int? latencyMs,
    double? cpuUsage,
    double? memoryUsage,
    int? activeNodesCount,
    String? protocol,
  }) {
    return PppSystemConfig(
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      gatewayName: gatewayName ?? this.gatewayName,
      apiKey: apiKey ?? this.apiKey,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      cloudEndpoint: cloudEndpoint ?? this.cloudEndpoint,
      isEncryptedTls: isEncryptedTls ?? this.isEncryptedTls,
      latencyMs: latencyMs ?? this.latencyMs,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      activeNodesCount: activeNodesCount ?? this.activeNodesCount,
      protocol: protocol ?? this.protocol,
    );
  }
}
