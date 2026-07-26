import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/ppp_system_model.dart';

class PppConnectionDialog extends StatefulWidget {
  final SmartHomeController controller;

  const PppConnectionDialog({super.key, required this.controller});

  @override
  State<PppConnectionDialog> createState() => _PppConnectionDialogState();
}

class _PppConnectionDialogState extends State<PppConnectionDialog> {
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _gatewayController;
  late TextEditingController _keyController;
  late TextEditingController _cloudController;
  late NetworkAccessMode _selectedMode;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final config = widget.controller.pppConfig;
    _ipController = TextEditingController(text: config.ipAddress);
    _portController = TextEditingController(text: config.port.toString());
    _gatewayController = TextEditingController(text: config.gatewayName);
    _keyController = TextEditingController(text: config.apiKey);
    _cloudController = TextEditingController(text: config.cloudEndpoint);
    _selectedMode = config.mode;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _gatewayController.dispose();
    _keyController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.controller.pppConfig;
    final tr = widget.controller.tr;

    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _selectedMode == NetworkAccessMode.remote ? Icons.public_rounded : Icons.router_rounded,
                      color: _selectedMode == NetworkAccessMode.remote ? AppTheme.accentPurple : AppTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('ppp_gateway_system'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _selectedMode == NetworkAccessMode.remote
                              ? tr('mode_remote')
                              : tr('mode_local'),
                          style: TextStyle(
                            fontSize: 13,
                            color: _selectedMode == NetworkAccessMode.remote ? AppTheme.accentPurple : AppTheme.primaryGlow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Network Access Mode Selector (Local vs Traveling Mode)
              Text(
                tr('connection_mode'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMode = NetworkAccessMode.local),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedMode == NetworkAccessMode.local ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.home_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                tr('mode_local'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMode = NetworkAccessMode.remote),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedMode == NetworkAccessMode.remote ? AppTheme.accentPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flight_takeoff_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                tr('mode_remote'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Traveling Mode Banner / Info
              if (_selectedMode == NetworkAccessMode.remote)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: AppTheme.accentPurple, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr('traveling_mode_desc'),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Status Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: config.status == ConnectionStatus.connected ? AppTheme.accentGreen : Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (config.status == ConnectionStatus.connected ? AppTheme.accentGreen : Colors.redAccent)
                                .withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      config.status == ConnectionStatus.connected
                          ? '${tr('connected')} (${config.latencyMs} ms)'
                          : tr('disconnected'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${tr('ppp_nodes')}: ${config.activeNodesCount}',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (_selectedMode == NetworkAccessMode.remote) ...[
                _buildTextField(tr('cloud_endpoint'), _cloudController, Icons.cloud_done_rounded),
                const SizedBox(height: 14),
              ],
              _buildTextField(tr('gateway_name'), _gatewayController, Icons.hub_rounded),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(tr('ip_address'), _ipController, Icons.dns_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(tr('port'), _portController, Icons.numbers_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(tr('api_key'), _keyController, Icons.key_rounded, isPassword: true),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.borderDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        widget.controller.togglePppConnection();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        config.status == ConnectionStatus.connected ? Icons.link_off : Icons.link,
                        size: 18,
                        color: config.status == ConnectionStatus.connected ? Colors.redAccent : AppTheme.accentGreen,
                      ),
                      label: Text(
                        config.status == ConnectionStatus.connected ? tr('disconnected') : tr('connected'),
                        style: TextStyle(
                          color: config.status == ConnectionStatus.connected ? Colors.redAccent : AppTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _selectedMode == NetworkAccessMode.remote ? AppTheme.accentPurple : AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isTesting
                          ? null
                          : () async {
                              setState(() => _isTesting = true);
                              final success = await widget.controller.updatePppConfig(
                                ip: _ipController.text,
                                port: int.tryParse(_portController.text) ?? 8080,
                                gateway: _gatewayController.text,
                                apiKey: _keyController.text,
                                cloudEndpoint: _cloudController.text,
                                mode: _selectedMode,
                              );
                              setState(() => _isTesting = false);
                              if (context.mounted && success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(tr('connect_success')),
                                    backgroundColor: AppTheme.accentGreen,
                                  ),
                                );
                              }
                            },
                      icon: _isTesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                      label: Text(
                        _isTesting ? tr('testing') : tr('save_connect'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            filled: true,
            fillColor: AppTheme.cardDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
