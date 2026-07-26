import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/device_model.dart';
import '../widgets/three_d_device_card.dart';

class ThreeDInteractiveView extends StatelessWidget {
  final SmartHomeController controller;

  const ThreeDInteractiveView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final devices = controller.filteredDevices;
    final isAr = controller.isArabic;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.3),
                  AppTheme.accentPurple.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.view_in_ar_rounded, color: AppTheme.primaryGlow, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'التحكم باللمس ثلاثي الأبعاد' : '3D Interactive Object Studio',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr
                            ? 'اضغط مباشرة على مجسمات 3D للتشغيل أو اسحب لضبط السطوع والحرارة بدون أزرار تقليدية'
                            : 'Tap 3D device objects to toggle or slide to adjust parameters without flat buttons',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Room Section Header
          Text(
            '${controller.getLocalizedRoom(controller.selectedRoom)} (${devices.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 3D Device Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final localizedName = controller.getLocalizedDeviceName(device);

              return ThreeDDeviceCard(
                device: device,
                localizedName: localizedName,
                onTap: () => controller.toggleDevice(device.id),
                onParamChanged: (val) {
                  if (device.type == DeviceType.light) {
                    controller.setLightBrightness(device.id, val);
                  } else if (device.type == DeviceType.hvac) {
                    controller.setHvacTemperature(device.id, val);
                  } else if (device.type == DeviceType.curtain) {
                    controller.setCurtainPosition(device.id, val);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
