import 'package:LawyerOnline/gwealth/data/mock_data.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';

/// แชทบอทอัจฉริยะ 24 ชม. — reuse รูปแบบแชทจากโปรเจคเดิมแบบเบา
class GWChatbotPage extends StatefulWidget {
  const GWChatbotPage({super.key});

  @override
  State<GWChatbotPage> createState() => _GWChatbotPageState();
}

class _GWChatbotPageState extends State<GWChatbotPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(
      text:
          'สวัสดีค่ะ ฉันคือแชทบอทอัจฉริยะของ G-Wealth พร้อมให้คำปรึกษาด้านสวัสดิการตลอด 24 ชั่วโมง\n\nลองพิมพ์ “สิทธิ์” หรือ “เบี้ยยังชีพ” ได้เลยค่ะ',
      isBot: true,
    ),
  ];
  bool _typing = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_Msg(text: text, isBot: false));
      _typing = true;
    });
    _jump();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final reply = _replyFor(text);
    setState(() {
      _typing = false;
      _messages.add(_Msg(text: reply, isBot: true));
    });
    _jump();
  }

  String _replyFor(String input) {
    final lower = input.toLowerCase();
    for (final entry in GWData.chatbotReplies.entries) {
      if (entry.key == 'default') continue;
      if (lower.contains(entry.key.toLowerCase())) return entry.value;
    }
    return GWData.chatbotReplies['default']!;
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(
        title: 'แชทบอทอัจฉริยะ',
        subtitle: 'บริการอัตโนมัติ 24 ชั่วโมง',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, i) {
                if (_typing && i == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: _Bubble(
                        text: 'กำลังพิมพ์...',
                        isBot: true,
                        muted: true,
                      ),
                    ),
                  );
                }
                final m = _messages[i];
                return Align(
                  alignment:
                      m.isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Bubble(text: m.text, isBot: m.isBot),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['สวัสดี', 'สิทธิ์', 'เบี้ยยังชีพ', 'ช่วยเหลือ']
                  .map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(q, style: GW.text(size: 12)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: GW.border),
                        onPressed: () => _send(q),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GW.text(size: 14),
                      decoration: InputDecoration(
                        hintText: 'ถามเรื่องสวัสดิการ...',
                        hintStyle: GW.text(size: 14, color: GW.inkLight),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: GW.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: GW.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: GW.primary),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: GW.primary,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => _send(),
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isBot;
  _Msg({required this.text, required this.isBot});
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final bool muted;

  const _Bubble({
    required this.text,
    required this.isBot,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : GW.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 4 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 4),
          ),
          border: isBot ? Border.all(color: GW.border) : null,
        ),
        child: Text(
          text,
          style: GW.text(
            size: 14,
            color: isBot
                ? (muted ? GW.inkMuted : GW.ink)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
