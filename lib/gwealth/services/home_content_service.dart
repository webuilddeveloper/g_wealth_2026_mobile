import 'package:gwealth/shared/api_provider.dart';
import 'package:flutter/foundation.dart';

/// ดึงแบนเนอร์ + ข่าวประชาสัมพันธ์จาก API เป็น List<dynamic>
class GWHomeContentService {
  GWHomeContentService._();
  static final instance = GWHomeContentService._();

  Future<List<dynamic>> fetchBanners() async {
    try {
      debugPrint('GW fetchBanners → $bannerReadApi');
      final result = await postDio(bannerReadApi, {
        'skip': 0,
        'limit': 20,
      });
      print('>>>>>>>>>>>>>>> → $result');
      final list = extractObjectData(result);
      debugPrint('GW fetchBanners: ${list.length} item(s)');
      return list;
    } catch (e) {
      debugPrint('GWHomeContentService.fetchBanners: $e');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> fetchNews({int limit = 30}) async {
    try {
      debugPrint('GW fetchNews → $newsReadApi');
      final result = await postDio(newsReadApi, {
        'skip': 0,
        'limit': limit,
      });
      if (result is Map && result['status']?.toString() == 'E') {
        debugPrint('GW fetchNews error: ${result['message']}');
        return <dynamic>[];
      }
      final list = extractObjectData(result);
      debugPrint('GW fetchNews: ${list.length} item(s)');
      return list;
    } catch (e) {
      debugPrint('GWHomeContentService.fetchNews: $e');
      return <dynamic>[];
    }
  }
}
