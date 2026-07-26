import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/device_model.dart';

class LightingView extends StatelessWidget {
  final SmartHomeController controller;

  const LightingView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final lights = controller.filteredLights;
    final tr = controller.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scene Presets Bar
          Text(
            tr('quick_mood_scenes'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSceneCard(context, controller.isArabic ? 'استرخاء' : 'Relax', Icons.nightlight_round, const Color(0xFFF59E0B)),
                _buildSceneCard(context, controller.isArabic ? 'تركيز' : 'Focus', Icons.light_mode_rounded, const Color(0xFF3B82F6)),
                _buildSceneCard(context, controller.isArabic ? 'حفلة' : 'Party Glow', Icons.celebration_rounded, const Color(0xFFE11D48)),
                _buildSceneCard(context, controller.isArabic ? 'أجواء ليلية' : 'Night Ambient', Icons.bedtime_rounded, const Color(0xFFA855F7)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Master Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tr('smart_lighting')} (${lights.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
                    onPressed: () => controller.turnOffAllLights(),
                    icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                    label: Text(tr('off_all')),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.accentAmber,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => controller.turnOnAllLights(),
                    icon: const Icon(Icons.wb_sunny_rounded, size: 16),
                    label: Text(tr('full_brightness')),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lighting Cards Grid / List
          if (lights.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                '${tr('no_lights')} ${controller.getLocalizedRoom(controller.selectedRoom)}',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lights.length,
              itemBuilder: (context, index) {
                final light = lights[index];
                return _buildLightCard(context, light);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSceneCard(BuildContext context, String title, IconData icon, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          controller.applyScene(title);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${controller.tr('applied_scene')}: "$title"'),
              duration: const Duration(seconds: 1),
              backgroundColor: accent,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLightCard(BuildContext context, SmartDeviceModel light) {
    final deviceName = controller.getLocalizedDeviceName(light);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: light.isOn ? light.color.withValues(alpha: 0.5) : AppTheme.borderDark,
          width: light.isOn ? 1.5 : 1,
        ),
        boxShadow: light.isOn
            ? [
                BoxShadow(
                  color: light.color.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Glow Light Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: light.isOn ? light.color.withValues(alpha: 0.2) : AppTheme.surfaceDark,
                  shape: BoxShape.circle,
                  boxShadow: light.isOn
                      ? [
                          BoxShadow(
                            color: light.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  light.icon,
                  color: light.isOn ? light.color : AppTheme.textMuted,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),

              // Title and Room
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          controller.getLocalizedRoom(light.room),
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        if (light.isOn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: light.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${light.brightness.round()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: light.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Color Preset Selector Button
              IconButton(
                icon: CircleAvatar(
                  radius: 12,
                  backgroundColor: light.color,
                  child: const Icon(Icons.color_lens_rounded, size: 14, color: Colors.black54),
                ),
                onPressed: () => _showColorPickerSheet(context, light, deviceName),
              ),

              // Switch Toggle
              Switch(
                value: light.isOn,
                activeThumbColor: light.color,
                onChanged: (_) => controller.toggleDevice(light.id),
              ),
            ],
          ),

          // Brightness Slider (if light is on)
          if (light.isOn) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.brightness_low_rounded, size: 16, color: AppTheme.textSecondary),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: light.color,
                      inactiveTrackColor: AppTheme.borderDark,
                      thumbColor: Colors.white,
                      overlayColor: light.color.withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: light.brightness,
                      min: 0,
                      max: 100,
                      onChanged: (val) => controller.setLightBrightness(light.id, val),
                    ),
                  ),
                ),
                const Icon(Icons.brightness_high_rounded, size: 16, color: AppTheme.textPrimary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showColorPickerSheet(BuildContext context, SmartDeviceModel light, String deviceName) {
    final tr = controller.tr;
    final colors = [
      const Color(0xFFFFB74D), // Warm Sunset Amber
      const Color(0xFFFFFFFF), // Daylight Pure White
      const Color(0xFF3B82F6), // Electric Ocean Blue
      const Color(0xFF10B981), // Emerald Green
      const Color(0xFFA855F7), // Neon Lavender
      const Color(0xFFF43F5E), // Crimson Red
      const Color(0xFFF59E0B), // Golden Yellow
    ];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('light_palette')}: $deviceName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('select_rgb'),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: colors.map((c) {
                  final isSelected = light.color == c;
                  return GestureDetector(
                    onTap: () {
                      controller.setLightColor(light.id, c);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.black87, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
