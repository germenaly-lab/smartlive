import 'package:flutter/material.dart';

enum TriggerType { schedule, sensor, deviceState }

class AutomationAction {
  final String deviceId;
  final String deviceName;
  final bool setOn;
  final double? setBrightness;
  final Color? setColor;
  final double? setValue; // Temp or curtain %

  AutomationAction({
    required this.deviceId,
    required this.deviceName,
    required this.setOn,
    this.setBrightness,
    this.setColor,
    this.setValue,
  });
}

class SmartAutomationModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final IconData icon;
  final Color accentColor;
  final TriggerType triggerType;
  final String triggerTime; // e.g. "07:30 AM" or "Temp > 26°C"
  final bool isActive;
  final bool isPreset;
  final List<String> activeDays; // ['Mon', 'Tue', ...]
  final List<AutomationAction> actions;

  SmartAutomationModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.icon,
    required this.accentColor,
    required this.triggerType,
    required this.triggerTime,
    this.isActive = true,
    this.isPreset = false,
    this.activeDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    required this.actions,
  });

  SmartAutomationModel copyWith({
    String? id,
    String? titleEn,
    String? titleAr,
    String? descEn,
    String? descAr,
    IconData? icon,
    Color? accentColor,
    TriggerType? triggerType,
    String? triggerTime,
    bool? isActive,
    bool? isPreset,
    List<String>? activeDays,
    List<AutomationAction>? actions,
  }) {
    return SmartAutomationModel(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descEn: descEn ?? this.descEn,
      descAr: descAr ?? this.descAr,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      triggerType: triggerType ?? this.triggerType,
      triggerTime: triggerTime ?? this.triggerTime,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
      activeDays: activeDays ?? this.activeDays,
      actions: actions ?? this.actions,
    );
  }
}
