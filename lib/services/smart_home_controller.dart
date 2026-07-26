import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/ppp_system_model.dart';
import '../models/device_model.dart';
import '../models/automation_model.dart';
import '../l10n/app_translations.dart';

class SmartHomeController extends ChangeNotifier {
  // --- Language / Localization State ---
  String _currentLanguage = 'ar'; // Defaulting to Arabic (bilingual Arabic & English support)

  String get currentLanguage => _currentLanguage;
  bool get isArabic => _currentLanguage == 'ar';
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'ar' ? 'en' : 'ar';
    notifyListeners();
  }

  void setLanguage(String langCode) {
    if (langCode == 'ar' || langCode == 'en') {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  String tr(String key) => AppTranslations.getText(key, _currentLanguage);

  // --- Google Sign-In State ---
  UserModel _currentUser = UserModel.guest();
  bool _isAuthLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  UserModel get currentUser => _currentUser;
  bool get isAuthLoading => _isAuthLoading;
  bool get isLoggedIn => _currentUser.isLoggedIn;

  // --- PPP System Connection State (Local & Remote Travel Mode) ---
  PppSystemConfig _pppConfig = PppSystemConfig(
    ipAddress: '192.168.1.120',
    port: 8080,
    gatewayName: 'PPP-Gateway-Hub-V3',
    apiKey: 'ppp_sec_9942a8b27c1f',
    status: ConnectionStatus.connected,
    mode: NetworkAccessMode.local,
    cloudEndpoint: 'wss://remote.pppsystem.io/v3/gateway',
    isEncryptedTls: true,
    latencyMs: 14,
    cpuUsage: 19.2,
    memoryUsage: 41.5,
    activeNodesCount: 14,
    protocol: 'WebSocket / MQTT (TLS)',
  );

  PppSystemConfig get pppConfig => _pppConfig;
  bool get isRemoteMode => _pppConfig.mode == NetworkAccessMode.remote;

  void toggleNetworkAccessMode() {
    if (_pppConfig.mode == NetworkAccessMode.local) {
      _pppConfig = _pppConfig.copyWith(
        mode: NetworkAccessMode.remote,
        latencyMs: 42,
        protocol: 'PPP Cloud Relay (TLS 1.3)',
      );
    } else {
      _pppConfig = _pppConfig.copyWith(
        mode: NetworkAccessMode.local,
        latencyMs: 14,
        protocol: 'WebSocket / MQTT (Local)',
      );
    }
    notifyListeners();
  }

  // --- Filter State ---
  String _selectedRoom = 'All Rooms';
  String get selectedRoom => _selectedRoom;

  void setSelectedRoom(String room) {
    _selectedRoom = room;
    notifyListeners();
  }

  // --- Devices & Lighting State ---
  List<SmartDeviceModel> _devices = [
    // Lighting Devices
    SmartDeviceModel(
      id: 'light_1',
      name: 'Main Ceiling Chandelier',
      room: 'Living Room',
      type: DeviceType.light,
      isOn: true,
      brightness: 85.0,
      color: const Color(0xFFFFB74D), // Warm Glow
      colorTemp: 3000.0,
      icon: Icons.lightbulb_rounded,
    ),
    SmartDeviceModel(
      id: 'light_2',
      name: 'Ambient LED Wall Strip',
      room: 'Living Room',
      type: DeviceType.light,
      isOn: true,
      brightness: 60.0,
      color: const Color(0xFF6366F1), // Indigo
      colorTemp: 4500.0,
      icon: Icons.tungsten_rounded,
    ),
    SmartDeviceModel(
      id: 'light_3',
      name: 'Night Reading Lamp',
      room: 'Bedroom',
      type: DeviceType.light,
      isOn: false,
      brightness: 40.0,
      color: const Color(0xFFF59E0B),
      colorTemp: 2700.0,
      icon: Icons.bed_rounded,
    ),
    SmartDeviceModel(
      id: 'light_4',
      name: 'Bedroom Ceiling Light',
      room: 'Bedroom',
      type: DeviceType.light,
      isOn: true,
      brightness: 70.0,
      color: const Color(0xFF10B981),
      colorTemp: 3500.0,
      icon: Icons.lightbulb_rounded,
    ),
    SmartDeviceModel(
      id: 'light_5',
      name: 'Countertop Lights',
      room: 'Kitchen',
      type: DeviceType.light,
      isOn: true,
      brightness: 90.0,
      color: const Color(0xFFFFFFFF),
      colorTemp: 5500.0,
      icon: Icons.wb_incandescent_rounded,
    ),
    SmartDeviceModel(
      id: 'light_6',
      name: 'Desk Study Lamp',
      room: 'Office',
      type: DeviceType.light,
      isOn: false,
      brightness: 50.0,
      color: const Color(0xFF3B82F6),
      colorTemp: 4000.0,
      icon: Icons.desk_rounded,
    ),

    // Appliances & Smart System Devices
    SmartDeviceModel(
      id: 'hvac_1',
      name: 'Living Room Inverter AC',
      room: 'Living Room',
      type: DeviceType.hvac,
      isOn: true,
      value: 22.0, // °C
      mode: 'Cool',
      icon: Icons.ac_unit_rounded,
    ),
    SmartDeviceModel(
      id: 'lock_1',
      name: 'Main Entrance Smart Lock',
      room: 'Living Room',
      type: DeviceType.lock,
      isOn: true, // true = locked
      icon: Icons.lock_rounded,
    ),
    SmartDeviceModel(
      id: 'plug_1',
      name: 'Coffee Maker Smart Plug',
      room: 'Kitchen',
      type: DeviceType.plug,
      isOn: false,
      value: 120.0, // Watts
      icon: Icons.power_rounded,
    ),
    SmartDeviceModel(
      id: 'curtain_1',
      name: 'Panoramic Smart Blinds',
      room: 'Living Room',
      type: DeviceType.curtain,
      isOn: true,
      value: 75.0, // 75% Open
      icon: Icons.blinds_rounded,
    ),
    SmartDeviceModel(
      id: 'tv_1',
      name: 'OLED 4K Cinema TV',
      room: 'Living Room',
      type: DeviceType.tv,
      isOn: false,
      value: 40.0, // Volume
      icon: Icons.tv_rounded,
    ),
  ];

  List<SmartDeviceModel> get devices => _devices;

  List<SmartDeviceModel> get lights {
    return _devices.where((d) => d.type == DeviceType.light).toList();
  }

  List<SmartDeviceModel> get appliances {
    return _devices.where((d) => d.type != DeviceType.light).toList();
  }

  List<SmartDeviceModel> get filteredDevices {
    if (_selectedRoom == 'All Rooms') return _devices;
    return _devices.where((d) => d.room == _selectedRoom).toList();
  }

  List<SmartDeviceModel> get filteredLights {
    if (_selectedRoom == 'All Rooms') return lights;
    return lights.where((d) => d.room == _selectedRoom).toList();
  }

  List<SmartDeviceModel> get filteredAppliances {
    if (_selectedRoom == 'All Rooms') return appliances;
    return appliances.where((d) => d.room == _selectedRoom).toList();
  }

  int get totalActiveDevices => _devices.where((d) => d.isOn).length;

  // --- Automations & Daily Routines State ---
  final List<SmartAutomationModel> _automations = [
    // 1-Tap Daily Routines
    SmartAutomationModel(
      id: 'routine_morning',
      titleEn: 'Good Morning Routine',
      titleAr: 'روتين صباح الخير',
      descEn: 'Lights on 70%, AC set to 24°C, Curtains open 80%, Coffee plug ON',
      descAr: 'تشغيل إضاءة غرفة النوم والمطبخ، التكييف 24°م، الستائر 80%، تشغيل القهوة',
      icon: Icons.wb_sunny_rounded,
      accentColor: const Color(0xFFF59E0B),
      triggerType: TriggerType.schedule,
      triggerTime: '07:00 AM',
      isPreset: true,
      actions: [
        AutomationAction(deviceId: 'light_4', deviceName: 'Bedroom Light', setOn: true, setBrightness: 70.0),
        AutomationAction(deviceId: 'light_5', deviceName: 'Kitchen Light', setOn: true, setBrightness: 80.0),
        AutomationAction(deviceId: 'hvac_1', deviceName: 'AC Inverter', setOn: true, setValue: 24.0),
        AutomationAction(deviceId: 'curtain_1', deviceName: 'Smart Blinds', setOn: true, setValue: 80.0),
        AutomationAction(deviceId: 'plug_1', deviceName: 'Coffee Maker Plug', setOn: true),
      ],
    ),
    SmartAutomationModel(
      id: 'routine_away',
      titleEn: 'Leaving Home Routine',
      titleAr: 'روتين مغادرة المنزل',
      descEn: 'Turn off all lights, Lock main door, AC to 26°C Eco, Coffee plug OFF',
      descAr: 'إطفاء جميع الأنوار، إقفال الباب الرئيسي، التكييف 26°م اقتصادي',
      icon: Icons.directions_run_rounded,
      accentColor: const Color(0xFF10B981),
      triggerType: TriggerType.schedule,
      triggerTime: '08:30 AM',
      isPreset: true,
      actions: [
        AutomationAction(deviceId: 'light_1', deviceName: 'All Lights', setOn: false),
        AutomationAction(deviceId: 'lock_1', deviceName: 'Main Lock', setOn: true), // locked
        AutomationAction(deviceId: 'hvac_1', deviceName: 'AC Inverter', setOn: true, setValue: 26.0),
        AutomationAction(deviceId: 'plug_1', deviceName: 'Coffee Plug', setOn: false),
      ],
    ),
    SmartAutomationModel(
      id: 'routine_sleep',
      titleEn: 'Good Night Sleep',
      titleAr: 'روتين تصبح على خير',
      descEn: 'Turn off living room/kitchen lights, dim reading lamp to 15%, lock door',
      descAr: 'إطفاء أنوار الصالة، تخفيض إضاءة القراءة 15%، قفل الباب الرئيسي',
      icon: Icons.bedtime_rounded,
      accentColor: const Color(0xFFA855F7),
      triggerType: TriggerType.schedule,
      triggerTime: '11:00 PM',
      isPreset: true,
      actions: [
        AutomationAction(deviceId: 'light_1', deviceName: 'Living Room Light', setOn: false),
        AutomationAction(deviceId: 'light_3', deviceName: 'Reading Lamp', setOn: true, setBrightness: 15.0),
        AutomationAction(deviceId: 'lock_1', deviceName: 'Main Lock', setOn: true),
        AutomationAction(deviceId: 'curtain_1', deviceName: 'Blinds', setOn: true, setValue: 0.0), // closed
      ],
    ),
    SmartAutomationModel(
      id: 'routine_cinema',
      titleEn: 'Movie & Cinema Mode',
      titleAr: 'وضع وقت السينما',
      descEn: 'Dim wall strip to 20% indigo, turn on 4K TV, volume 40%, close blinds',
      descAr: 'تخفيض الإضاءة للون الأزرق 20%، تشغيل التلفاز، إغلاق الستائر 100%',
      icon: Icons.movie_rounded,
      accentColor: const Color(0xFF3B82F6),
      triggerType: TriggerType.schedule,
      triggerTime: '09:00 PM',
      isPreset: true,
      actions: [
        AutomationAction(deviceId: 'light_2', deviceName: 'LED Wall Strip', setOn: true, setBrightness: 20.0, setColor: const Color(0xFF6366F1)),
        AutomationAction(deviceId: 'tv_1', deviceName: 'Cinema TV', setOn: true, setValue: 40.0),
        AutomationAction(deviceId: 'curtain_1', deviceName: 'Blinds', setOn: true, setValue: 0.0),
      ],
    ),

    // Customizable Scheduled Automations
    SmartAutomationModel(
      id: 'auto_sunset_lights',
      titleEn: 'Auto Sunset Porch Lights',
      titleAr: 'تشغيل إضاءة المدخل عند الغروب',
      descEn: 'Automatically turns on wall strip and chandelier at sunset (06:45 PM)',
      descAr: 'تشغيل تلقائي لإضاءة المدخل والجدار عند غروب الشمس (06:45 م)',
      icon: Icons.wb_twilight_rounded,
      accentColor: const Color(0xFFF43F5E),
      triggerType: TriggerType.schedule,
      triggerTime: '06:45 PM',
      isPreset: false,
      actions: [
        AutomationAction(deviceId: 'light_1', deviceName: 'Chandelier', setOn: true, setBrightness: 80.0),
        AutomationAction(deviceId: 'light_2', deviceName: 'Wall Strip', setOn: true, setBrightness: 60.0),
      ],
    ),
    SmartAutomationModel(
      id: 'auto_temp_cool',
      titleEn: 'Smart Climate Temperature Protection',
      titleAr: 'حماية التكييف عند ارتفاع الحرارة',
      descEn: 'Triggers Living Room AC when room temperature exceeds 25°C',
      descAr: 'تشغيل التكييف تلقائياً عندما تتجاوز حرارة الغرفة 25 درجة مئوية',
      icon: Icons.thermostat_rounded,
      accentColor: const Color(0xFF3B82F6),
      triggerType: TriggerType.sensor,
      triggerTime: 'Temp > 25°C',
      isPreset: false,
      actions: [
        AutomationAction(deviceId: 'hvac_1', deviceName: 'Inverter AC', setOn: true, setValue: 22.0),
      ],
    ),
  ];

  List<SmartAutomationModel> get automations => _automations;
  List<SmartAutomationModel> get presetRoutines => _automations.where((a) => a.isPreset).toList();
  List<SmartAutomationModel> get customAutomations => _automations.where((a) => !a.isPreset).toList();

  void toggleAutomationActive(String id) {
    final index = _automations.indexWhere((a) => a.id == id);
    if (index != -1) {
      _automations[index] = _automations[index].copyWith(isActive: !_automations[index].isActive);
      notifyListeners();
    }
  }

  void addCustomAutomation(SmartAutomationModel automation) {
    _automations.add(automation);
    notifyListeners();
  }

  void executeAutomation(String id) {
    final automation = _automations.firstWhere((a) => a.id == id, orElse: () => _automations.first);
    for (var action in automation.actions) {
      final index = _devices.indexWhere((d) => d.id == action.deviceId);
      if (index != -1) {
        var updated = _devices[index].copyWith(isOn: action.setOn);
        if (action.setBrightness != null) {
          updated = updated.copyWith(brightness: action.setBrightness);
        }
        if (action.setColor != null) {
          updated = updated.copyWith(color: action.setColor);
        }
        if (action.setValue != null) {
          updated = updated.copyWith(value: action.setValue);
        }
        _devices[index] = updated;
      } else if (action.deviceId == 'light_1' && !action.setOn) {
        turnOffAllLights();
      }
    }
    notifyListeners();
  }

  // --- Preset Scenes ---
  void applyScene(String sceneName) {
    switch (sceneName) {
      case 'Relax':
      case 'استرخاء':
        _devices = _devices.map((d) {
          if (d.type == DeviceType.light) {
            return d.copyWith(
              isOn: true,
              brightness: 45.0,
              color: const Color(0xFFF59E0B),
            );
          }
          return d;
        }).toList();
        break;
      case 'Focus':
      case 'تركيز':
        _devices = _devices.map((d) {
          if (d.type == DeviceType.light) {
            return d.copyWith(
              isOn: true,
              brightness: 95.0,
              color: const Color(0xFF3B82F6),
            );
          }
          return d;
        }).toList();
        break;
      case 'Party Glow':
      case 'حفلة':
        _devices = _devices.map((d) {
          if (d.type == DeviceType.light) {
            return d.copyWith(
              isOn: true,
              brightness: 100.0,
              color: const Color(0xFFE11D48),
            );
          }
          return d;
        }).toList();
        break;
      case 'Night Ambient':
      case 'أجواء ليلية':
        _devices = _devices.map((d) {
          if (d.type == DeviceType.light) {
            return d.copyWith(
              isOn: d.room == 'Bedroom',
              brightness: 20.0,
              color: const Color(0xFFA855F7),
            );
          }
          return d;
        }).toList();
        break;
    }
    notifyListeners();
  }

  Timer? _telemetryTimer;

  SmartHomeController() {
    // Start background telemetry simulation for PPP system
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pppConfig.status == ConnectionStatus.connected) {
        final baseLatency = isRemoteMode ? 40 : 12;
        _pppConfig = _pppConfig.copyWith(
          latencyMs: baseLatency + (DateTime.now().second % 6),
          cpuUsage: 16.0 + (DateTime.now().second % 8),
        );
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  // --- Helpers for device and room name translation ---
  String getLocalizedRoom(String roomKey) {
    switch (roomKey) {
      case 'All Rooms':
        return tr('all_rooms');
      case 'Living Room':
        return tr('living_room');
      case 'Bedroom':
        return tr('bedroom');
      case 'Kitchen':
        return tr('kitchen');
      case 'Office':
        return tr('office');
      default:
        return roomKey;
    }
  }

  String getLocalizedDeviceName(SmartDeviceModel device) {
    if (!isArabic) return device.name;
    switch (device.id) {
      case 'light_1':
        return 'ثريا السقف الرئيسية';
      case 'light_2':
        return 'شريط إضاءة جداري LED';
      case 'light_3':
        return 'مصباح القراءة الليلي';
      case 'light_4':
        return 'إضاءة سقف غرفة النوم';
      case 'light_5':
        return 'إضاءة كاونتر المطبخ';
      case 'light_6':
        return 'مصباح المكتب والدراسة';
      case 'hvac_1':
        return 'مكيف إنفرتر المجلس';
      case 'lock_1':
        return 'القفل الذكي للمدخل الرئيسي';
      case 'plug_1':
        return 'مقبس آلة القهوة الذكي';
      case 'curtain_1':
        return 'الستائر الذكية البانورامية';
      case 'tv_1':
        return 'تلفاز السينما OLED 4K';
      default:
        return device.name;
    }
  }

  // --- Authentication Methods ---
  Future<bool> signInWithGoogle() async {
    _isAuthLoading = true;
    notifyListeners();

    try {
      final account = await _googleSignIn.authenticate();
      _currentUser = UserModel(
        id: account.id,
        name: account.displayName ?? (isArabic ? 'مستخدم ذكي' : 'Smart User'),
        email: account.email,
        photoUrl: account.photoUrl ?? 'https://i.pravatar.cc/150?img=12',
        isLoggedIn: true,
      );
      _isAuthLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // If authenticating fails on physical iOS device, prompt or fallback explicitly
      _isAuthLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void loginAsDemoUser() {
    _currentUser = UserModel(
      id: 'google_user_ppp_1092',
      name: isArabic ? 'علي أحمد' : 'Alex Johnson',
      email: 'alex.johnson@gmail.com',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      isLoggedIn: true,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    _currentUser = UserModel.guest();
    _isAuthLoading = false;
    notifyListeners();
  }

  // --- PPP System Methods ---
  Future<bool> updatePppConfig({
    required String ip,
    required int port,
    required String gateway,
    required String apiKey,
    required String cloudEndpoint,
    required NetworkAccessMode mode,
  }) async {
    _pppConfig = _pppConfig.copyWith(status: ConnectionStatus.connecting);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _pppConfig = _pppConfig.copyWith(
      ipAddress: ip,
      port: port,
      gatewayName: gateway,
      apiKey: apiKey,
      cloudEndpoint: cloudEndpoint,
      mode: mode,
      status: ConnectionStatus.connected,
      latencyMs: mode == NetworkAccessMode.remote ? 42 : 11,
    );
    notifyListeners();
    return true;
  }

  void togglePppConnection() {
    if (_pppConfig.status == ConnectionStatus.connected) {
      _pppConfig = _pppConfig.copyWith(status: ConnectionStatus.disconnected);
    } else {
      _pppConfig = _pppConfig.copyWith(status: ConnectionStatus.connected);
    }
    notifyListeners();
  }

  // --- Device Control Actions ---
  void toggleDevice(String id) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(isOn: !_devices[index].isOn);
      notifyListeners();
    }
  }

  void setLightBrightness(String id, double brightness) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(
        brightness: brightness,
        isOn: brightness > 0,
      );
      notifyListeners();
    }
  }

  void setLightColor(String id, Color color) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(color: color, isOn: true);
      notifyListeners();
    }
  }

  void setHvacTemperature(String id, double temp) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(value: temp);
      notifyListeners();
    }
  }

  void setCurtainPosition(String id, double percentage) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(
        value: percentage,
        isOn: percentage > 0,
      );
      notifyListeners();
    }
  }

  void turnOffAllLights() {
    _devices = _devices.map((d) {
      if (d.type == DeviceType.light) {
        return d.copyWith(isOn: false);
      }
      return d;
    }).toList();
    notifyListeners();
  }

  void turnOnAllLights() {
    _devices = _devices.map((d) {
      if (d.type == DeviceType.light) {
        return d.copyWith(isOn: true, brightness: 100.0);
      }
      return d;
    }).toList();
    notifyListeners();
  }
}
