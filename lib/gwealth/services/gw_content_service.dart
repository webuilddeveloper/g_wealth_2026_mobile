import 'package:LawyerOnline/gwealth/services/home_content_service.dart';
import 'package:LawyerOnline/shared/api_provider.dart';
import 'package:flutter/foundation.dart';

/// ดึงเนื้อหา G-Wealth จาก API เป็น List<dynamic>
class GWContentService {
  GWContentService._();
  static final instance = GWContentService._();

  Future<List<dynamic>> fetchNews({int limit = 30}) async {
    return GWHomeContentService.instance.fetchNews(limit: limit);
  }

  Future<List<dynamic>> fetchNewsGallery(String newsCode) async {
    final code = newsCode.trim();
    if (code.isEmpty) return <dynamic>[];
    try {
      final result = await postDio(newsGalleryApi, {
        'code': code,
        'skip': 0,
        'limit': 50,
      });
      return extractObjectData(result);
    } catch (e) {
      debugPrint('GWContentService.fetchNewsGallery: $e');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> fetchKnowledge() async {
    try {
      final result = await postDio('${knowledgeApi}read', {
        'skip': 0,
        'limit': 50,
      });
      return extractObjectData(result);
    } catch (e) {
      debugPrint('GWContentService.fetchKnowledge: $e');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> fetchContacts() async {
    try {
      final result = await postDio('${contactApi}read', {
        'skip': 0,
        'limit': 50,
      });
      return extractObjectData(result);
    } catch (e) {
      debugPrint('GWContentService.fetchContacts: $e');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> fetchWelfareBenefits() async {
    try {
      final result = await postDio('${welfareApi}read', {
        'skip': 0,
        'limit': 50,
      });
      return extractObjectData(result);
    } catch (e) {
      debugPrint('GWContentService.fetchWelfareBenefits: $e');
      return <dynamic>[];
    }
  }

  Future<List<dynamic>> fetchActiveSurvey() async {
    try {
      final result = await postDio('${pollApi}all/read', {
        'skip': 0,
        'limit': 1,
      });
      return extractObjectData(result);
    } catch (e) {
      debugPrint('GWContentService.fetchActiveSurvey: $e');
      return <dynamic>[];
    }
  }

  Future<bool> submitSurveyReply({
    required String pollCode,
    required String questionCode,
    required String answerCode,
    required String answerTitle,
  }) async {
    try {
      final result = await postDio('${pollApi}reply/create', {
        'reference': pollCode,
        'question': questionCode,
        'answer': answerCode,
        'title': answerTitle,
        'description': answerTitle,
      });
      return result?['status']?.toString() == 'S';
    } catch (e) {
      debugPrint('GWContentService.submitSurveyReply: $e');
      return false;
    }
  }
}
