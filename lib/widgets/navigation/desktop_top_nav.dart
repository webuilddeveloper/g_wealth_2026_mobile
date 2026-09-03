import 'package:gwealth/component/dialog_service.dart';
import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/login.dart';
import 'package:gwealth/menu.dart';
import 'package:gwealth/models/user_profile_store.dart';
import 'package:gwealth/notification.dart';
import 'package:gwealth/shared/notification_store.dart';
import 'package:gwealth/shared/responsive/responsive_values.dart';
import 'package:gwealth/widgets/notification_badge.dart';
import 'package:gwealth/widgets/profile/profile_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NavItem {
  final String? icon;
  final IconData? iconData;
  final IconData? activeIconData;
  final String label;
  final int index;
  final bool showBadge;
  final bool isLogo;

  const NavItem({
    this.icon,
    this.iconData,
    this.activeIconData,
    required this.label,
    required this.index,
    this.showBadge = false,
    this.isLogo = false,
  });
}

class DesktopTopNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> navItems;
  final String name;
  final String imageUrl;
  final String userType;
  final String typeLogin;

  const DesktopTopNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navItems,
    required this.name,
    required this.imageUrl,
    required this.userType,
    required this.typeLogin,
  });

  @override
  Widget build(BuildContext context) {
    final loggedIn = typeLogin != 'null';

    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: RV.appBarHeight(context),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE8ECF1))),
        ),
        child: Row(
          children: [
            Text(
              'G-Wealth',
              style: GW.text(
                size: 20,
                weight: FontWeight.w800,
                color: GW.primary,
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Row(
                children: [
                  for (final item in navItems)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: () => onTap(item.index),
                        style: TextButton.styleFrom(
                          foregroundColor: currentIndex == item.index
                              ? GW.primary
                              : GW.inkMuted,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              currentIndex == item.index
                                  ? (item.activeIconData ??
                                      item.iconData ??
                                      Icons.circle)
                                  : (item.iconData ?? Icons.circle_outlined),
                              size: 18,
                              color: currentIndex == item.index
                                  ? GW.primary
                                  : GW.inkMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.label,
                              style: GW.text(
                                size: 13,
                                weight: currentIndex == item.index
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: currentIndex == item.index
                                    ? GW.primary
                                    : GW.inkMuted,
                              ),
                            ),
                            if (item.showBadge && loggedIn)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: NotificationBadgeDot(
                                  count: NotificationStore.instance
                                      .badgeCountForNavIndex(item.index),
                                  size: 7,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (loggedIn) ...[
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none_rounded),
                    Positioned(
                      top: -2,
                      right: -4,
                      child: NotificationBadgeDot(
                        count: NotificationStore.instance.unreadCount,
                        size: 7,
                      ),
                    ),
                  ],
                ),
                color: GW.inkMuted,
              ),
              const SizedBox(width: 8),
              ProfileAvatar(
                imageUrl: imageUrl,
                typeLogin: typeLogin,
                size: 40,
                onProfileTap: () => onTap(3),
              ),
              const SizedBox(width: 8),
              Text(
                name.isEmpty ? 'สมาชิก' : name,
                style: GW.text(size: 13, weight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  DialogService.showConfirmLogout(
                    context,
                    title: 'confirmLogoutTitle'.tr(),
                    message: 'confirmLogoutMessage'.tr(),
                    onConfirm: () async {
                      await UserProfileStore.instance.resetAndClear();
                      if (!context.mounted) return;
                      await Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MenuPage()),
                        (_) => false,
                      );
                    },
                  );
                },
                child: Text('logout'.tr(),
                    style: GW.text(size: 12, color: Colors.red)),
              ),
            ] else
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LoginPage(isBack: true)),
                  );
                },
                child: Text('login'.tr(),
                    style: GW.text(
                        size: 13, weight: FontWeight.w700, color: GW.primary)),
              ),
          ],
        ),
      ),
    );
  }
}
