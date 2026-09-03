import 'package:gwealth/gwealth/data/mock_data.dart';
import 'package:gwealth/gwealth/services/gw_map.dart';
import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/login.dart';
import 'package:gwealth/models/user_profile_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

typedef GWServiceTap = void Function(GWServiceItem item);

class GWHomeHeader extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double height;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotiTap;

  const GWHomeHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.height,
    this.onProfileTap,
    this.onSearchTap,
    this.onNotiTap,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final displayName =
        name.trim().isEmpty || name == 'null' ? 'ประชาชน' : name;

    return ClipPath(
      clipper: GWHeaderCurveClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: const BoxDecoration(gradient: GW.headerGradient),
        padding: EdgeInsets.fromLTRB(16, top + 8, 12, 78),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: _BorderlessAvatar(imageUrl: imageUrl, size: 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดี ยินดีต้อนรับ',
                      style: GW.text(
                        size: 16,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GW.text(
                        size: 13,
                        weight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ตาม mockup: ไอคอนค้นหา + แจ้งเตือนอยู่ในแคปซูลเดียว
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    onTap: onSearchTap,
                  ),
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: onNotiTap,
                    showDot: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BorderlessAvatar extends StatelessWidget {
  const _BorderlessAvatar({required this.imageUrl, required this.size});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isNotEmpty
            ? (imageUrl.startsWith('http')
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Image.asset(imageUrl, fit: BoxFit.cover))
            : Image.asset('assets/icons/profile.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (showDot)
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GWBannerCarousel extends StatefulWidget {
  final List<dynamic> banners;
  final double height;

  const GWBannerCarousel({
    super.key,
    required this.banners,
    this.height = 112,
  });

  @override
  State<GWBannerCarousel> createState() => _GWBannerCarouselState();
}

class _GWBannerCarouselState extends State<GWBannerCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners.isEmpty
        ? <dynamic>[
            {
              'title': 'G-Wealth',
              'description': 'ศูนย์กลางสวัสดิการแห่งรัฐ',
            },
          ]
        : widget.banners;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CarouselSlider.builder(
            itemCount: banners.length,
            itemBuilder: (context, i, _) {
              final b = banners[i];
              final imageUrl = gwStr(b, 'imageUrl');
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: GW.primary.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: widget.height,
                        placeholder: (_, __) => _BannerFallback(item: b),
                        errorWidget: (_, __, ___) =>
                            _BannerFallback(item: b),
                      )
                    : _BannerFallback(item: b),
              );
            },
            options: CarouselOptions(
              height: widget.height,
              viewportFraction: 1,
              padEnds: false,
              enableInfiniteScroll: banners.length > 1,
              autoPlay: banners.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (i, _) => setState(() => _index = i),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? GW.primary : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerFallback extends StatelessWidget {
  final dynamic item;
  const _BannerFallback({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = gwStr(item, 'title', 'G-Wealth');
    final subtitle = gwHtml(item, 'description');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F7), Color(0xFFFFD6EA), Color(0xFFE91E8C)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_outlined,
                color: GW.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'กระทรวง พม.',
                  style: GW.text(
                    size: 10,
                    weight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GW.text(
                    size: 14,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GW.text(
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.9),
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

class GWServiceGrid extends StatelessWidget {
  final GWServiceTap onTap;
  final VoidCallback? onSeeAll;

  const GWServiceGrid({super.key, required this.onTap, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'บริการ', onSeeAll: onSeeAll),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: GWData.services.length,
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, i) {
            final s = GWData.services[i];
            return InkWell(
              onTap: () => onTap(s),
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: GW.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(s.icon, color: GW.iconPink, size: 26),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    s.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GW.text(
                      size: 11,
                      weight: FontWeight.w500,
                      color: GW.ink,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class GWNewsSection extends StatelessWidget {
  final List<dynamic> items;
  final VoidCallback? onSeeAll;
  final ValueChanged<dynamic>? onTap;

  const GWNewsSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final list = items.take(3).toList();
    return Column(
      children: [
        _SectionHeader(title: 'ข่าวประชาสัมพันธ์', onSeeAll: onSeeAll),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: GW.card(radius: 16),
            child: Text('ยังไม่มีข่าวประชาสัมพันธ์',
                style: GW.text(size: 13, color: GW.inkMuted)),
          )
        else
          ...list.map((n) {
            final imageUrl = gwStr(n, 'imageUrl');
            final title = gwStr(n, 'title');
            final date = gwDateBe(n);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onTap?.call(n),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF2A2A2A),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: GW.primaryDeep),
                        )
                      else
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE91E8C),
                                Color(0xFF7C3AED),
                                Color(0xFF1A1A2E),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 36, 14, 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.72),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GW.text(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (date.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  date,
                                  style: GW.text(
                                    size: 11,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: GW.text(size: 17, weight: FontWeight.w700)),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'ดูทั้งหมด',
                  style: GW.text(
                    size: 13,
                    weight: FontWeight.w500,
                    color: GW.inkLight,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: GW.inkLight),
              ],
            ),
          ),
      ],
    );
  }
}

Future<bool> gwEnsureLogin(BuildContext context) async {
  if (UserProfileStore.instance.isLoggedIn) return true;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => LoginPage(isBack: true)),
  );
  return UserProfileStore.instance.isLoggedIn;
}
