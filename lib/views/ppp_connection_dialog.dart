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
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final config = widget.controller.pppConfig;
    _ipController = TextEditingController(text: config.ipAddress);
    _portController = TextEditingController(text: config.port.toString());
    _gatewayController = TextEditingController(text: config.gatewayName);
    _keyController = TextEditingController(text: config.apiKey);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _gatewayController.dispose();
    _keyController.dispose();
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
                    child: const Icon(Icons.router_rounded, color: AppTheme.primary, size: 28),
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
                          tr('ppp_protocol_desc'),
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
              const SizedBox(height: 20),

              // Status Summary
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
                        color: config.status == ConnectionStatus.connected
                            ? AppTheme.accentGreen
                            : Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: (config.status == ConnectionStatus.connected
                                    ? AppTheme.accentGreen
                                    : Colors.redAccent)
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
                        backgroundColor: AppTheme.primary,
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
