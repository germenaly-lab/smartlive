import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/ppp_system_model.dart';
import 'lighting_view.dart';
import 'devices_view.dart';
import 'ppp_connection_dialog.dart';
import 'esp32_provisioning_dialog.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final SmartHomeController controller;

  const DashboardScreen({super.key, required this.controller});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeTab = 0; // 0 = Lighting, 1 = Appliances

  final List<String> _rooms = [
    'All Rooms',
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Office',
  ];

  @override
  Widget build(BuildContext context) {
    final tr = widget.controller.tr;
    final isAr = widget.controller.isArabic;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final user = widget.controller.currentUser;
        final ppp = widget.controller.pppConfig;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 74,
            title: Row(
              children: [
                // User Avatar
                GestureDetector(
                  onTap: () => _showUserAccountModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user.photoUrl),
                      child: user.photoUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${tr('hi_user')} ${user.name.split(" ").first}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.g_mobiledata, color: AppTheme.accentGreen, size: 16),
                          Expanded(
                            child: Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ESP32 Provisioning Button
                IconButton(
                  tooltip: isAr ? 'إضافة جهاز ESP32' : 'Provision ESP32 Node',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.memory_rounded, color: AppTheme.accentAmber, size: 18),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Esp32ProvisioningDialog(controller: widget.controller),
                    );
                  },
                ),

                // Language Selector Button
                IconButton(
                  tooltip: tr('lang_switch'),
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Text(
                      widget.controller.isArabic ? 'EN' : 'عربي',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGlow,
                      ),
                    ),
                  ),
                  onPressed: () => widget.controller.toggleLanguage(),
                ),

                // PPP Gateway Status Button
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => PppConnectionDialog(controller: widget.controller),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ppp.status == ConnectionStatus.connected
                            ? AppTheme.accentGreen.withValues(alpha: 0.4)
                            : Colors.redAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ppp.status == ConnectionStatus.connected
                                ? AppTheme.accentGreen
                                : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('ppp_gateway'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              ppp.status == ConnectionStatus.connected
                                  ? '${ppp.latencyMs}ms'
                                  : tr('offline'),
                              style: TextStyle(
                                fontSize: 10,
                                color: ppp.status == ConnectionStatus.connected
                                    ? AppTheme.accentGreen
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // System Telemetry Metrics
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile(
                        Icons.devices_rounded,
                        '${widget.controller.totalActiveDevices}/${widget.controller.devices.length}',
                        tr('active_devices'),
                        AppTheme.primary,
                      ),
                      Container(width: 1, height: 30, color: AppTheme.borderDark),
                      _buildMetricTile(
                        Icons.hub_rounded,
                        '${ppp.activeNodesCount}',
                        tr('ppp_nodes'),
                        AppTheme.accentGreen,
                      ),
                      Container(width: 1, height: 30, color: AppTheme.borderDark),
                      _buildMetricTile(
                        Icons.speed_rounded,
                        '${ppp.cpuUsage.toStringAsFixed(1)}%',
                        tr('cpu_load'),
                        AppTheme.accentAmber,
                      ),
                    ],
                  ),
                ),
              ),

              // Room Selector Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: _rooms.map((roomKey) {
                    final isSelected = widget.controller.selectedRoom == roomKey;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(widget.controller.getLocalizedRoom(roomKey)),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.borderDark,
                          ),
                        ),
                        onSelected: (_) => widget.controller.setSelectedRoom(roomKey),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Body Content (Lighting or Appliances)
              Expanded(
                child: IndexedStack(
                  index: _activeTab,
                  children: [
                    LightingView(controller: widget.controller),
                    DevicesView(controller: widget.controller),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: BottomNavigationBar(
              currentIndex: _activeTab,
              onTap: (index) => setState(() => _activeTab = index),
              backgroundColor: AppTheme.surfaceDark,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.lightbulb_rounded),
                  activeIcon: const Icon(Icons.lightbulb_rounded, color: AppTheme.primary),
                  label: tr('lighting_hub'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.tune_rounded),
                  activeIcon: const Icon(Icons.tune_rounded, color: AppTheme.primary),
                  label: tr('appliances_climate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(IconData icon, String value, String label, Color accent) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  void _showUserAccountModal(BuildContext context) {
    final user = widget.controller.currentUser;
    final tr = widget.controller.tr;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tr('google_authenticated'),
                  style: const TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await widget.controller.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(controller: widget.controller),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  label: Text(
                    tr('sign_out'),
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
