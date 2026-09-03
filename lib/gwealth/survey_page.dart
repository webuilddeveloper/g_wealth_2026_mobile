import 'package:LawyerOnline/gwealth/services/gw_content_service.dart';
import 'package:LawyerOnline/gwealth/services/gw_map.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';

class GWSurveyPage extends StatefulWidget {
  const GWSurveyPage({super.key});

  @override
  State<GWSurveyPage> createState() => _GWSurveyPageState();
}

class _GWSurveyPageState extends State<GWSurveyPage> {
  List<dynamic> _polls = [];
  String? _selectedCode;
  bool _loading = true;
  bool _submitting = false;

  static const _fallback = [
    ('สุขภาพและการรักษา', Icons.local_hospital_outlined),
    ('การศึกษาของบุตร', Icons.school_outlined),
    ('อาชีพและรายได้', Icons.work_outline_rounded),
    ('ที่อยู่อาศัย', Icons.home_outlined),
    ('การดูแลผู้สูงอายุ', Icons.elderly_outlined),
  ];

  dynamic get _poll => _polls.isEmpty ? null : _polls.first;

  List<dynamic> get _options {
    final poll = _poll;
    if (poll == null) return [];
    final questions = gwMap(poll)['questions'] ?? gwMap(poll)['questionList'];
    if (questions is List && questions.isNotEmpty) {
      final q = gwMap(questions.first);
      final answers = q['answers'] ?? q['answerList'] ?? [];
      if (answers is List) return answers;
    }
    final answers = gwMap(poll)['answers'] ?? gwMap(poll)['answerList'];
    if (answers is List) return answers;
    return [];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await GWContentService.instance.fetchActiveSurvey();
    if (!mounted) return;
    setState(() {
      _polls = list;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_selectedCode == null) return;
    setState(() => _submitting = true);

    var ok = false;
    if (_poll != null && _options.isNotEmpty) {
      final opt = _options.firstWhere(
        (o) => gwStr(o, 'code') == _selectedCode,
        orElse: () => {'code': _selectedCode, 'title': _selectedCode},
      );
      ok = await GWContentService.instance.submitSurveyReply(
        pollCode: gwStr(_poll, 'code'),
        questionCode: gwStr(_poll, 'code'),
        answerCode: gwStr(opt, 'code'),
        answerTitle: gwStr(opt, 'title'),
      );
    } else {
      ok = true;
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'บันทึกคำตอบเรียบร้อยแล้ว' : 'บันทึกไม่สำเร็จ กรุณาลองใหม่',
          style: GW.text(size: 14, color: Colors.white),
        ),
        backgroundColor: ok ? GW.primary : GW.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _poll == null
        ? 'คุณต้องการความช่วยเหลือด้านใดมากที่สุด?'
        : gwStr(_poll, 'title', 'คุณต้องการความช่วยเหลือด้านใดมากที่สุด?');
    final usingApi = _options.isNotEmpty;

    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'สำรวจความต้องการ'),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: GW.primary, strokeWidth: 2.4),
            )
          : RefreshIndicator(
              color: GW.primary,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GW.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GW.text(size: 16, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          usingApi
                              ? 'เลือกคำตอบจากแบบสำรวจในระบบ'
                              : 'เลือก 1 ข้อ เพื่อให้ระบบแนะนำสวัสดิการที่เหมาะสม',
                          style: GW.text(size: 13, color: GW.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (usingApi)
                    ..._options.map((o) {
                      final code = gwStr(o, 'code', gwStr(o, 'title'));
                      final selected = _selectedCode == code;
                      return _OptionTile(
                        label: gwStr(o, 'title'),
                        icon: Icons.radio_button_checked,
                        selected: selected,
                        onTap: () => setState(() => _selectedCode = code),
                      );
                    })
                  else
                    ..._fallback.map((o) {
                      final selected = _selectedCode == o.$1;
                      return _OptionTile(
                        label: o.$1,
                        icon: o.$2,
                        selected: selected,
                        onTap: () => setState(() => _selectedCode = o.$1),
                      );
                    }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _selectedCode == null || _submitting
                          ? null
                          : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: GW.primary,
                        disabledBackgroundColor: GW.primaryMute,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'ส่งคำตอบ',
                              style: GW.text(
                                size: 15,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? GW.primary : GW.border,
                width: selected ? 1.6 : 1,
              ),
              color: selected
                  ? GW.primarySoft.withValues(alpha: 0.45)
                  : Colors.white,
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? GW.primary : GW.inkMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GW.text(
                      size: 14,
                      weight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: selected ? GW.primary : GW.inkLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
