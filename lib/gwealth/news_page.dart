import 'package:LawyerOnline/gwealth/services/gw_content_service.dart';
import 'package:LawyerOnline/gwealth/services/home_content_service.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GWNewsPage extends StatefulWidget {
  const GWNewsPage({super.key, this.highlightId});

  final String? highlightId;

  @override
  State<GWNewsPage> createState() => _GWNewsPageState();
}

class _GWNewsPageState extends State<GWNewsPage> {
  List<GWNewsFeedItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await GWContentService.instance.fetchNews(limit: 50);
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  void _openDetail(GWNewsFeedItem n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final h = MediaQuery.of(ctx).size.height * 0.88;
        return SizedBox(
          height: h,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: GW.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    if (n.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: n.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: GW.primarySoft,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported_outlined,
                                  color: GW.primary),
                            ),
                          ),
                        ),
                      ),
                    if (n.imageUrl.isNotEmpty) const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: GW.primarySoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            n.category,
                            style: GW.text(
                              size: 11,
                              weight: FontWeight.w600,
                              color: GW.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (n.date.isNotEmpty)
                          Text(n.date,
                              style: GW.text(size: 12, color: GW.inkLight)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(n.title,
                        style: GW.text(size: 18, weight: FontWeight.w700)),
                    if (n.summary.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        n.summary,
                        style: GW.text(
                          size: 14,
                          color: GW.inkMuted,
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (n.linkUrl.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: GW.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final uri = Uri.tryParse(n.linkUrl);
                            if (uri == null) return;
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          },
                          child: Text(
                            n.textButton.isNotEmpty
                                ? n.textButton
                                : 'เปิดแหล่งอ้างอิง',
                            style: GW.text(
                              size: 14,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'ข่าวประชาสัมพันธ์'),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: GW.primary, strokeWidth: 2.4),
            )
          : RefreshIndicator(
              color: GW.primary,
              onRefresh: _load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _items.isEmpty ? 1 : _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  if (_items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(
                        child: Text(
                          'ยังไม่มีข่าวประชาสัมพันธ์ที่เผยแพร่',
                          style: GW.text(size: 14, color: GW.inkMuted),
                        ),
                      ),
                    );
                  }
                  final n = _items[i];
                  final highlight = n.id == widget.highlightId;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openDetail(n),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: highlight
                                ? GW.primary
                                : GW.border.withValues(alpha: 0.85),
                            width: highlight ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (n.imageUrl.isNotEmpty)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  imageUrl: n.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: GW.primarySoft,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: GW.primarySoft,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.campaign_outlined,
                                      color: GW.primary,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: GW.primarySoft,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          n.category,
                                          style: GW.text(
                                            size: 11,
                                            weight: FontWeight.w600,
                                            color: GW.primary,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (n.date.isNotEmpty)
                                        Text(
                                          n.date,
                                          style: GW.text(
                                              size: 12, color: GW.inkLight),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    n.title,
                                    style: GW.text(
                                        size: 16, weight: FontWeight.w700),
                                  ),
                                  if (n.summary.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      n.summary,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
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
                },
              ),
            ),
    );
  }
}
