import 'package:gwealth/gwealth/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppBar มาตรฐานของ G-Wealth — พื้นขาว ไอคอนสถานะเข้ม อ่านชัดบนมือถือ
/// ใช้ Material [AppBar] เพื่อให้ Scaffold คำนวณความสูง / status bar ถูกต้อง
class GWAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GWAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.bottom,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBack;

  static const _toolbarHeight = 56.0;
  static const _dividerHeight = 1.0;

  @override
  Size get preferredSize => Size.fromHeight(
        _toolbarHeight +
            (bottom?.preferredSize.height ?? 0) +
            _dividerHeight,
      );

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showLeading = showBack && (onBack != null || canPop);

    final divider = Container(
      height: _dividerHeight,
      color: GW.border.withValues(alpha: 0.7),
    );

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: GW.ink,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: _toolbarHeight,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      leadingWidth: showLeading ? 56 : 0,
      leading: showLeading
          ? Center(
              child: _BackButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GW.text(
              size: 17,
              weight: FontWeight.w700,
              color: GW.ink,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GW.text(
                size: 11,
                color: GW.inkMuted,
              ),
            ),
        ],
      ),
      actions: actions == null || actions!.isEmpty
          ? null
          : [
              ...actions!,
              const SizedBox(width: 8),
            ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          (bottom?.preferredSize.height ?? 0) + _dividerHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bottom != null) bottom!,
            divider,
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GW.primarySoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: GW.primary,
          ),
        ),
      ),
    );
  }
}
