import 'package:flutter/material.dart';

enum DeviceType { light, hvac, lock, plug, curtain, tv }

class SmartDeviceModel {
  final String id;
  final String name;
  final String room;
  final DeviceType type;
  final bool isOn;
  final double brightness; // 0.0 - 100.0 for lights
  final Color color; // For RGB lighting
  final double colorTemp; // 2700K - 6500K for white light
  final double value; // Generic parameter: Temp in °C for HVAC, % for curtains, Watts for plug
  final String mode; // HVAC mode or Scene mode
  final IconData icon;

  SmartDeviceModel({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    this.isOn = false,
    this.brightness = 80.0,
    this.color = const Color(0xFFFFB74D), // Warm Amber default
    this.colorTemp = 3200.0,
    this.value = 24.0,
    this.mode = 'Auto',
    required this.icon,
  });

  SmartDeviceModel copyWith({
    String? id,
    String? name,
    String? room,
    DeviceType? type,
    bool? isOn,
    double? brightness,
    Color? color,
    double? colorTemp,
    double? value,
    String? mode,
    IconData? icon,
  }) {
    return SmartDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      colorTemp: colorTemp ?? this.colorTemp,
      value: value ?? this.value,
      mode: mode ?? this.mode,
      icon: icon ?? this.icon,
    );
  }
}
