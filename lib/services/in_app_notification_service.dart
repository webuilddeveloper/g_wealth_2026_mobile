import 'package:gwealth/shared/notification_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:gwealth/main.dart';
import 'package:gwealth/services/notification_service.dart';
import 'package:gwealth/widgets/top_notification_banner.dart';

class InAppNotificationService {
  static OverlayEntry? _entry;

  static Future<void> show({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    VoidCallback? onTap,
  }) async {
    final settings = NotificationSettingsStore.instance;
    if (data != null && !settings.shouldNotify(data)) return;

    await NotificationService.playForegroundAlert(
      sound: settings.shouldPlaySound,
      vibration: settings.shouldVibrate,
    );

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _entry?.remove();
    _entry = null;

    _entry = OverlayEntry(
      builder: (context) => TopNotificationBanner(
        title: title,
        body: body,
        imageUrl: _readImageUrl(data),
        onTap: onTap,
        onDismiss: () {
          _entry?.remove();
          _entry = null;
        },
      ),
    );

    overlay.insert(_entry!);
  }

  static String? _readImageUrl(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in const [
      'imageUrl',
      'senderImageUrl',
      'senderImage',
      'avatar',
      'imageUrlCreateBy',
    ]) {
      final v = data[key]?.toString().trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return null;
  }
}
