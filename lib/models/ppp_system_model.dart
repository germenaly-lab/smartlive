enum ConnectionStatus { connected, connecting, disconnected, error }

class PppSystemConfig {
  final String ipAddress;
  final int port;
  final String gatewayName;
  final String apiKey;
  final ConnectionStatus status;
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
    this.latencyMs = 14,
    this.cpuUsage = 18.5,
    this.memoryUsage = 42.0,
    this.activeNodesCount = 12,
    this.protocol = 'WebSocket / MQTT',
  });

  PppSystemConfig copyWith({
    String? ipAddress,
    int? port,
    String? gatewayName,
    String? apiKey,
    ConnectionStatus? status,
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
      latencyMs: latencyMs ?? this.latencyMs,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      activeNodesCount: activeNodesCount ?? this.activeNodesCount,
      protocol: protocol ?? this.protocol,
    );
  }
}
