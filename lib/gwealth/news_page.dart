import 'package:gwealth/component/gallery_view.dart';
import 'package:gwealth/gwealth/services/gw_content_service.dart';
import 'package:gwealth/gwealth/services/gw_map.dart';
import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/gwealth/widgets/gw_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GWNewsPage extends StatefulWidget {
  const GWNewsPage({super.key});

  @override
  State<GWNewsPage> createState() => _GWNewsPageState();
}

class _GWNewsPageState extends State<GWNewsPage> {
  List<dynamic> _items = [];
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

  void _openDetail(dynamic n) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GWNewsDetailPage(item: n)),
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
                  final imageUrl = gwStr(n, 'imageUrl');
                  final title = gwStr(n, 'title');
                  final summary = gwHtml(n, 'description');
                  final date = gwDateBe(n);
                  final category = gwCategory(n, 'ข่าวประชาสัมพันธ์');
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
                            color: GW.border.withValues(alpha: 0.85),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl.isNotEmpty)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: GW.primarySoft),
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
                                          category,
                                          style: GW.text(
                                            size: 11,
                                            weight: FontWeight.w600,
                                            color: GW.primary,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (date.isNotEmpty)
                                        Text(
                                          date,
                                          style: GW.text(
                                              size: 12, color: GW.inkLight),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    title,
                                    style: GW.text(
                                        size: 16, weight: FontWeight.w700),
                                  ),
                                  if (summary.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      summary,
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

class GWNewsDetailPage extends StatefulWidget {
  const GWNewsDetailPage({super.key, required this.item});

  final dynamic item;

  @override
  State<GWNewsDetailPage> createState() => _GWNewsDetailPageState();
}

class _GWNewsDetailPageState extends State<GWNewsDetailPage> {
  List<String> _extraImages = [];
  bool _loadingGallery = true;

  String get _mainImage => gwStr(widget.item, 'imageUrl');

  List<String> get _allImages {
    final urls = <String>[];
    void add(String url) {
      final u = url.trim();
      if (u.isNotEmpty && !urls.contains(u)) urls.add(u);
    }

    add(_mainImage);
    for (final url in _extraImages) {
      add(url);
    }
    return urls;
  }

  /// รูปเล็กใต้รูปหลัก — ไม่ซ้ำกับรูปที่โชว์เป็นฮีโร่
  List<String> get _thumbImages {
    final all = _allImages;
    if (all.length <= 1) return const [];
    return all.sublist(1);
  }

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final code = gwStr(widget.item, 'code');
    final list = await GWContentService.instance.fetchNewsGallery(code);
    if (!mounted) return;
    final main = _mainImage;
    final extras = <String>[];
    for (final g in list) {
      final url = gwStr(g, 'imageUrl');
      if (url.isEmpty || url == main || extras.contains(url)) continue;
      extras.add(url);
    }
    setState(() {
      _extraImages = extras;
      _loadingGallery = false;
    });
  }

  void _openViewer(int index) {
    final images = _allImages;
    if (images.isEmpty) return;
    final safeIndex = index.clamp(0, images.length - 1);
    final providers =
        images.map((u) => CachedNetworkImageProvider(u)).toList();
    showCupertinoDialog(
      context: context,
      builder: (_) => ImageViewer(
        initialIndex: safeIndex,
        imageProviders: providers,
      ),
    );
  }

  Widget _buildMainImage(String imageUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openViewer(0),
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: GW.primarySoft),
                  errorWidget: (_, __, ___) => Container(
                    color: GW.primarySoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: GW.primary,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'แตะเพื่อขยาย',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraGallery() {
    if (_loadingGallery) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 72,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: GW.primary,
                strokeWidth: 2.2,
              ),
            ),
          ),
        ),
      );
    }
    if (_thumbImages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รูปภาพเพิ่มเติม',
            style: GW.text(size: 13, weight: FontWeight.w600, color: GW.inkMuted),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _thumbImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final url = _thumbImages[i];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openViewer(i + 1),
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GW.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: GW.primarySoft),
                          errorWidget: (_, __, ___) => Container(
                            color: GW.primarySoft,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: GW.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _mainImage;
    final title = gwStr(widget.item, 'title');
    final summary = gwHtml(widget.item, 'description');
    final date = gwDateBe(widget.item);
    final category = gwCategory(widget.item, 'ข่าวประชาสัมพันธ์');
    final linkUrl = gwStr(widget.item, 'linkUrl');
    final textButton = gwStr(widget.item, 'textButton', 'เปิดแหล่งอ้างอิง');
    final hasHero = imageUrl.isNotEmpty || _allImages.isNotEmpty;
    final heroUrl = imageUrl.isNotEmpty
        ? imageUrl
        : (_allImages.isNotEmpty ? _allImages.first : '');

    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'รายละเอียดข่าว'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (hasHero) _buildMainImage(heroUrl),
          if (hasHero) _buildExtraGallery(),
          if (hasHero) const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: GW.card(radius: 16),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: GW.text(
                          size: 11,
                          weight: FontWeight.w600,
                          color: GW.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (date.isNotEmpty)
                      Text(date, style: GW.text(size: 12, color: GW.inkLight)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(title, style: GW.text(size: 18, weight: FontWeight.w700)),
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: GW.text(
                      size: 14,
                      color: GW.inkMuted,
                      height: 1.45,
                    ),
                  ),
                ],
                if (linkUrl.isNotEmpty) ...[
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
                        final uri = Uri.tryParse(linkUrl);
                        if (uri == null) return;
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        textButton,
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
  }
}
