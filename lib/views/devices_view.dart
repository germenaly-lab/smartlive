import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/device_model.dart';

class DevicesView extends StatelessWidget {
  final SmartHomeController controller;

  const DevicesView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final appliances = controller.filteredAppliances;
    final tr = controller.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tr('ppp_appliances')} (${appliances.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: AppTheme.accentGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '365 W ${tr('total_active')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (appliances.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                '${tr('no_appliances')} ${controller.getLocalizedRoom(controller.selectedRoom)}',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appliances.length,
              itemBuilder: (context, index) {
                final device = appliances[index];
                switch (device.type) {
                  case DeviceType.hvac:
                    return _buildHvacCard(context, device);
                  case DeviceType.lock:
                    return _buildLockCard(context, device);
                  case DeviceType.plug:
                    return _buildPlugCard(context, device);
                  case DeviceType.curtain:
                    return _buildCurtainCard(context, device);
                  case DeviceType.tv:
                    return _buildTvCard(context, device);
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
        ],
      ),
    );
  }

  // --- HVAC Air Conditioning Card ---
  Widget _buildHvacCard(BuildContext context, SmartDeviceModel device) {
    final tr = controller.tr;
    final name = controller.getLocalizedDeviceName(device);
    final room = controller.getLocalizedRoom(device.room);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: device.isOn ? AppTheme.accentBlue.withValues(alpha: 0.5) : AppTheme.borderDark,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: device.isOn ? AppTheme.accentBlue.withValues(alpha: 0.2) : AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  device.icon,
                  color: device.isOn ? AppTheme.accentBlue : AppTheme.textMuted,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text('$room • ${device.mode}', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: device.isOn,
                activeThumbColor: AppTheme.accentBlue,
                onChanged: (_) => controller.toggleDevice(device.id),
              ),
            ],
          ),

          if (device.isOn) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textSecondary, size: 28),
                  onPressed: () {
                    if (device.value > 16) {
                      controller.setHvacTemperature(device.id, device.value - 1);
                    }
                  },
                ),
                Column(
                  children: [
                    Text(
                      '${device.value.round()}°C',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(tr('target_temp'), style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.textSecondary, size: 28),
                  onPressed: () {
                    if (device.value < 30) {
                      controller.setHvacTemperature(device.id, device.value + 1);
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- Smart Lock Card ---
  Widget _buildLockCard(BuildContext context, SmartDeviceModel device) {
    final tr = controller.tr;
    final isLocked = device.isOn;
    final name = controller.getLocalizedDeviceName(device);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLocked ? AppTheme.accentGreen.withValues(alpha: 0.5) : AppTheme.accentRose.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked ? AppTheme.accentGreen.withValues(alpha: 0.15) : AppTheme.accentRose.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: isLocked ? AppTheme.accentGreen : AppTheme.accentRose,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  isLocked ? tr('secured_locked') : tr('unlocked_attention'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppTheme.accentGreen : AppTheme.accentRose,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked ? AppTheme.surfaceDark : AppTheme.accentGreen,
              foregroundColor: isLocked ? AppTheme.textPrimary : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => controller.toggleDevice(device.id),
            child: Text(isLocked ? tr('unlock') : tr('lock_now')),
          ),
        ],
      ),
    );
  }

  // --- Smart Plug Card ---
  Widget _buildPlugCard(BuildContext context, SmartDeviceModel device) {
    final tr = controller.tr;
    final name = controller.getLocalizedDeviceName(device);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isOn ? AppTheme.accentAmber.withValues(alpha: 0.2) : AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              device.icon,
              color: device.isOn ? AppTheme.accentAmber : AppTheme.textMuted,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  device.isOn ? '${tr('power_watts')}: ${device.value.round()} W' : tr('standby'),
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: device.isOn,
            activeThumbColor: AppTheme.accentAmber,
            onChanged: (_) => controller.toggleDevice(device.id),
          ),
        ],
      ),
    );
  }

  // --- Smart Curtain Card ---
  Widget _buildCurtainCard(BuildContext context, SmartDeviceModel device) {
    final tr = controller.tr;
    final name = controller.getLocalizedDeviceName(device);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(device.icon, color: AppTheme.accentPurple, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text('${tr('open_state')}: ${device.value.round()}%', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.accentPurple,
              inactiveTrackColor: AppTheme.borderDark,
              thumbColor: Colors.white,
              trackHeight: 6,
            ),
            child: Slider(
              value: device.value,
              min: 0,
              max: 100,
              onChanged: (val) => controller.setCurtainPosition(device.id, val),
            ),
          ),
        ],
      ),
    );
  }

  // --- Smart TV Card ---
  Widget _buildTvCard(BuildContext context, SmartDeviceModel device) {
    final tr = controller.tr;
    final name = controller.getLocalizedDeviceName(device);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isOn ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              device.icon,
              color: device.isOn ? AppTheme.primary : AppTheme.textMuted,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(device.isOn ? 'HDMI 1 • Vol 40%' : tr('powered_off'), style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: device.isOn,
            activeThumbColor: AppTheme.primary,
            onChanged: (_) => controller.toggleDevice(device.id),
          ),
        ],
      ),
    );
  }
}
