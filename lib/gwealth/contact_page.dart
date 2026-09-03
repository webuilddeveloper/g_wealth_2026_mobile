import 'package:LawyerOnline/gwealth/services/gw_content_service.dart';
import 'package:LawyerOnline/gwealth/services/gw_map.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GWContactPage extends StatefulWidget {
  const GWContactPage({super.key});

  @override
  State<GWContactPage> createState() => _GWContactPageState();
}

class _GWContactPageState extends State<GWContactPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  static const _icons = [
    Icons.support_agent_rounded,
    Icons.account_balance_outlined,
    Icons.health_and_safety_outlined,
    Icons.location_city_outlined,
  ];
  static const _colors = [
    GW.primary,
    GW.accentPurple,
    GW.accentBlue,
    Color(0xFF0D9488),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await GWContentService.instance.fetchContacts();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'ติดต่อหน่วยงาน'),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: GW.primary, strokeWidth: 2.4),
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
                      gradient: GW.headerGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.headset_mic_outlined,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ช่องทางช่วยเหลือ',
                                style: GW.text(
                                  size: 16,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'เลือกหน่วยงานที่ต้องการติดต่อ',
                                style: GW.text(
                                  size: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('ยังไม่มีข้อมูลติดต่อ',
                            style: GW.text(size: 14, color: GW.inkMuted)),
                      ),
                    )
                  else
                    ...List.generate(_items.length, (i) {
                      final c = _items[i];
                      final color = _colors[i % _colors.length];
                      final icon = _icons[i % _icons.length];
                      final title = gwStr(c, 'title');
                      final subtitle = gwHtml(c, 'description');
                      final phone = gwStr(c, 'phone', gwStr(c, 'title'));
                      final hasPhone =
                          phone.replaceAll(RegExp(r'[^0-9+]'), '').isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: hasPhone ? () => _call(phone) : null,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(icon, color: color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: GW.text(
                                                size: 15,
                                                weight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle.isNotEmpty
                                              ? subtitle
                                              : (hasPhone
                                                  ? phone
                                                  : 'ติดต่อหน่วยงาน'),
                                          style: GW.text(
                                              size: 12, color: GW.inkMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasPhone)
                                    Icon(Icons.phone_rounded,
                                        color: color, size: 22),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
