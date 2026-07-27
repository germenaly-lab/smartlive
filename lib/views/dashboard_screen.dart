import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/ppp_system_model.dart';
import 'lighting_view.dart';
import 'devices_view.dart';
import 'automations_view.dart';
import 'three_d_interactive_view.dart';
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
  int _activeTab = 0; // 0 = Lighting, 1 = Appliances, 2 = Automations, 3 = 3D Studio

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
        final isRemote = widget.controller.isRemoteMode;

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
                      border: Border.all(
                        color: isRemote ? AppTheme.accentPurple : AppTheme.primary,
                        width: 2,
                      ),
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
                          Icon(
                            isRemote ? Icons.flight_takeoff_rounded : Icons.g_mobiledata,
                            color: isRemote ? AppTheme.accentPurple : AppTheme.accentGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isRemote ? tr('mode_remote') : user.email,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isRemote ? FontWeight.bold : FontWeight.normal,
                                color: isRemote ? AppTheme.accentPurple : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3D Interactive Mode Toggle Button
                IconButton(
                  tooltip: isAr ? 'تحكم 3D التفاعلي' : '3D Object Studio',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _activeTab == 3
                          ? AppTheme.primaryGlow
                          : AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                    ),
                    child: Icon(
                      Icons.view_in_ar_rounded,
                      color: _activeTab == 3 ? Colors.black : AppTheme.primaryGlow,
                      size: 18,
                    ),
                  ),
                  onPressed: () => setState(() => _activeTab = _activeTab == 3 ? 0 : 3),
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

                // PPP Gateway Status Button (Local vs Remote Pill)
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
                            ? (isRemote ? AppTheme.accentPurple : AppTheme.accentGreen).withValues(alpha: 0.5)
                            : Colors.redAccent.withValues(alpha: 0.5),
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
                                ? (isRemote ? AppTheme.accentPurple : AppTheme.accentGreen)
                                : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRemote ? 'Remote 5G' : tr('ppp_gateway'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              ppp.status == ConnectionStatus.connected ? '${ppp.latencyMs}ms' : tr('offline'),
                              style: TextStyle(
                                fontSize: 10,
                                color: ppp.status == ConnectionStatus.connected
                                    ? (isRemote ? AppTheme.accentPurple : AppTheme.accentGreen)
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
          body: Container(
            decoration: AppTheme.logoBackgroundDecoration,
            child: Column(
            children: [
              // Traveling Mode Banner (if active)
              if (isRemote)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.accentPurple.withValues(alpha: 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flight_takeoff_rounded, color: AppTheme.accentPurple, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        tr('remote_active'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

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
                        isRemote ? Icons.cloud_done_rounded : Icons.speed_rounded,
                        isRemote ? 'TLS 1.3' : '${ppp.cpuUsage.toStringAsFixed(1)}%',
                        isRemote ? 'Cloud Tunnel' : tr('cpu_load'),
                        isRemote ? AppTheme.accentPurple : AppTheme.accentAmber,
                      ),
                    ],
                  ),
                ),
              ),

              // Room Selector Tabs (only shown on Lighting, Devices or 3D tab)
              if (_activeTab != 2)
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
                          selectedColor: isRemote ? AppTheme.accentPurple : AppTheme.primary,
                          backgroundColor: AppTheme.surfaceDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected ? (isRemote ? AppTheme.accentPurple : AppTheme.primary) : AppTheme.borderDark,
                            ),
                          ),
                          onSelected: (_) => widget.controller.setSelectedRoom(roomKey),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Body Content (Lighting, Appliances, Automations, or 3D Interactive Studio)
              Expanded(
                child: IndexedStack(
                  index: _activeTab,
                  children: [
                    LightingView(controller: widget.controller),
                    DevicesView(controller: widget.controller),
                    AutomationsView(controller: widget.controller),
                    ThreeDInteractiveView(controller: widget.controller),
                  ],
                ),
              ),
            ],
          ),
        ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: BottomNavigationBar(
              currentIndex: _activeTab > 2 ? 0 : _activeTab,
              onTap: (index) => setState(() => _activeTab = index),
              backgroundColor: AppTheme.surfaceDark,
              selectedItemColor: isRemote ? AppTheme.accentPurple : AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.lightbulb_rounded),
                  activeIcon: Icon(Icons.lightbulb_rounded, color: isRemote ? AppTheme.accentPurple : AppTheme.primary),
                  label: tr('lighting_hub'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.tune_rounded),
                  activeIcon: Icon(Icons.tune_rounded, color: isRemote ? AppTheme.accentPurple : AppTheme.primary),
                  label: tr('appliances_climate'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.auto_awesome_rounded),
                  activeIcon: Icon(Icons.auto_awesome_rounded, color: isRemote ? AppTheme.accentPurple : AppTheme.primary),
                  label: tr('automations_routines'),
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
              const SizedBox(height: 18),

              // Remote Travel Mode Toggle
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  side: const BorderSide(color: AppTheme.accentPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.controller.toggleNetworkAccessMode();
                },
                icon: const Icon(Icons.flight_takeoff_rounded, color: AppTheme.accentPurple),
                label: Text(
                  widget.controller.isRemoteMode ? tr('switch_to_local') : tr('switch_to_remote'),
                  style: const TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),
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
