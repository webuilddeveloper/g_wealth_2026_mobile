import 'package:LawyerOnline/gwealth/data/mock_data.dart';
import 'package:LawyerOnline/shared/api_provider.dart';
import 'package:flutter/foundation.dart';

class GWBannerItem {
  final String code;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String linkUrl;

  const GWBannerItem({
    required this.code,
    required this.title,
    required this.subtitle,
    this.imageUrl = '',
    this.linkUrl = '',
  });
}

class GWNewsFeedItem {
  final String id;
  final String title;
  final String summary;
  final String date;
  final String category;
  final String imageUrl;
  final String linkUrl;
  final String textButton;

  const GWNewsFeedItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.category,
    this.imageUrl = '',
    this.linkUrl = '',
    this.textButton = '',
  });
}

/// ดึงแบนเนอร์ + ข่าวประชาสัมพันธ์จาก API (fallback เป็น mock เมื่อเรียก API ไม่สำเร็จ)
class GWHomeContentService {
  GWHomeContentService._();
  static final instance = GWHomeContentService._();

  Future<List<GWBannerItem>> fetchBanners() async {
    try {
      final result = await postDio(mainBannerApi, {
        'skip': 0,
        'limit': 20,
      });
      if (result == null) return _mockBanners();

      final raw = result['objectData'];
      if (raw is! List || raw.isEmpty) return _mockBanners();

      final list = raw
          .whereType<Map>()
          .map((e) {
            final m = Map<String, dynamic>.from(e);
            final title = (m['title']?.toString() ?? '').trim();
            final description =
                _stripHtml(m['description']?.toString() ?? '').trim();
            return GWBannerItem(
              code: m['code']?.toString() ?? '',
              title: title.isNotEmpty
                  ? title
                  : (description.isNotEmpty ? description : 'G-Wealth'),
              subtitle: description,
              imageUrl: (m['imageUrl']?.toString() ?? '').trim(),
              linkUrl: (m['linkUrl']?.toString() ?? '').trim(),
            );
          })
          .where((b) => b.imageUrl.isNotEmpty || b.title.isNotEmpty)
          .toList();

      return list.isEmpty ? _mockBanners() : list;
    } catch (e) {
      debugPrint('GWHomeContentService.fetchBanners: $e');
      return _mockBanners();
    }
  }

  Future<List<GWNewsFeedItem>> fetchNews({int limit = 30}) async {
    try {
      // ใช้ v2: status=A + lookup หมวดหมู่ ไม่กรอง organization เข้ม
      final result = await postDio('${newsV2Api}read', {
        'skip': 0,
        'limit': limit,
        'language': 'th',
      });
      if (result == null) {
        debugPrint('GWHomeContentService.fetchNews: null response');
        return _mockNews();
      }
      if (result['status']?.toString() == 'E') {
        debugPrint(
            'GWHomeContentService.fetchNews: ${result['message']}');
        return _mockNews();
      }

      final raw = result['objectData'];
      if (raw is! List) return const [];

      final list = raw.whereType<Map>().map(_mapNews).where((n) {
        return n.title.isNotEmpty;
      }).toList();

      // สำเร็จแล้วแต่ยังไม่มีข่าวที่เผยแพร่ (status A) → ว่าง ไม่ใช้ mock
      return list;
    } catch (e) {
      debugPrint('GWHomeContentService.fetchNews: $e');
      return _mockNews();
    }
  }

  static GWNewsFeedItem _mapNews(Map raw) {
    final m = Map<String, dynamic>.from(raw);
    var category = 'ข่าวประชาสัมพันธ์';
    final categoryList = m['categoryList'];
    if (categoryList is List && categoryList.isNotEmpty) {
      final first = categoryList.first;
      if (first is Map) {
        final t = first['title']?.toString().trim() ?? '';
        if (t.isNotEmpty) category = t;
      }
    } else {
      final c = m['category']?.toString().trim() ?? '';
      // ถ้าเป็นรหัสยาว ไม่โชว์เป็นชื่อหมวด
      if (c.isNotEmpty && c.length < 40 && !c.contains('-')) {
        category = c;
      }
    }

    return GWNewsFeedItem(
      id: m['code']?.toString() ?? '',
      title: (m['title']?.toString() ?? '').trim(),
      summary: _stripHtml(
        m['description']?.toString() ?? m['detail']?.toString() ?? '',
      ),
      date: (m['createDate']?.toString() ??
              m['createDateTH']?.toString() ??
              m['updateDate']?.toString() ??
              '')
          .trim(),
      category: category,
      imageUrl: (m['imageUrl']?.toString() ?? '').trim(),
      linkUrl: (m['linkUrl']?.toString() ?? '').trim(),
      textButton: (m['textButton']?.toString() ?? '').trim(),
    );
  }

  List<GWBannerItem> _mockBanners() {
    return GWData.banners
        .map(
          (b) => GWBannerItem(
            code: b['code']?.toString() ?? '',
            title: b['title']?.toString() ?? '',
            subtitle: b['subtitle']?.toString() ?? '',
          ),
        )
        .toList();
  }

  List<GWNewsFeedItem> _mockNews() {
    return GWData.news
        .map(
          (n) => GWNewsFeedItem(
            id: n.id,
            title: n.title,
            summary: n.summary,
            date: n.date,
            category: n.category,
          ),
        )
        .toList();
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
