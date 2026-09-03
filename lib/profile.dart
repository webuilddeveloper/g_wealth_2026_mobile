import 'package:LawyerOnline/about-us.dart';
import 'package:LawyerOnline/change-password.dart';
import 'package:LawyerOnline/component/dialog_service.dart';
import 'package:LawyerOnline/delete-account.dart';
import 'package:LawyerOnline/device_sessions_page.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:LawyerOnline/menu.dart';
import 'package:LawyerOnline/models/user_profile_store.dart';
import 'package:LawyerOnline/notification-settings.dart';
import 'package:LawyerOnline/profile-form.dart';
import 'package:LawyerOnline/shared/responsive/res_layout.dart';
import 'package:LawyerOnline/widgets/profile/profile_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userType, this.name, this.imageUrl});

  final String? userType;
  final String? name;
  final String? imageUrl;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String get name => UserProfileStore.instance.name;
  String get imageUrl => UserProfileStore.instance.imageUrl;
  String get typeLogin => UserProfileStore.instance.typeLogin;

  @override
  void initState() {
    super.initState();
    UserProfileStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    UserProfileStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: GWAppBar(
        title: 'profile'.tr(),
        showBack: false,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                ResponsiveLayout.isDesktop(context) ? 560 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              const SizedBox(height: 20),
              _profileCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  name.isEmpty ? 'ประชาชน' : name,
                  style: GW.text(
                    size: 16,
                    weight: FontWeight.w700,
                    color: GW.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('myAccount'.tr()),
              _menuItem(
                title: 'editInformation'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileFormPage(),
                    ),
                  );
                },
              ),
              _menuItem(
                title: 'changePassword'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _sectionTitle('settings'.tr()),
              _menuItem(
                title: 'notifications'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingPage(),
                    ),
                  );
                },
              ),
              _menuItem(
                title: 'changelanguage'.tr(),
                onTap: () => showLanguagePicker(context),
              ),
              _menuItem(
                title: 'deviceSessionsTitle'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeviceSessionsPage(),
                    ),
                  );
                },
              ),
              _menuItem(
                title: 'aboutUs'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutUsPage(),
                    ),
                  );
                },
              ),
              _menuItem(
                title: 'deleteAccount'.tr(),
                titleStyle: GW.text(size: 12, color: Colors.red),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeleteAccountPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _confirmLogout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFDF0A0A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout,
                            size: 16, color: Color(0xFFDF0A0A)),
                        const SizedBox(width: 8),
                        Text(
                          'logout'.tr(),
                          style: GW.text(
                            size: 14,
                            weight: FontWeight.w600,
                            color: const Color(0xFFDF0A0A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: ProfileAvatar(
            imageUrl: imageUrl,
            typeLogin: typeLogin,
            size: 100,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Text(title, style: GW.text(size: 16, weight: FontWeight.w700)),
    );
  }

  Widget _menuItem({
    required String title,
    required VoidCallback onTap,
    TextStyle? titleStyle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle ?? GW.text(size: 13),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 12, color: GW.primary),
              ],
            ),
          ),
          const Divider(color: Color(0xFFD9D9D9), height: 1),
        ],
      ),
    );
  }

  void _confirmLogout() {
    DialogService.showConfirmLogout(
      context,
      title: 'confirmLogoutTitle'.tr(),
      message: 'confirmLogoutMessage'.tr(),
      onConfirm: _logout,
    );
  }

  Future<void> _logout() async {
    await UserProfileStore.instance.resetAndClear();
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MenuPage()),
      (_) => false,
    );
  }
}

Future<void> showLanguagePicker(BuildContext context) async {
  final storage = const FlutterSecureStorage();
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('ไทย', style: GW.text(size: 15)),
              onTap: () async {
                await context.setLocale(const Locale('th'));
                await storage.write(key: 'appLanguage', value: 'th');
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text('English', style: GW.text(size: 15)),
              onTap: () async {
                await context.setLocale(const Locale('en'));
                await storage.write(key: 'appLanguage', value: 'en');
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      );
    },
  );
}
