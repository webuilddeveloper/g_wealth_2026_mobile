import 'package:LawyerOnline/gwealth/home_page.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/welfare_page.dart';
import 'package:LawyerOnline/login.dart';
import 'package:LawyerOnline/models/user_profile_store.dart';
import 'package:LawyerOnline/notification.dart';
import 'package:LawyerOnline/profile.dart';
import 'package:LawyerOnline/shared/notification_store.dart';
import 'package:LawyerOnline/shared/responsive/res_layout.dart';
import 'package:LawyerOnline/shared/responsive/responsive_values.dart';
import 'package:LawyerOnline/widgets/navigation/desktop_top_nav.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, this.pageIndex, this.modelprofile, this.userType});

  final int? pageIndex;
  final dynamic modelprofile;
  final String? userType;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  static const _tabSpring = SpringDescription(
    mass: 1,
    stiffness: 80,
    damping: 22,
  );

  late final AnimationController _tabAnimCtrl;

  int _currentPage = 0;
  double _slideDirection = 1.0;
  DateTime? currentBackPressTime;

  String userType = '';
  String name = '';
  String imageUrl = '';
  String typeLogin = '';

  List<NavItem> get _navItems => [
        const NavItem(
          iconData: Icons.home_outlined,
          activeIconData: Icons.home_rounded,
          label: 'หน้าแรก',
          index: 0,
        ),
        const NavItem(
          iconData: Icons.volunteer_activism_outlined,
          activeIconData: Icons.volunteer_activism,
          label: 'สวัสดิการสังคม',
          index: 1,
        ),
        const NavItem(
          iconData: Icons.notifications_none_rounded,
          activeIconData: Icons.notifications_rounded,
          label: 'แจ้งเตือน',
          index: 2,
          showBadge: true,
        ),
        const NavItem(
          iconData: Icons.person_outline_rounded,
          activeIconData: Icons.person_rounded,
          label: 'โปรไฟล์',
          index: 3,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _tabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _tabAnimCtrl.value = 1.0;
    callRead();
    UserProfileStore.instance.addListener(_onStoreChanged);
    NotificationStore.instance.addListener(_onNotificationChanged);
  }

  @override
  void dispose() {
    _tabAnimCtrl.dispose();
    UserProfileStore.instance.removeListener(_onStoreChanged);
    NotificationStore.instance.removeListener(_onNotificationChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;
    final store = UserProfileStore.instance;
    setState(() {
      name = store.name;
      imageUrl = store.imageUrl;
      typeLogin = store.typeLogin;
      userType = store.userType.isNotEmpty ? store.userType : userType;
    });
    if (store.isLoggedIn) {
      NotificationStore.instance.refresh();
    } else {
      NotificationStore.instance.clearUnread();
    }
  }

  void _onNotificationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> callRead() async {
    await UserProfileStore.instance.load();
    if (UserProfileStore.instance.isLoggedIn) {
      await NotificationStore.instance.refresh();
    }

    final store = UserProfileStore.instance;
    setState(() {
      userType = widget.userType?.isNotEmpty == true
          ? widget.userType!
          : store.userType;
      name = store.name;
      imageUrl = store.imageUrl;
      typeLogin = store.typeLogin;
      _currentPage = widget.pageIndex ?? 0;
    });
  }

  Widget _tabChild(int index) {
    switch (index) {
      case 0:
        return GWHomePage(
          key: const ValueKey(0),
          onProfileTap: () => _onNavTap(3),
          onWelfareTap: () => _onNavTap(1),
          isTabActive: _currentPage == 0,
        );
      case 1:
        return const GWWelfarePage(
          key: ValueKey(1),
          embedded: true,
        );
      case 2:
        return typeLogin != 'null'
            ? const NotificationPage(key: ValueKey(2))
            : LoginPage(key: const ValueKey(2), isBack: false);
      case 3:
        return typeLogin != 'null'
            ? ProfilePage(key: const ValueKey(3))
            : LoginPage(key: const ValueKey(3), isBack: false);
      default:
        return GWHomePage(
          key: const ValueKey(0),
          onProfileTap: () => _onNavTap(3),
          onWelfareTap: () => _onNavTap(1),
          isTabActive: _currentPage == 0,
        );
    }
  }

  void _playTabTransition() {
    _tabAnimCtrl.stop();
    _tabAnimCtrl.value = 0;
    _tabAnimCtrl.animateWith(
      SpringSimulation(_tabSpring, 0, 1, 0),
    );
  }

  Widget _buildAnimatedTabBody() {
    return AnimatedBuilder(
      animation: _tabAnimCtrl,
      builder: (context, child) {
        final t = _tabAnimCtrl.value.clamp(0.0, 1.0);
        final dx = _slideDirection * 5 * (1 - t);
        final dy = 1.5 * (1 - t);
        return Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );
      },
      child: RepaintBoundary(
        child: IndexedStack(
          index: _currentPage,
          sizing: StackFit.expand,
          children: List.generate(_navItems.length, (index) {
            return TickerMode(
              enabled: index == _currentPage,
              child: _tabChild(index),
            );
          }),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _currentPage) return;
    _slideDirection = index > _currentPage ? 1.0 : -1.0;
    setState(() => _currentPage = index);
    _playTabTransition();
    if (UserProfileStore.instance.isLoggedIn) {
      NotificationStore.instance.refresh();
    }
  }

  Future<bool> confirmExit() {
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'pressBackAgainToExit'.tr());
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      extendBody: false,
      backgroundColor: GW.bg,
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: Size.fromHeight(RV.appBarHeight(context)),
              child: DesktopTopNav(
                currentIndex: _currentPage,
                onTap: _onNavTap,
                navItems: _navItems,
                name: name,
                imageUrl: imageUrl,
                userType: userType,
                typeLogin: typeLogin,
              ),
            )
          : null,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final ok = await confirmExit();
            if (ok && context.mounted) {
              Navigator.of(context).maybePop();
            }
          },
          child: _buildAnimatedTabBody(),
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _GWBottomBar(
              items: _navItems,
              currentIndex: _currentPage,
              badgeCountFor: (index) => typeLogin != 'null'
                  ? NotificationStore.instance.badgeCountForNavIndex(index)
                  : 0,
              onTap: _onNavTap,
            ),
    );
  }
}

/// Bottom bar ตาม mockup: แถบขาวเต็มจอ + ไอคอนเส้นบาง + title ใต้ไอคอน
class _GWBottomBar extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final int Function(int index) badgeCountFor;
  final ValueChanged<int> onTap;

  const _GWBottomBar({
    required this.items,
    required this.currentIndex,
    required this.badgeCountFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFECECEC), width: 0.8),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: _GWBottomNavItem(
                    item: item,
                    isSelected: currentIndex == item.index,
                    badgeCount: badgeCountFor(item.index),
                    onTap: () => onTap(item.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GWBottomNavItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _GWBottomNavItem({
    required this.item,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? GW.primary : const Color(0xFF8A8A8A);
    final icon = isSelected
        ? (item.activeIconData ?? item.iconData ?? Icons.circle)
        : (item.iconData ?? Icons.circle_outlined);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: color),
              if (item.showBadge && badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GW.text(
              size: 10.5,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
