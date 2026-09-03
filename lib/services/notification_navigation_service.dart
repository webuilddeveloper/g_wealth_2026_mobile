import 'package:LawyerOnline/main.dart' show navigatorKey;
import 'package:LawyerOnline/models/user_profile_store.dart';
import 'package:LawyerOnline/notification-detail.dart';
import 'package:flutter/material.dart';

/// นำทางจากการแจ้งเตือนไปหน้ารายละเอียด (G-Wealth)
class NotificationNavigationService {
  static String extractCode(Map<String, dynamic> data) {
    final ref = data['refCode']?.toString().trim() ?? '';
    if (ref.isNotEmpty) return ref;
    return data['code']?.toString().trim() ?? '';
  }

  static bool canNavigate(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? '';
    final body = data['body']?.toString() ?? '';
    return title.isNotEmpty || body.isNotEmpty || extractCode(data).isNotEmpty;
  }

  static void handlePayload(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      await handle(context, data);
    });
  }

  static Future<bool> handle(
    BuildContext context,
    Map<String, dynamic> data, {
    bool showLoading = true,
  }) async {
    await UserProfileStore.instance.load();
    if (!context.mounted) return false;
    if (!UserProfileStore.instance.isLoggedIn) return false;

    final code = extractCode(data);
    final title = data['title']?.toString() ?? 'แจ้งเตือน';
    final body = data['body']?.toString() ?? '';

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailPage(
          data: {
            'code': code,
            'title': title,
            'body': body,
            'description': body,
            'createDate': data['createDate']?.toString() ?? '',
            'isRead': true,
            'category': data['category']?.toString() ??
                data['type']?.toString() ??
                'system',
            ...data,
          },
        ),
      ),
    );
    return true;
  }
}
