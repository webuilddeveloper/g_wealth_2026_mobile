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
    if (code.isEmpty) return _mockNotifications();

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

      if (list.isEmpty) return _mockNotifications();

      final unread = list.where((n) => n['isRead'] != true).length;
      NotificationStore.instance.setUnread(unread);

      return list;
    } catch (_) {
      return _mockNotifications();
    }
  }

  static List<Map<String, dynamic>> _mockNotifications() {
    final now = DateTime.now();
    final list = [
      {
        'title': 'ยืนยันการลงทะเบียนสำเร็จ',
        'description':
            'บัญชี G-Wealth ของคุณพร้อมใช้งานแล้ว เริ่มตรวจสอบสิทธิ์และบริการที่เหมาะกับคุณได้ทันที',
        'createDate':
            now.subtract(const Duration(minutes: 18)).toIso8601String(),
        'isRead': false,
        'type': 'system',
      },
      {
        'title': 'พบสิทธิ์ใหม่สำหรับคุณ',
        'description':
            'คุณอาจมีสิทธิ์รับเงินอุดหนุนค่าครองชีพ กรุณาตรวจสอบรายละเอียดและเงื่อนไขการรับสิทธิ์',
        'createDate': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'isRead': false,
        'type': 'benefit',
      },
      {
        'title': 'แจ้งเตือนการนัดหมาย',
        'description':
            'คุณมีนัดหมายให้คำปรึกษาในวันพรุ่งนี้ เวลา 10:30 น. กรุณาเตรียมเอกสารให้พร้อม',
        'createDate': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'isRead': false,
        'type': 'booking',
      },
      {
        'title': 'อัปเดตข้อมูลส่วนตัวสำเร็จ',
        'description': 'ระบบบันทึกข้อมูลส่วนตัวล่าสุดของคุณเรียบร้อยแล้ว',
        'createDate':
            now.subtract(const Duration(days: 1, hours: 1)).toIso8601String(),
        'isRead': true,
        'type': 'system',
      },
      {
        'title': 'ข่าวสารจาก G-Wealth',
        'description':
            'ติดตามมาตรการช่วยเหลือและข่าวสารทางการเงินใหม่ ๆ ได้จากหน้าแรกของแอป',
        'createDate': now.subtract(const Duration(days: 3)).toIso8601String(),
        'isRead': true,
        'type': 'news',
      },
    ].map(normalize).toList();

    list.sort(_compareNotification);
    NotificationStore.instance.setUnread(
      list.where((notification) => notification['isRead'] != true).length,
    );
    return list;
  }

  static Map<String, dynamic> normalize(Map<String, dynamic> raw) {
    final title = raw['title']?.toString() ?? '';
    final body = raw['description']?.toString() ??
        raw['body']?.toString() ??
        raw['detail']?.toString() ??
        '';
    final createDate =
        raw['createDate']?.toString() ?? raw['createdDate']?.toString() ?? '';

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
