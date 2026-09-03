import 'package:LawyerOnline/gwealth/data/mock_data.dart';
import 'package:LawyerOnline/gwealth/rights_page.dart';
import 'package:LawyerOnline/gwealth/services/gw_content_service.dart';
import 'package:LawyerOnline/gwealth/services/gw_map.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';

/// สวัสดิการของฉัน — เส้นทางสิทธิ์แห่งชีวิต + สิทธิ์จาก API
class GWWelfarePage extends StatefulWidget {
  const GWWelfarePage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<GWWelfarePage> createState() => _GWWelfarePageState();
}

class _GWWelfarePageState extends State<GWWelfarePage> {
  List<dynamic> _benefits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await GWContentService.instance.fetchWelfareBenefits();
    if (!mounted) return;
    setState(() {
      _benefits = list;
      _loading = false;
    });
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      color: GW.primary,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _HeroCard(
            onCheck: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GWRightsPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('เส้นทางสิทธิ์แห่งชีวิต',
              style: GW.text(size: 17, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('ดูแลครอบคลุม ค้นพบสิทธิ์ที่ซ่อนอยู่',
              style: GW.text(size: 13, color: GW.inkMuted)),
          const SizedBox(height: 14),
          ...GWData.lifeStages.map((s) => _LifeStageCard(stage: s)),
          const SizedBox(height: 20),
          Text('5 มิติสิทธิ์พื้นฐาน',
              style: GW.text(size: 17, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('เสาหลักแห่งคุณภาพชีวิต',
              style: GW.text(size: 13, color: GW.inkMuted)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: GWData.dimensions.map((d) {
              return SizedBox(
                width: (MediaQuery.sizeOf(context).width - 42) / 2,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: GW.card(radius: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: d.$3.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(d.$2, color: d.$3, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          d.$1,
                          style: GW.text(size: 14, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('สิทธิ์ของฉัน',
              style: GW.text(size: 17, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                    color: GW.primary, strokeWidth: 2.4),
              ),
            )
          else if (_benefits.isEmpty)
            Text('ยังไม่มีข้อมูลสวัสดิการ',
                style: GW.text(size: 13, color: GW.inkMuted))
          else
            ..._benefits.map((b) => _BenefitTile(benefit: b)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: GW.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text('สวัสดิการของฉัน',
                    style: GW.text(size: 22, weight: FontWeight.w700)),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'สวัสดิการของฉัน'),
      body: body,
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onCheck;
  const _HeroCard({required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: GW.headerGradient,
        boxShadow: [
          BoxShadow(
            color: GW.primary.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Personalized Benefit Analysis',
                style: GW.text(
                  size: 12,
                  weight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'AI วิเคราะห์สิทธิ์เฉพาะบุคคล',
            style: GW.text(size: 18, weight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'จับคู่สวัสดิการแบบ 1-on-1 เพื่อไม่ให้สิทธิ์ตกหล่น',
            style: GW.text(size: 13, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onCheck,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: GW.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('ตรวจสอบสิทธิ์ตอนนี้',
                style: GW.text(
                    size: 14, weight: FontWeight.w700, color: GW.primaryDark)),
          ),
        ],
      ),
    );
  }
}

class _LifeStageCard extends StatelessWidget {
  final GWLifeStage stage;
  const _LifeStageCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: GW.card(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: stage.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stage.icon, color: stage.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stage.title,
                    style: GW.text(size: 15, weight: FontWeight.w700)),
                Text(stage.subtitle,
                    style: GW.text(size: 12, color: GW.inkMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: stage.sampleRights
                      .map(
                        (r) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: stage.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(r,
                              style: GW.text(
                                  size: 11,
                                  weight: FontWeight.w500,
                                  color: stage.color)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final dynamic benefit;
  const _BenefitTile({required this.benefit});

  String get _status =>
      gwStr(benefit, 'eligibilityStatus', gwStr(benefit, 'status', 'eligible'));

  Color get _statusColor {
    switch (_status) {
      case 'eligible':
      case 'A':
        return GW.success;
      case 'claimed':
        return GW.accentBlue;
      case 'pending':
      case 'P':
        return GW.warning;
      case 'hidden':
        return GW.accentPurple;
      default:
        return GW.inkMuted;
    }
  }

  String get _statusLabel {
    switch (_status) {
      case 'eligible':
      case 'A':
        return 'มีสิทธิ์';
      case 'claimed':
        return 'ใช้สิทธิ์แล้ว';
      case 'pending':
      case 'P':
        return 'รอตรวจสอบ';
      case 'hidden':
        return 'สิทธิ์ที่ซ่อนอยู่';
      default:
        return _status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: GW.card(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(gwStr(benefit, 'title'),
                    style: GW.text(size: 14, weight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel,
                    style: GW.text(
                        size: 11,
                        weight: FontWeight.w600,
                        color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            gwStr(benefit, 'agency', gwStr(benefit, 'category', 'หน่วยงานรัฐ')),
            style: GW.text(size: 12, color: GW.inkMuted),
          ),
          const SizedBox(height: 6),
          Text(gwHtml(benefit, 'description'),
              style: GW.text(size: 13, color: GW.ink)),
          const SizedBox(height: 8),
          Text(gwStr(benefit, 'amount'),
              style: GW.text(
                  size: 13, weight: FontWeight.w700, color: GW.primary)),
        ],
      ),
    );
  }
}
