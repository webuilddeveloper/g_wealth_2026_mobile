import 'dart:async';
import 'package:flutter/material.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/menu.dart';
import 'package:LawyerOnline/models/user_profile_store.dart';
import 'package:LawyerOnline/pdpa_consent_page.dart';
import 'package:LawyerOnline/services/pdpa_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
    _startDelay();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _startDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    _callNavigatorPage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF5FA), Colors.white, Color(0xFFF0F7FF)],
            ),
          ),
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: GW.headerGradient,
                        boxShadow: [
                          BoxShadow(
                            color: GW.primary.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.hub_outlined,
                          color: Colors.white, size: 52),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'G-Wealth',
                      style: GW.text(
                        size: 28,
                        weight: FontWeight.w800,
                        color: GW.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ศูนย์กลางสวัสดิการแห่งรัฐ',
                      style: GW.text(size: 14, color: GW.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _callNavigatorPage() async {
    await UserProfileStore.instance.load();
    final userType = UserProfileStore.instance.userType;
    if (!mounted) return;

    final accepted = await PdpaService.hasAcceptedPdpa();
    if (!accepted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdpaConsentPage(
            onAccepted: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MenuPage(userType: userType),
      ),
      (_) => false,
    );
  }
}
