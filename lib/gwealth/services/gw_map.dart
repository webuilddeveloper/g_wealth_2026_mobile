Map<String, dynamic> gwMap(dynamic item) {
  if (item is Map<String, dynamic>) return item;
  if (item is Map) return Map<String, dynamic>.from(item);
  return <String, dynamic>{};
}

String gwStr(dynamic item, String key, [String fallback = '']) {
  final v = gwMap(item)[key];
  if (v == null) return fallback;
  final s = v.toString().trim();
  return s.isEmpty ? fallback : s;
}

String gwHtml(dynamic item, String key, [String fallback = '']) {
  return gwStr(item, key, fallback)
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String gwCategory(dynamic item, [String fallback = '']) {
  final list = gwMap(item)['categoryList'];
  if (list is List && list.isNotEmpty) {
    final title = gwStr(list.first, 'title');
    if (title.isNotEmpty) return title;
  }
  final category = gwStr(item, 'category');
  if (category.isEmpty) return fallback;
  // ฟิลด์ category จาก API มักเป็นรหัส — ไม่โชว์รหัสเป็นชื่อประเภท
  if (_looksLikeCategoryCode(category)) return fallback;
  return category;
}

bool _looksLikeCategoryCode(String value) {
  final s = value.trim();
  if (s.isEmpty) return false;
  // มีตัวอักษรไทย = ชื่อประเภทแล้ว
  if (RegExp(r'[ก-๙]').hasMatch(s)) return false;
  if (s.contains(' ')) return false;
  // รหัสมักยาวและเป็นเลข/อังกฤษ
  return s.length >= 8 || RegExp(r'^[0-9a-fA-F-]+$').hasMatch(s);
}

/// วันที่ข่าว/เนื้อหา เป็น วว/ดด/ปปปป (พ.ศ.)
String gwDateBe(dynamic item, [String fallback = '']) {
  final raw = gwStr(item, 'createDate', gwStr(item, 'updateDate'));
  return formatBuddhistDate(raw, fallback: fallback);
}

String formatBuddhistDate(String raw, {String fallback = ''}) {
  final s = raw.trim();
  if (s.isEmpty) return fallback;
  final dt = parseGwDate(s);
  if (dt == null) return s;
  final year = dt.year > 2400 ? dt.year : dt.year + 543;
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m/$year';
}

DateTime? parseGwDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;

  final iso = DateTime.tryParse(s);
  if (iso != null) return iso.toLocal();

  final msMatch = RegExp(r'/Date\((\d+)').firstMatch(s);
  if (msMatch != null) {
    return DateTime.fromMillisecondsSinceEpoch(
      int.parse(msMatch.group(1)!),
    ).toLocal();
  }

  if (RegExp(r'^\d{8,}').hasMatch(s) &&
      !s.contains('/') &&
      !s.contains('-') &&
      !s.contains('.')) {
    final y = int.tryParse(s.substring(0, 4));
    final mo = int.tryParse(s.substring(4, 6));
    final d = int.tryParse(s.substring(6, 8));
    if (y != null && mo != null && d != null && mo >= 1 && mo <= 12) {
      return DateTime(y > 2400 ? y - 543 : y, mo, d);
    }
  }

  final slash = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})').firstMatch(s);
  if (slash != null) {
    final d = int.parse(slash.group(1)!);
    final mo = int.parse(slash.group(2)!);
    var y = int.parse(slash.group(3)!);
    if (y > 2400) y -= 543;
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      return DateTime(y, mo, d);
    }
  }

  return null;
}
