import 'package:gwealth/models/user_profile_store.dart';
import 'package:gwealth/shared/api_provider.dart';
import 'package:gwealth/shared/notification_store.dart';
import 'package:intl/intl.dart';

/// โหลดและจัดรูปแบบรายการแจ้งเตือนจาก API
class NotificationListService {
  NotificationListService._();

  static Future<List<Map<String, dynamic>>> load({
    int skip = 0,
    int limit = 50,
  }) async {
    final code = UserProfileStore.instance.code;
    if (code.isEmpty) return [];

    try {
      final result = await postDio('${server}m/notification/read', {
        'code': code,
        'skip': skip,
        'limit': limit,
      });

      final raw = result?['objectData'];
      final list = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => normalize(Map<String, dynamic>.from(e)))
              .toList()
          : <Map<String, dynamic>>[];

      list.sort(_compareNotification);

      final unread = list.where((n) => n['isRead'] != true).length;
      NotificationStore.instance.setUnread(unread);

      return list;
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic> normalize(Map<String, dynamic> raw) {
    final title = raw['title']?.toString() ?? '';
    final body = raw['description']?.toString() ??
        raw['body']?.toString() ??
        raw['detail']?.toString() ??
        '';
    final createDate = raw['createDate']?.toString() ??
        raw['createdDate']?.toString() ??
        '';

    return {
      ...raw,
      'title': title,
      'body': body,
      'detail': body,
      'description': body,
      'createDate': createDate,
      'displayTime': _formatDisplayTime(createDate),
      'time': _formatDisplayTime(createDate),
      'date': _bucketDate(createDate),
      'isRead': raw['isRead'] == true ||
          raw['status']?.toString().toLowerCase() == 'read',
      'code': raw['code']?.toString() ?? '',
      'page': raw['page']?.toString() ?? '',
      'type': raw['type']?.toString() ?? '',
      'refCode': raw['refCode']?.toString() ?? raw['code']?.toString() ?? '',
    };
  }

  static String _bucketDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'earlier';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return 'earlier';
  }

  static String _formatDisplayTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(raw);
      if (dt == null) return raw;
      return DateFormat('d MMM yyyy HH:mm', 'th').format(dt);
    } catch (_) {
      return raw;
    }
  }

  static int _compareNotification(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final aRead = a['isRead'] == true;
    final bRead = b['isRead'] == true;
    if (aRead != bRead) return aRead ? 1 : -1;

    final aDt = DateTime.tryParse(a['createDate']?.toString() ?? '');
    final bDt = DateTime.tryParse(b['createDate']?.toString() ?? '');
    if (aDt != null && bDt != null) return bDt.compareTo(aDt);
    if (aDt != null) return -1;
    if (bDt != null) return 1;
    return 0;
  }

  static Future<void> markOneRead(Map<String, dynamic> item) async {
    if (item['isRead'] == true) return;
    item['isRead'] = true;
    final code = item['code']?.toString() ?? '';
    if (code.isEmpty) return;
    try {
      await postDio('${server}m/notification/markRead', {'code': code});
      await NotificationStore.instance.refresh();
    } catch (_) {}
  }

  static Future<void> markAllRead(List<Map<String, dynamic>> items) async {
    for (final item in items) {
      item['isRead'] = true;
    }
    await NotificationStore.instance.markAllRead();
    await NotificationStore.instance.refresh();
  }
}
