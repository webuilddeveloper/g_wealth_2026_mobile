import 'package:LawyerOnline/gwealth/data/mock_data.dart';
import 'package:LawyerOnline/gwealth/services/home_content_service.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/shared/api_provider.dart';
import 'package:flutter/material.dart';

class GWKnowledgeItem {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final Color color;

  const GWKnowledgeItem({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl = '',
    this.color = GW.primary,
  });
}

class GWContactItem {
  final String id;
  final String title;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color color;

  const GWContactItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.phone = '',
    this.icon = Icons.support_agent_rounded,
    this.color = GW.primary,
  });
}

class GWPollOption {
  final String code;
  final String title;
  const GWPollOption({required this.code, required this.title});
}

class GWPollQuestion {
  final String code;
  final String title;
  final List<GWPollOption> options;
  const GWPollQuestion({
    required this.code,
    required this.title,
    required this.options,
  });
}

/// ดึงเนื้อหา G-Wealth จาก API พร้อม fallback เป็น mock
class GWContentService {
  GWContentService._();
  static final instance = GWContentService._();

  Future<List<GWNewsFeedItem>> fetchNews({int limit = 30}) async {
    return GWHomeContentService.instance.fetchNews(limit: limit);
  }

  Future<List<GWKnowledgeItem>> fetchKnowledge() async {
    try {
      final result = await postDio('${knowledgeApi}read', {
        'skip': 0,
        'limit': 50,
      });
      final raw = result?['objectData'];
      if (raw is! List || raw.isEmpty) return _mockKnowledge();

      final colors = [
        GW.primary,
        GW.accentPurple,
        GW.accentBlue,
        const Color(0xFF06B6D4),
      ];
      var i = 0;
      final list = raw.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        final color = colors[i % colors.length];
        i++;
        return GWKnowledgeItem(
          id: m['code']?.toString() ?? '',
          title: m['title']?.toString() ?? '',
          summary: _stripHtml(m['description']?.toString() ?? ''),
          imageUrl: m['imageUrl']?.toString() ?? '',
          color: color,
        );
      }).where((k) => k.title.isNotEmpty).toList();

      return list.isEmpty ? _mockKnowledge() : list;
    } catch (e) {
      debugPrint('GWContentService.fetchKnowledge: $e');
      return _mockKnowledge();
    }
  }

  Future<List<GWContactItem>> fetchContacts() async {
    try {
      final result = await postDio('${contactApi}read', {
        'skip': 0,
        'limit': 50,
      });
      final raw = result?['objectData'];
      if (raw is! List || raw.isEmpty) return _mockContacts();

      final icons = [
        Icons.support_agent_rounded,
        Icons.account_balance_outlined,
        Icons.health_and_safety_outlined,
        Icons.location_city_outlined,
      ];
      final colors = [
        GW.primary,
        GW.accentPurple,
        GW.accentBlue,
        const Color(0xFF0D9488),
      ];
      var i = 0;
      final list = raw.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        final icon = icons[i % icons.length];
        final color = colors[i % colors.length];
        i++;
        return GWContactItem(
          id: m['code']?.toString() ?? '',
          title: m['title']?.toString() ?? '',
          subtitle: _stripHtml(m['description']?.toString() ?? ''),
          phone: m['phone']?.toString() ?? m['title']?.toString() ?? '',
          icon: icon,
          color: color,
        );
      }).where((c) => c.title.isNotEmpty).toList();

      return list.isEmpty ? _mockContacts() : list;
    } catch (e) {
      debugPrint('GWContentService.fetchContacts: $e');
      return _mockContacts();
    }
  }

  Future<List<GWBenefit>> fetchWelfareBenefits() async {
    try {
      final result = await postDio('${welfareApi}read', {
        'skip': 0,
        'limit': 50,
      });
      final raw = result?['objectData'];
      if (raw is! List || raw.isEmpty) return GWData.benefits;

      final list = raw.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        return GWBenefit(
          id: m['code']?.toString() ?? '',
          title: m['title']?.toString() ?? '',
          agency: m['agency']?.toString() ??
              m['category']?.toString() ??
              'หน่วยงานรัฐ',
          lifeStage: m['lifeStage']?.toString() ?? '',
          dimension: m['dimension']?.toString() ?? '',
          amount: m['amount']?.toString() ?? '',
          status: m['eligibilityStatus']?.toString() ?? 'eligible',
          description: _stripHtml(m['description']?.toString() ?? ''),
        );
      }).where((b) => b.title.isNotEmpty).toList();

      return list.isEmpty ? GWData.benefits : list;
    } catch (e) {
      debugPrint('GWContentService.fetchWelfareBenefits: $e');
      return GWData.benefits;
    }
  }

  Future<GWPollQuestion?> fetchActiveSurvey() async {
    try {
      final result = await postDio('${pollApi}all/read', {
        'skip': 0,
        'limit': 1,
      });
      final raw = result?['objectData'];
      if (raw is! List || raw.isEmpty) return null;

      final poll = Map<String, dynamic>.from(raw.first as Map);
      final questions = poll['questions'] ?? poll['questionList'] ?? [];
      if (questions is! List || questions.isEmpty) {
        // fallback: use poll title as single question with answers
        final answers = poll['answers'] ?? poll['answerList'] ?? [];
        if (answers is List && answers.isNotEmpty) {
          return GWPollQuestion(
            code: poll['code']?.toString() ?? '',
            title: poll['title']?.toString() ?? 'แบบสำรวจ',
            options: answers.whereType<Map>().map((a) {
              final m = Map<String, dynamic>.from(a);
              return GWPollOption(
                code: m['code']?.toString() ?? m['title']?.toString() ?? '',
                title: m['title']?.toString() ?? '',
              );
            }).where((o) => o.title.isNotEmpty).toList(),
          );
        }
        return null;
      }

      final q = Map<String, dynamic>.from(questions.first as Map);
      final answers = q['answers'] ?? q['answerList'] ?? poll['answers'] ?? [];
      final options = (answers is List ? answers : [])
          .whereType<Map>()
          .map((a) {
            final m = Map<String, dynamic>.from(a);
            return GWPollOption(
              code: m['code']?.toString() ?? '',
              title: m['title']?.toString() ?? '',
            );
          })
          .where((o) => o.title.isNotEmpty)
          .toList();

      if (options.isEmpty) return null;
      return GWPollQuestion(
        code: q['code']?.toString() ?? poll['code']?.toString() ?? '',
        title: q['title']?.toString() ?? poll['title']?.toString() ?? '',
        options: options,
      );
    } catch (e) {
      debugPrint('GWContentService.fetchActiveSurvey: $e');
      return null;
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

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<GWKnowledgeItem> _mockKnowledge() => const [
        GWKnowledgeItem(
          id: 'k1',
          title: 'การบริหารจัดการฐานข้อมูลอัจฉริยะ',
          summary: 'บูรณาการสิทธิสวัสดิการจากทุกกระทรวงเป็นหนึ่งเดียว',
          color: GW.primary,
        ),
        GWKnowledgeItem(
          id: 'k2',
          title: 'การวิเคราะห์ข้อมูลเชิงลึก',
          summary: 'AI สนับสนุนการตัดสินใจเชิงนโยบายและการจัดสรรงบประมาณ',
          color: GW.accentPurple,
        ),
        GWKnowledgeItem(
          id: 'k3',
          title: 'แชทบอทอัจฉริยะ',
          summary: 'ตอบคำถามและให้คำปรึกษาด้านสวัสดิการอัตโนมัติ 24 ชม.',
          color: GW.accentBlue,
        ),
        GWKnowledgeItem(
          id: 'k4',
          title: 'ระบบวิเคราะห์สิทธิเฉพาะบุคคล',
          summary: 'ตรวจสอบคุณสมบัติตามช่วงวัยอย่างถูกต้องแม่นยำ',
          color: Color(0xFF06B6D4),
        ),
      ];

  List<GWContactItem> _mockContacts() => const [
        GWContactItem(
          id: 'c1',
          title: 'สายด่วน พม. 1300',
          subtitle: 'ช่วยเหลือกลุ่มเปราะบาง 24 ชม.',
          phone: '1300',
          icon: Icons.support_agent_rounded,
          color: GW.primary,
        ),
        GWContactItem(
          id: 'c2',
          title: 'กระทรวง พม.',
          subtitle: 'ศูนย์บริการประชาชน',
          phone: '',
          icon: Icons.account_balance_outlined,
          color: GW.accentPurple,
        ),
        GWContactItem(
          id: 'c3',
          title: 'ประกันสังคม',
          subtitle: 'สอบถามสิทธิ์ประกันสังคม',
          phone: '',
          icon: Icons.health_and_safety_outlined,
          color: GW.accentBlue,
        ),
        GWContactItem(
          id: 'c4',
          title: 'อปท. ในพื้นที่',
          subtitle: 'เบี้ยยังชีพ / สวัสดิการท้องถิ่น',
          phone: '',
          icon: Icons.location_city_outlined,
          color: Color(0xFF0D9488),
        ),
      ];
}
