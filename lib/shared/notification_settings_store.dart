import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationCategory { message, welfare, system }

class NotificationSettingsStore extends ChangeNotifier {
  NotificationSettingsStore._();
  static final instance = NotificationSettingsStore._();

  static const _keyMaster = 'noti_master';
  static const _keyMessage = 'noti_message';
  static const _keyAppointment = 'noti_appointment'; // legacy key → welfare
  static const _keySystem = 'noti_system';
  static const _keySound = 'noti_sound';
  static const _keyVibration = 'noti_vibration';

  bool masterEnabled = true;
  bool messageEnabled = true;
  bool appointmentEnabled = true; // welfare rights alerts
  bool systemEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    masterEnabled = prefs.getBool(_keyMaster) ?? true;
    messageEnabled = prefs.getBool(_keyMessage) ?? true;
    appointmentEnabled = prefs.getBool(_keyAppointment) ?? true;
    systemEnabled = prefs.getBool(_keySystem) ?? true;
    soundEnabled = prefs.getBool(_keySound) ?? true;
    vibrationEnabled = prefs.getBool(_keyVibration) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaster, masterEnabled);
    await prefs.setBool(_keyMessage, messageEnabled);
    await prefs.setBool(_keyAppointment, appointmentEnabled);
    await prefs.setBool(_keySystem, systemEnabled);
    await prefs.setBool(_keySound, soundEnabled);
    await prefs.setBool(_keyVibration, vibrationEnabled);
    notifyListeners();
  }

  void update({
    bool? masterEnabled,
    bool? messageEnabled,
    bool? appointmentEnabled,
    bool? systemEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    if (masterEnabled != null) this.masterEnabled = masterEnabled;
    if (messageEnabled != null) this.messageEnabled = messageEnabled;
    if (appointmentEnabled != null) this.appointmentEnabled = appointmentEnabled;
    if (systemEnabled != null) this.systemEnabled = systemEnabled;
    if (soundEnabled != null) this.soundEnabled = soundEnabled;
    if (vibrationEnabled != null) this.vibrationEnabled = vibrationEnabled;
    notifyListeners();
  }

  bool shouldNotify(Map<String, dynamic> data) {
    if (!masterEnabled) return false;
    switch (resolveCategory(data)) {
      case NotificationCategory.message:
        return messageEnabled;
      case NotificationCategory.welfare:
        return appointmentEnabled;
      case NotificationCategory.system:
        return systemEnabled;
    }
  }

  bool get shouldPlaySound => masterEnabled && soundEnabled;
  bool get shouldVibrate => masterEnabled && vibrationEnabled;

  static NotificationCategory resolveCategory(Map<String, dynamic> data) {
    final page = data['page']?.toString() ?? '';
    final type = data['type']?.toString() ?? '';
    final category = data['category']?.toString() ?? '';

    if (page == 'chat' || type == 'chat_message' || category == 'message') {
      return NotificationCategory.message;
    }

    if (page.contains('welfare') ||
        page.contains('rights') ||
        type.contains('benefit') ||
        type.contains('welfare') ||
        category == 'welfare') {
      return NotificationCategory.welfare;
    }

    return NotificationCategory.system;
  }
}
