import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';

class ThreeDDeviceCard extends StatefulWidget {
  final SmartDeviceModel device;
  final String localizedName;
  final VoidCallback onTap;
  final ValueChanged<double>? onParamChanged;

  const ThreeDDeviceCard({
    super.key,
    required this.device,
    required this.localizedName,
    required this.onTap,
    this.onParamChanged,
  });

  @override
  State<ThreeDDeviceCard> createState() => _ThreeDDeviceCardState();
}

class _ThreeDDeviceCardState extends State<ThreeDDeviceCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.device;
    final isOn = d.isOn;
    final accent = d.type == DeviceType.light
        ? d.color
        : (d.type == DeviceType.hvac
            ? AppTheme.accentBlue
            : (d.type == DeviceType.lock
                ? (isOn ? AppTheme.accentGreen : AppTheme.accentRose)
                : AppTheme.accentAmber));

    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: isOn
                      ? [
                          AppTheme.surfaceDark,
                          accent.withValues(alpha: 0.25),
                        ]
                      : [
                          AppTheme.cardDark,
                          AppTheme.surfaceDark,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isOn ? accent.withValues(alpha: 0.6) : AppTheme.borderDark,
                  width: isOn ? 2 : 1,
                ),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 3D Volumetric Object Avatar
                  _build3dObjectAvatar(d, isOn, accent),

                  const SizedBox(height: 12),

                  // Device Name & Status
                  Column(
                    children: [
                      Text(
                        widget.localizedName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getParamSummary(d),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOn ? accent : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),

                  // 3D Interactive Parameter Gesture Ring (if on and adjustable)
                  if (isOn && widget.onParamChanged != null) ...[
                    const SizedBox(height: 8),
                    _build3dParameterSlider(d, accent),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Volumetric 3D Object Renderer ---
  Widget _build3dObjectAvatar(SmartDeviceModel d, bool isOn, Color accent) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isOn
              ? [
                  accent.withValues(alpha: 0.8),
                  accent.withValues(alpha: 0.2),
                  Colors.transparent,
                ]
              : [
                  AppTheme.cardDark,
                  AppTheme.surfaceDark,
                ],
          radius: 0.85,
        ),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn ? accent : AppTheme.surfaceDark,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Icon(
            _get3dIcon(d.type, isOn),
            color: isOn ? Colors.white : AppTheme.textMuted,
            size: 34,
          ),
        ),
      ),
    );
  }

  IconData _get3dIcon(DeviceType type, bool isOn) {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb_rounded;
      case DeviceType.hvac:
        return Icons.ac_unit_rounded;
      case DeviceType.lock:
        return isOn ? Icons.lock_rounded : Icons.lock_open_rounded;
      case DeviceType.plug:
        return Icons.power_rounded;
      case DeviceType.curtain:
        return Icons.blinds_rounded;
      case DeviceType.tv:
        return Icons.tv_rounded;
    }
  }

  String _getParamSummary(SmartDeviceModel d) {
    if (!d.isOn) return 'OFF';
    switch (d.type) {
      case DeviceType.light:
        return '${d.brightness.round()}% Brightness';
      case DeviceType.hvac:
        return '${d.value.round()}°C Cool';
      case DeviceType.lock:
        return 'LOCKED';
      case DeviceType.plug:
        return '${d.value.round()} W Active';
      case DeviceType.curtain:
        return '${d.value.round()}% Open';
      case DeviceType.tv:
        return 'Volume ${d.value.round()}%';
    }
  }

  // --- Interactive Gesture Slider ---
  Widget _build3dParameterSlider(SmartDeviceModel d, Color accent) {
    double currentVal = d.type == DeviceType.light ? d.brightness : d.value;
    double minVal = d.type == DeviceType.hvac ? 16.0 : 0.0;
    double maxVal = d.type == DeviceType.hvac ? 30.0 : 100.0;

    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: AppTheme.borderDark,
        thumbColor: Colors.white,
        overlayColor: accent.withValues(alpha: 0.2),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      child: Slider(
        value: currentVal.clamp(minVal, maxVal),
        min: minVal,
        max: maxVal,
        onChanged: widget.onParamChanged,
      ),
    );
  }
}
