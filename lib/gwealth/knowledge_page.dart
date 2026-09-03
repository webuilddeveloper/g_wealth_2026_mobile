import 'package:gwealth/gwealth/services/gw_content_service.dart';
import 'package:gwealth/gwealth/services/gw_map.dart';
import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';

class GWKnowledgePage extends StatefulWidget {
  const GWKnowledgePage({super.key});

  @override
  State<GWKnowledgePage> createState() => _GWKnowledgePageState();
}

class _GWKnowledgePageState extends State<GWKnowledgePage> {
  List<dynamic> _items = [];
  bool _loading = true;

  static const _colors = [
    GW.primary,
    GW.accentPurple,
    GW.accentBlue,
    Color(0xFF06B6D4),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await GWContentService.instance.fetchKnowledge();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'คลังความรู้'),
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
                  Text(
                    'ข้อมูลที่เป็นประโยชน์เพื่อยกระดับคุณภาพชีวิต',
                    style: GW.text(size: 13, color: GW.inkMuted, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text('ยังไม่มีคลังความรู้',
                            style: GW.text(size: 14, color: GW.inkMuted)),
                      ),
                    )
                  else
                    ...List.generate(_items.length, (i) {
                      final e = _items[i];
                      final color = _colors[i % _colors.length];
                      final title = gwStr(e, 'title');
                      final summary = gwHtml(e, 'description');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.menu_book_outlined,
                                      color: color),
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
                                      if (summary.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          summary,
                                          style: GW.text(
                                            size: 13,
                                            color: GW.inkMuted,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
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
