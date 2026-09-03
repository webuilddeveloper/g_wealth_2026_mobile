import 'package:flutter/material.dart';
import 'package:gwealth/gwealth/theme.dart';

class GWServiceItem {
  final String id;
  final String title;
  final IconData icon;
  final String route;

  const GWServiceItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
  });
}

class GWBenefit {
  final String id;
  final String title;
  final String agency;
  final String lifeStage;
  final String dimension;
  final String amount;
  final String status; // eligible | pending | claimed | hidden
  final String description;

  const GWBenefit({
    required this.id,
    required this.title,
    required this.agency,
    required this.lifeStage,
    required this.dimension,
    required this.amount,
    required this.status,
    required this.description,
  });
}

class GWNewsItem {
  final String id;
  final String title;
  final String summary;
  final String date;
  final String category;
  final Color accent;

  const GWNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.date,
    required this.category,
    required this.accent,
  });
}

class GWLifeStage {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> sampleRights;

  const GWLifeStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.sampleRights,
  });
}

/// Mock content จาก G-Wealth Infographic + G-Wealth_fn.pdf
class GWData {
  GWData._();

  static const services = <GWServiceItem>[
    GWServiceItem(
      id: 'register',
      title: 'ลงทะเบียน',
      icon: Icons.assignment_outlined,
      route: 'register',
    ),
    GWServiceItem(
      id: 'rights',
      title: 'ตรวจสอบสิทธิ์',
      icon: Icons.manage_search_outlined,
      route: 'rights',
    ),
    GWServiceItem(
      id: 'announce',
      title: 'ประชาสัมพันธ์',
      icon: Icons.campaign_outlined,
      route: 'news',
    ),
    GWServiceItem(
      id: 'knowledge',
      title: 'คลังความรู้',
      icon: Icons.menu_book_outlined,
      route: 'knowledge',
    ),
    GWServiceItem(
      id: 'welfare',
      title: 'สวัสดิการ',
      icon: Icons.volunteer_activism_outlined,
      route: 'welfare',
    ),
    GWServiceItem(
      id: 'survey',
      title: 'สำรวจ',
      icon: Icons.how_to_vote_outlined,
      route: 'survey',
    ),
    GWServiceItem(
      id: 'alert',
      title: 'แจ้งเหตุ',
      icon: Icons.warning_amber_rounded,
      route: 'alert',
    ),
    GWServiceItem(
      id: 'contact',
      title: 'ติดต่อ',
      icon: Icons.phone_in_talk_outlined,
      route: 'contact',
    ),
  ];

  static const lifeStages = <GWLifeStage>[
    GWLifeStage(
      id: 'child',
      title: 'แรกเกิด / เด็ก',
      subtitle: 'เงินอุดหนุน · วัคซีน',
      icon: Icons.child_friendly_outlined,
      color: Color(0xFFE84090),
      sampleRights: ['เงินอุดหนุนเด็กแรกเกิด', 'สิทธิ์วัคซีนพื้นฐาน'],
    ),
    GWLifeStage(
      id: 'youth',
      title: 'เยาวชน / ศึกษา',
      subtitle: 'เรียนฟรี · กองทุน',
      icon: Icons.school_outlined,
      color: Color(0xFFA855F7),
      sampleRights: ['สิทธิ์เรียนฟรี 15 ปี', 'กองทุนการศึกษา'],
    ),
    GWLifeStage(
      id: 'work',
      title: 'วัยทำงาน',
      subtitle: 'ประกันสังคม · อาชีพ',
      icon: Icons.work_outline,
      color: Color(0xFF7C3AED),
      sampleRights: ['สิทธิ์ประกันสังคม', 'การฝึกอาชีพ', 'สินเชื่อที่อยู่อาศัย'],
    ),
    GWLifeStage(
      id: 'elder',
      title: 'ผู้สูงอายุ',
      subtitle: 'เบี้ยยังชีพ · ที่อยู่อาศัย',
      icon: Icons.elderly_outlined,
      color: Color(0xFF3B82F6),
      sampleRights: ['เบี้ยยังชีพผู้สูงอายุ', 'สิทธิ์ปรับสภาพที่อยู่อาศัย'],
    ),
  ];

  static const dimensions = [
    ('สุขภาพ', Icons.medical_services_outlined, Color(0xFFE84090)),
    ('การศึกษา', Icons.school_outlined, Color(0xFFA855F7)),
    ('การเดินทาง', Icons.directions_bus_outlined, Color(0xFF7C3AED)),
    ('แรงงาน', Icons.engineering_outlined, Color(0xFF3B82F6)),
    ('การเงิน', Icons.account_balance_wallet_outlined, Color(0xFF06B6D4)),
  ];

  static const benefits = <GWBenefit>[
    GWBenefit(
      id: 'b1',
      title: 'เงินอุดหนุนบุตรแรกเกิด',
      agency: 'พม. / กรมกิจการเด็กและเยาวชน',
      lifeStage: 'child',
      dimension: 'การเงิน',
      amount: '600 บาท/เดือน',
      status: 'eligible',
      description:
          'AI พบว่าคุณมีคุณสมบัติรับเงินอุดหนุนบุตรแรกเกิด กดยืนยันเพื่อดำเนินการต่อ',
    ),
    GWBenefit(
      id: 'b2',
      title: 'สิทธิ์ประกันสังคม มาตรา 33',
      agency: 'สำนักงานประกันสังคม',
      lifeStage: 'work',
      dimension: 'แรงงาน',
      amount: 'ตามสิทธิ์',
      status: 'claimed',
      description: 'คุณอยู่ในระบบประกันสังคมแล้ว ตรวจสอบสิทธิ์การรักษาได้ทันที',
    ),
    GWBenefit(
      id: 'b3',
      title: 'กองทุนเงินให้กู้ยืมเพื่อการศึกษา',
      agency: 'กองทุน กยศ.',
      lifeStage: 'youth',
      dimension: 'การศึกษา',
      amount: 'ตามหลักสูตร',
      status: 'hidden',
      description: 'สิทธิ์ที่อาจตกหล่น — กองทุนการศึกษาสำหรับผู้มีรายได้น้อย',
    ),
    GWBenefit(
      id: 'b4',
      title: 'เบี้ยยังชีพผู้สูงอายุ',
      agency: 'องค์กรปกครองส่วนท้องถิ่น',
      lifeStage: 'elder',
      dimension: 'การเงิน',
      amount: '600–1,000 บาท/เดือน',
      status: 'pending',
      description: 'รอตรวจสอบคุณสมบัติตามช่วงอายุและสถานะทางทะเบียน',
    ),
    GWBenefit(
      id: 'b5',
      title: 'ส่วนลดค่าโดยสารขนส่งสาธารณะ',
      agency: 'กระทรวงคมนาคม',
      lifeStage: 'work',
      dimension: 'การเดินทาง',
      amount: 'ตามบัตรสิทธิ์',
      status: 'eligible',
      description: 'สิทธิ์อุดหนุนค่าโดยสารสำหรับกลุ่มเปราะบางและผู้สูงอายุ',
    ),
  ];

  static const news = <GWNewsItem>[
    GWNewsItem(
      id: 'n1',
      title: 'พม. เปิดตัว G-Wealth ศูนย์กลางสวัสดิการแห่งรัฐ',
      summary:
          'เชื่อมโยงข้อมูลจาก 20 กระทรวง เป็น Single Source of Truth เพื่อประชาชน 70 ล้านคน',
      date: '3 ก.ย. 2569',
      category: 'ข่าวประชาสัมพันธ์',
      accent: GW.primary,
    ),
    GWNewsItem(
      id: 'n2',
      title: 'AI ค้นหาสิทธิ์เชิงรุก — ไม่ต้องรอร้องขอ',
      summary:
          'ระบบ Personalized Benefit Analysis แจ้งเตือนสิทธิ์ใหม่ถึงสมาร์ทโฟนอัตโนมัติ',
      date: '1 ก.ย. 2569',
      category: 'เทคโนโลยี',
      accent: GW.accentPurple,
    ),
    GWNewsItem(
      id: 'n3',
      title: 'เส้นทางสิทธิ์แห่งชีวิต: จากแรกเกิดถึงผู้สูงอายุ',
      summary:
          'ครอบคลุมเงินอุดหนุน เรียนฟรี ประกันสังคม และเบี้ยยังชีพในที่เดียว',
      date: '28 ส.ค. 2569',
      category: 'ความรู้',
      accent: GW.accentBlue,
    ),
  ];

  static const banners = [
    {
      'code': 'gw1',
      'title': 'G-Wealth Government Hub',
      'subtitle': 'ศูนย์กลางสวัสดิการแห่งรัฐ · ประชาชน 70 ล้านคน',
      'color': 0xFFE84090,
    },
    {
      'code': 'gw2',
      'title': 'ตรวจสอบสิทธิ์ด้วย AI',
      'subtitle': 'Personalized Benefit Analysis ตลอด 24 ชั่วโมง',
      'color': 0xFF7C3AED,
    },
    {
      'code': 'gw3',
      'title': 'แชทบอทอัจฉริยะ',
      'subtitle': 'ปรึกษาด้านสวัสดิการอัตโนมัติ ไม่ต้องต่อคิว',
      'color': 0xFF3B82F6,
    },
  ];

  static const chatbotReplies = <String, String>{
    'สวัสดี':
        'สวัสดีค่ะ ยินดีต้อนรับสู่ G-Wealth แชทบอทอัจฉริยะ พร้อมช่วยตรวจสอบสิทธิ์สวัสดิการและให้คำปรึกษาตลอด 24 ชั่วโมงค่ะ',
    'สิทธิ์':
        'จากข้อมูลของคุณ ระบบพบสิทธิ์ที่อาจได้รับ เช่น เงินอุดหนุนบุตรแรกเกิด และส่วนลดค่าโดยสาร คุณต้องการให้ช่วยตรวจสอบรายละเอียดข้อใดคะ?',
    'เบี้ยยังชีพ':
        'เบี้ยยังชีพผู้สูงอายุจ่ายผ่าน อปท. ตามช่วงอายุ โดยทั่วไปอายุ 60 ปีขึ้นไป คุณสามารถกดเมนู “ตรวจสอบสิทธิ์” เพื่อยืนยันคุณสมบัติได้ค่ะ',
    'default':
        'รับทราบค่ะ ขณะนี้ G-Wealth กำลังวิเคราะห์ข้อมูลสิทธิ์จาก Government Hub ให้คุณ หากต้องการตรวจสอบสิทธิ์เฉพาะบุคคล พิมพ์ “สิทธิ์” หรือเลือกเมนูตรวจสอบสิทธิ์ได้เลยค่ะ',
  };
}
