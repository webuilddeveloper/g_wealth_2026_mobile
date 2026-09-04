import 'package:gwealth/change-password.dart';
import 'package:gwealth/component/dialog_service.dart';
import 'package:gwealth/component/loading_service.dart';
import 'package:gwealth/gwealth/theme.dart';
import 'package:gwealth/menu.dart';
import 'package:gwealth/register_page.dart';
import 'package:gwealth/services/auth_service.dart';
import 'package:gwealth/services/device_session_service.dart';
import 'package:gwealth/services/fcm_service.dart';
import 'package:gwealth/shared/apple_firebase.dart';
import 'package:gwealth/shared/line.dart';
import 'package:gwealth/shared/notification-service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gwealth/models/user_model.dart';
import 'package:gwealth/models/user_profile_store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gwealth/shared/responsive/app_layout.dart';

class LoginPage extends StatefulWidget {
  final bool isBack;
  LoginPage({super.key, this.isBack = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final storage = const FlutterSecureStorage();

  bool remember = false;
  bool obscure = true;

  late AnimationController controller;
  late Animation<double> fade;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: GW.inkMuted, size: 20),
      suffixIcon: suffix,
      labelText: label,
      labelStyle: GW.text(size: 14, color: GW.inkMuted),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GW.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GW.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GW.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    const headerBody = 188.0;
    final headerHeight = top + headerBody;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: GW.bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: GW.bg,
        body: FadeTransition(
          opacity: fade,
          child: AppLayout(
            maxWidth: 500,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: headerHeight,
                  child: ClipPath(
                    clipper: GWHeaderCurveClipper(),
                    child: Container(
                      width: double.infinity,
                      decoration:
                          const BoxDecoration(gradient: GW.headerGradient),
                      padding: EdgeInsets.fromLTRB(12, top + 4, 12, 48),
                      child: Stack(
                        children: [
                          if (widget.isBack)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: goBack,
                                  child: const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.12),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/icons/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'appTitle'.tr(),
                                  textAlign: TextAlign.center,
                                  style: GW.text(
                                    size: 22,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'loginSubtitle'.tr(),
                                  textAlign: TextAlign.center,
                                  style: GW.text(
                                    size: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.92),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                      decoration: GW.card(radius: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'login'.tr(),
                            textAlign: TextAlign.center,
                            style: GW.text(
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'loginFormHint'.tr(),
                            textAlign: TextAlign.center,
                            style: GW.text(size: 13, color: GW.inkMuted),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: usernameController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: GW.text(size: 15),
                            decoration: _fieldDecoration(
                              label: 'loginEmail'.tr(),
                              icon: Icons.mail_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: passwordController,
                            obscureText: obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (!isLoading) login();
                            },
                            style: GW.text(size: 15),
                            decoration: _fieldDecoration(
                              label: 'passwordPlaceholder'.tr(),
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: GW.inkMuted,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscure = !obscure;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'register'.tr(),
                                  style: GW.text(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: GW.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'forgotPassword'.tr(),
                                  style: GW.text(
                                    size: 13,
                                    color: GW.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 50,
                            child: GestureDetector(
                              onTap: () {
                                if (!isLoading) login();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isLoading
                                      ? null
                                      : GW.headerGradient,
                                  color: isLoading
                                      ? GW.primaryMute
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: isLoading
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: GW.primary
                                                .withValues(alpha: 0.28),
                                            blurRadius: 12,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const DotsLoader(color: Colors.white)
                                      : Text(
                                          'login'.tr(),
                                          style: GW.text(
                                            size: 16,
                                            weight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                side: const BorderSide(color: GW.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: isLoading ? null : pressThaiId,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/thaiid.png',
                                    width: 36,
                                    height: 36,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'loginWithThaiID'.tr(),
                                    style: GW.text(
                                      size: 15,
                                      weight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mock Thai ID login — จำลองยืนยันตัวตน แล้วเข้าด้วยโปรไฟล์ตัวอย่าง
  Future<void> pressThaiId() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    DialogService.showLoading(
      context,
      message: 'thaiIdLoggingIn'.tr(),
    );

    try {
      // จำลองขั้นตอน Thai ID (redirect / ยืนยันตัวตน)
      await Future.delayed(const Duration(milliseconds: 1800));

      // โปรไฟล์ตัวอย่างที่ "ดึงมาจาก Thai ID"
      const mockUser = UserModel(
        code: 'thaiid-demo-1103700150001',
        userType: 'user',
        firstName: 'สมชาย',
        lastName: 'ใจดี',
        email: 'somchai.jaidee@example.com',
        phone: '0812345678',
        imageUrl: 'assets/images/profile-avatar.jpg',
        category: 'ThaiID',
        isActive: true,
        status: 'A',
        prefixName: 'นาย',
        facebookID: '',
        googleID: '',
        lineID: '',
        line: '',
        sex: 'M',
        address: 'กรุงเทพมหานคร',
        idcard: '1103700150001',
        lastLat: 0,
        lastLong: 0,
      );

      await NotificationService.saveFcmToken(
        await FirebaseMessaging.instance.getToken() ?? '',
      );

      await UserProfileStore.instance.setUser(
        mockUser,
        typeLogin: 'thaiid',
        authToken: 'mock-thaiid-token',
      );

      FcmService.registerFcmToken(mockUser.code);

      if (!mounted) return;
      Navigator.pop(context); // ปิด loading

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPage(userType: mockUser.userType),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => isLoading = false);
        DialogService.showError(
          context,
          title: 'loginFailed'.tr(),
          message: 'thaiIdLoginFailed'.tr(),
        );
      }
    }
  }

  pressLine() async {
    try {
      var obj = await loginLine();

      DialogService.showLoading(context);

      final idToken = obj.accessToken.idToken;
      final userEmail = (idToken != null) ? idToken['email'] ?? '' : '';

      await NotificationService.saveFcmToken(
        await FirebaseMessaging.instance.getToken() ?? '',
      );

      await UserProfileStore.instance.setUser(
        UserModel(
            code: obj.userProfile!.userId,
            userType: 'user',
            firstName: obj.userProfile!.displayName,
            lastName: '',
            email: userEmail.toString(),
            phone: '',
            imageUrl: obj.userProfile!.pictureUrl?.isNotEmpty == true
                ? obj.userProfile!.pictureUrl!
                : '',
            category: 'Line',
            isActive: true,
            status: '',
            prefixName: '',
            facebookID: '',
            googleID: '',
            lineID: obj.userProfile!.userId,
            line: '',
            sex: '',
            address: '',
            idcard: '',
            lastLat: 0.0,
            lastLong: 0.0),
        typeLogin: 'social',
      );

      if (!mounted) return;
      Navigator.pop(context);

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(),
        ),
      );
    } catch (e) {
      DialogService.showError(
        context,
        title: "loginFailed".tr(),
        message: "genericError".tr(),
      );
    }
  }

  pressApple() async {
    var obj = await signInWithApple();
    var model = {
      "username": obj!.user?.email ?? obj.user?.uid,
      "email": obj.user?.email ?? '',
      "imageUrl": '',
      "firstName": obj.user?.email,
      "lastName": '',
      "appleID": obj.user?.uid
    };
    print(
        "---------------------------------------------------------------------");
    print(model);
    print(
        "---------------------------------------------------------------------");
  }

  login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final session = await AuthService.loginSession(
        usernameController.text.trim(),
        passwordController.text,
        'guest',
      );
      final user = session.user;
      final userWithAvatar = user.imageUrl.isNotEmpty
          ? user
          : user.copyWith(imageUrl: 'assets/images/profile-avatar.jpg');

      await UserProfileStore.instance.setUser(
        userWithAvatar,
        typeLogin: 'local',
        authToken: session.token,
      );

      FcmService.registerFcmToken(user.code);
      await DeviceSessionService.registerCurrentDevice(
        userCode: user.code,
        token: session.token,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPage(userType: user.userType),
        ),
      );
    } catch (error) {
      print('--------------123-------------- ${error}');
      setState(() {
        isLoading = false;
      });
      if (error is AccountBlockedException) {
        _showAccountBlockedDialog(error);
        return;
      }
      DialogService.showError(
        context,
        title: 'loginFailed'.tr(),
        message: _friendlyLoginError(error),
      );
    }
  }

  void _showAccountBlockedDialog(AccountBlockedException error) {
    final isBanned = error.accountStatus == 'B';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isBanned ? 'บัญชีถูกปิดใช้งานถาวร' : 'บัญชีถูกระงับชั่วคราว',
          style: GW.text(size: 18, weight: FontWeight.w700),
        ),
        content: Text(
          error.message,
          style: GW.text(size: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ตกลง',
              style: GW.text(weight: FontWeight.w600, color: GW.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyLoginError(Object error) {
    final raw = error.toString();
    final normalized = raw.toLowerCase();

    final leaksApiDetail = normalized.contains('http://') ||
        normalized.contains('https://') ||
        normalized.contains('/m/register/') ||
        normalized.contains('uri=') ||
        normalized.contains('clientexception');

    if (leaksApiDetail ||
        normalized.contains('failed to fetch') ||
        normalized.contains('socketexception') ||
        normalized.contains('timeout') ||
        normalized.contains('network')) {
      return 'networkError'.tr();
    }

    if (normalized.contains('server') ||
        normalized.contains('http') ||
        normalized.contains('500') ||
        normalized.contains('502') ||
        normalized.contains('503') ||
        normalized.contains('504')) {
      return 'serverError'.tr();
    }

    var message = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (message.isEmpty || _containsSensitiveApiDetail(message)) {
      return 'genericError'.tr();
    }

    return message;
  }

  bool _containsSensitiveApiDetail(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('http://') ||
        normalized.contains('https://') ||
        normalized.contains('/m/register/') ||
        normalized.contains('uri=') ||
        normalized.contains('clientexception');
  }

  void goBack() async {
    Navigator.pop(context, false);
  }
}
