import 'package:gwealth/gwealth/data/mock_data.dart';
import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/gwealth/widgets/gw_app_bar.dart';
import 'package:gwealth/gwealth/widgets/home_sections.dart';
import 'package:flutter/material.dart';

/// ระบบวิเคราะห์สิทธิเฉพาะบุคคล + E-KYC mock
class GWRightsPage extends StatefulWidget {
  const GWRightsPage({super.key, this.initialTab = 1});

  final int initialTab;

  @override
  State<GWRightsPage> createState() => _GWRightsPageState();
}

class _GWRightsPageState extends State<GWRightsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _analyzing = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    final ok = await gwEnsureLogin(context);
    if (!ok || !mounted) return;
    setState(() {
      _analyzing = true;
      _done = false;
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _analyzing = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'ตรวจสอบสิทธิ์'),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              labelColor: GW.primary,
              unselectedLabelColor: GW.inkMuted,
              indicatorColor: GW.primary,
              indicatorWeight: 2.5,
              labelStyle: GW.text(size: 14, weight: FontWeight.w700),
              unselectedLabelStyle: GW.text(size: 14, weight: FontWeight.w500),
              tabs: const [
                Tab(text: 'ยืนยันตัวตน E-KYC'),
                Tab(text: 'วิเคราะห์สิทธิ์ AI'),
              ],
            ),
          ),
          Container(height: 1, color: GW.border.withValues(alpha: 0.7)),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _EkycTab(onDone: () => _tabs.animateTo(1)),
                _AnalysisTab(
                  analyzing: _analyzing,
                  done: _done,
                  onAnalyze: _runAnalysis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EkycTab extends StatelessWidget {
  final VoidCallback onDone;
  const _EkycTab({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: GW.card(),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: GW.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.face_retouching_natural,
                    size: 44, color: GW.primary),
              ),
              const SizedBox(height: 14),
              Text('ยืนยันตัวตนด้วย E-KYC',
                  style: GW.text(size: 17, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                'เชื่อมโยงทะเบียนกลางเพื่อตรวจสอบคุณสมบัติสวัสดิการแบบ Self-Service ตลอด 24 ชั่วโมง',
                textAlign: TextAlign.center,
                style: GW.text(size: 13, color: GW.inkMuted),
              ),
              const SizedBox(height: 18),
              _Step(n: '1', title: 'สแกนบัตรประชาชน / ThaiID'),
              _Step(n: '2', title: 'ถ่ายภาพใบหน้าเปรียบเทียบ'),
              _Step(n: '3', title: 'ยินยอม PDPA และเชื่อม Government Hub'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    final ok = await gwEnsureLogin(context);
                    if (!ok || !context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('จำลองยืนยันตัวตนสำเร็จ',
                            style: GW.text(size: 13, color: Colors.white)),
                        backgroundColor: GW.success,
                      ),
                    );
                    onDone();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: GW.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('เริ่มยืนยันตัวตน',
                      style: GW.text(
                          size: 15,
                          weight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String n;
  final String title;
  const _Step({required this.n, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: GW.primary,
            child: Text(n,
                style: GW.text(
                    size: 12, weight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GW.text(size: 14))),
        ],
      ),
    );
  }
}

class _AnalysisTab extends StatelessWidget {
  final bool analyzing;
  final bool done;
  final VoidCallback onAnalyze;

  const _AnalysisTab({
    required this.analyzing,
    required this.done,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final eligible =
        GWData.benefits.where((b) => b.status == 'eligible' || b.status == 'hidden');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFE84090)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Data Analysis',
                  style: GW.text(
                      size: 12,
                      weight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9))),
              const SizedBox(height: 6),
              Text('AI ประมวลผลจาก Big Data',
                  style: GW.text(
                      size: 18, weight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'ตรวจสอบคุณสมบัติ ทรัพย์สิน และสถานะ เพื่อจับคู่สิทธิ์แบบเฉพาะบุคคล',
                style: GW.text(size: 13, color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: analyzing ? null : onAnalyze,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: GW.primaryDark,
                    disabledBackgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: analyzing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: GW.primary,
                          ),
                        )
                      : Text('เริ่มวิเคราะห์สิทธิ์',
                          style: GW.text(
                              size: 14,
                              weight: FontWeight.w700,
                              color: GW.primaryDark)),
                ),
              ),
            ],
          ),
        ),
        if (done) ...[
          const SizedBox(height: 16),
          Text('ผลการวิเคราะห์',
              style: GW.text(size: 16, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...eligible.map((b) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: GW.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: GW.success, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(b.title,
                            style:
                                GW.text(size: 14, weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(b.description,
                      style: GW.text(size: 13, color: GW.inkMuted)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ส่งคำขอยืนยันสิทธิ์แล้ว',
                                style:
                                    GW.text(size: 13, color: Colors.white)),
                            backgroundColor: GW.primary,
                          ),
                        );
                      },
                      child: Text('ยืนยันรับสิทธิ์',
                          style: GW.text(
                              size: 13,
                              weight: FontWeight.w700,
                              color: GW.primary)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ] else if (!analyzing) ...[
          const SizedBox(height: 24),
          Icon(Icons.psychology_outlined, size: 56, color: GW.primaryMute),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'กดเริ่มวิเคราะห์เพื่อค้นหาสิทธิ์เชิงรุก',
              style: GW.text(size: 13, color: GW.inkMuted),
            ),
          ),
        ],
      ],
    );
  }
}
