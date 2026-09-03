import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Legacy wrapper — ชี้ไป GWAppBar เพื่อให้ทุกหน้าได้ status bar ที่อ่านได้
PreferredSizeWidget appBar({
  String? title = '',
  bool backBtn = true,
  bool rightBtn = true,
  Function? rightAction,
  Function? backAction,
  bool isFavorite = false,
}) {
  final customBack = backAction;
  return GWAppBar(
    title: title ?? '',
    showBack: backBtn,
    // ส่ง onBack เฉพาะเมื่อมี custom action — ไม่เช่นนั้นให้ GWAppBar pop เอง
    onBack: backBtn && customBack != null ? () => customBack() : null,
    actions: rightBtn
        ? [
            _AppBarIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : GW.inkMuted,
              background: isFavorite ? const Color(0xFFFFF0F0) : GW.primarySoft,
              onTap: () => rightAction?.call(),
            ),
          ]
        : null,
  );
}

PreferredSizeWidget appBarCustom({
  String? title = '',
  String? subTitle = '',
  bool backBtn = true,
  bool isRightWidget = true,
  Widget? rightWidget,
  Function? backAction,
}) {
  final customBack = backAction;
  return GWAppBar(
    title: title ?? '',
    subtitle: subTitle,
    showBack: backBtn,
    onBack: backBtn && customBack != null ? () => customBack() : null,
    actions: isRightWidget && rightWidget != null ? [rightWidget] : null,
  );
}

PreferredSizeWidget appBarHome({
  String? name = '',
  String? memberType = '',
  String? imageUrl = '',
  String? typeLogin = 'local',
  Widget? rightWidget,
  Function? rightAction,
  Function? profileAction,
}) {
  return GWAppBar(
    title: name?.isNotEmpty == true ? name! : 'G-Wealth',
    subtitle: memberType,
    showBack: false,
    actions: rightWidget != null ? [rightWidget] : null,
  );
}

PreferredSizeWidget appBarChat({
  required VoidCallback onBack,
  required Widget avatarWidget,
  required String name,
  String? statusText,
  Widget? actions,
}) {
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: GW.ink,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    leading: Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Center(
        child: _AppBarIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          color: GW.primary,
          background: GW.primarySoft,
          onTap: onBack,
        ),
      ),
    ),
    titleSpacing: 8,
    title: Row(
      children: [
        avatarWidget,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GW.text(size: 15, weight: FontWeight.w700),
              ),
              if (statusText != null)
                Text(
                  statusText,
                  style: GW.text(size: 12, color: GW.inkMuted),
                ),
            ],
          ),
        ),
      ],
    ),
    actions: actions != null ? [actions, const SizedBox(width: 8)] : null,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: GW.border.withValues(alpha: 0.7)),
    ),
  );
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
