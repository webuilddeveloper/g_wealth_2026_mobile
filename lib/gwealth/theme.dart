import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// G-Wealth design tokens — ใกล้เคียง mockup ใน G-Wealth_fn.pdf
class GW {
  GW._();

  /// สีชมพูหลักตาม mockup (magenta / hot pink)
  static const primary = Color(0xFFE91E8C);
  static const primaryDark = Color(0xFFC2186A);
  static const primaryDeep = Color(0xFFAD1457);
  static const primarySoft = Color(0xFFFFE8F3);
  static const primaryMute = Color(0xFFF8B6D4);
  static const iconPink = Color(0xFFD81B60);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF7C3AED);
  static const bg = Color(0xFFF7F8FC);
  static const surface = Colors.white;
  static const ink = Color(0xFF222222);
  static const inkMuted = Color(0xFF757575);
  static const inkLight = Color(0xFF9E9E9E);
  static const border = Color(0xFFE8ECF1);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  /// Header: ไล่จากชมพูสว่างด้านบน → ชมพูเข้มด้านล่าง
  static const headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF4FA3),
      Color(0xFFE91E8C),
      Color(0xFFD81B60),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const lifeGradient = LinearGradient(
    colors: [Color(0xFFFF4FA3), Color(0xFF7C3AED), Color(0xFF3B82F6)],
  );

  static TextStyle text({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.prompt(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: height,
    );
  }

  static BoxDecoration card({
    Color color = surface,
    double radius = 16,
    bool shadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}

/// โค้งนูนลงกลางด้านล่างของ header ตาม mockup ใน G-Wealth_fn.pdf
class GWHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // โค้งนูนลงกลางชัด — ขอบซ้าย/ขวาสูงขึ้น ให้เห็นโค้งข้างๆ แบนเนอร์
    const side = 44.0;
    path.lineTo(0, size.height - side);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 28,
      size.width,
      size.height - side,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
