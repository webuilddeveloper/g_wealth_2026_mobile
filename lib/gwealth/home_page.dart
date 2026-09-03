import 'package:LawyerOnline/gwealth/chatbot_page.dart';
import 'package:LawyerOnline/gwealth/contact_page.dart';
import 'package:LawyerOnline/gwealth/data/mock_data.dart';
import 'package:LawyerOnline/gwealth/knowledge_page.dart';
import 'package:LawyerOnline/gwealth/news_page.dart';
import 'package:LawyerOnline/gwealth/rights_page.dart';
import 'package:LawyerOnline/gwealth/services/home_content_service.dart';
import 'package:LawyerOnline/gwealth/services_all_page.dart';
import 'package:LawyerOnline/gwealth/survey_page.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/welfare_page.dart';
import 'package:LawyerOnline/gwealth/widgets/home_sections.dart';
import 'package:LawyerOnline/models/user_profile_store.dart';
import 'package:LawyerOnline/notification.dart';
import 'package:LawyerOnline/shared/responsive/responsive_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GWHomePage extends StatefulWidget {
  const GWHomePage({
    super.key,
    this.onProfileTap,
    this.onWelfareTap,
    this.isTabActive = true,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onWelfareTap;
  final bool isTabActive;

  @override
  State<GWHomePage> createState() => _GWHomePageState();
}

class _GWHomePageState extends State<GWHomePage> {
  String name = '';
  String imageUrl = '';
  List<dynamic> _banners = [];
  List<dynamic> _news = [];
  bool _loadingContent = true;

  /// ทับช่วงโค้งนูนของ header ตาม mockup (~ครึ่งบนของการ์ดทับชมพู)
  static const _bannerOverlap = 58.0;
  /// การ์ดแบนเนอร์เตี้ยตาม mockup + จุด carousel
  static const _bannerCardHeight = 112.0;
  static const _bannerBlockHeight = 112.0 + 18.0; // card + dots
  /// ความสูงส่วนเนื้อหา header (ไม่รวม status bar) — ให้มีช่องว่างเหนือแบนเนอร์
  static const _headerBody = 168.0;

  @override
  void initState() {
    super.initState();
    UserProfileStore.instance.addListener(_syncProfile);
    _syncProfile();
    _loadContent();
  }

  @override
  void dispose() {
    UserProfileStore.instance.removeListener(_syncProfile);
    super.dispose();
  }

  void _syncProfile() {
    final store = UserProfileStore.instance;
    if (!mounted) return;
    setState(() {
      name = store.name;
      imageUrl = store.imageUrl;
    });
  }

  Future<void> _loadContent() async {
    setState(() => _loadingContent = true);
    final results = await Future.wait([
      GWHomeContentService.instance.fetchBanners(),
      GWHomeContentService.instance.fetchNews(limit: 10),
    ]);
    if (!mounted) return;
    setState(() {
      _banners = results[0];
      _news = results[1];
      _loadingContent = false;
    });
  }

  Future<void> _openService(GWServiceItem item) async {
    switch (item.route) {
      case 'register':
        final ok = await gwEnsureLogin(context);
        if (!ok || !mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GWRightsPage(initialTab: 0)),
        );
        break;
      case 'rights':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GWRightsPage()),
        );
        break;
      case 'news':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GWNewsPage()),
        );
        break;
      case 'knowledge':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GWKnowledgePage()),
        );
        break;
      case 'welfare':
        if (widget.onWelfareTap != null) {
          widget.onWelfareTap!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GWWelfarePage()),
          );
        }
        break;
      case 'survey':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GWSurveyPage()),
        );
        break;
      case 'alert':
        _showEmergencySheet();
        break;
      case 'contact':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GWContactPage()),
        );
        break;
    }
  }

  void _showEmergencySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GW.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('แจ้งเหตุฉุกเฉิน',
                  style: GW.text(size: 18, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'ช่องทางช่วยเหลือเร่งด่วนจากเครือข่ายหน่วยงานรัฐ',
                style: GW.text(size: 13, color: GW.inkMuted),
              ),
              const SizedBox(height: 16),
              _EmergencyTile(
                title: 'สายด่วน พม. 1300',
                subtitle: 'ช่วยเหลือกลุ่มเปราะบางตลอด 24 ชม.',
                icon: Icons.support_agent,
                color: GW.primary,
                onTap: () => Navigator.pop(ctx),
              ),
              _EmergencyTile(
                title: 'แจ้งเหตุฉุกเฉิน 191',
                subtitle: 'ตำรวจ / เหตุร้ายเร่งด่วน',
                icon: Icons.local_police_outlined,
                color: GW.danger,
                onTap: () => Navigator.pop(ctx),
              ),
              _EmergencyTile(
                title: 'เจ็บป่วยฉุกเฉิน 1669',
                subtitle: 'หน่วยแพทย์ฉุกเฉิน',
                icon: Icons.local_hospital_outlined,
                color: GW.accentBlue,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final headerHeight = top + _headerBody;
    final maxW = RV.maxContentWidth(context);
    final contentMax = maxW.isFinite ? maxW : 720.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: GW.bg,
        body: RefreshIndicator(
          color: GW.primary,
          displacement: headerHeight * 0.35,
          onRefresh: () async {
            await UserProfileStore.instance.load();
            _syncProfile();
            await _loadContent();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMax),
                    child: SizedBox(
                      height: headerHeight + (_bannerBlockHeight - _bannerOverlap),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GWHomeHeader(
                            name: name,
                            imageUrl: imageUrl,
                            height: headerHeight,
                            onProfileTap: widget.onProfileTap,
                            onSearchTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GWServicesAllPage(),
                                ),
                              );
                            },
                            onNotiTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationPage(),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: headerHeight - _bannerOverlap,
                            child: GWBannerCarousel(
                              banners: _banners,
                              height: _bannerCardHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMax),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: GWServiceGrid(
                        onTap: _openService,
                        onSeeAll: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GWServicesAllPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMax),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                      child: _loadingContent && _news.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: GW.primary,
                                  strokeWidth: 2.4,
                                ),
                              ),
                            )
                          : GWNewsSection(
                              items: _news,
                              onSeeAll: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const GWNewsPage(),
                                  ),
                                );
                              },
                              onTap: (n) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GWNewsDetailPage(item: n),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GWChatbotPage()),
              );
            },
            backgroundColor: GW.primary,
            foregroundColor: Colors.white,
            elevation: 3,
            child: const Icon(Icons.smart_toy_outlined),
          ),
        ),
      ),
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: GW.text(size: 15, weight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GW.text(size: 12, color: GW.inkMuted)),
      trailing: const Icon(Icons.chevron_right, color: GW.inkLight),
    );
  }
}
