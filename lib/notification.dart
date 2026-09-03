import 'package:LawyerOnline/component/loading_service.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:LawyerOnline/notification-detail.dart';
import 'package:LawyerOnline/services/notification_list_service.dart';
import 'package:LawyerOnline/services/notification_navigation_service.dart';
import 'package:LawyerOnline/shared/api_provider.dart';
import 'package:LawyerOnline/shared/notification_store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

List<Map<String, dynamic>> globalNotifications = [];

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  int get unreadCount =>
      _notifications.where((n) => n['isRead'] != true).length;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await NotificationListService.load();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    if (_notifications.isEmpty) return;
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
    await NotificationStore.instance.markAllRead();
    await NotificationStore.instance.refresh();
  }

  Future<void> _markOneRead(Map<String, dynamic> item) async {
    if (item['isRead'] == true) return;
    setState(() => item['isRead'] = true);
    final code = item['code']?.toString();
    if (code != null && code.isNotEmpty) {
      try {
        await postDio('$server/m/notification/markRead', {'code': code});
        await NotificationStore.instance.refresh();
      } catch (_) {}
    }
  }

  Future<void> _openItem(Map<String, dynamic> item) async {
    await _markOneRead(item);
    if (!mounted) return;

    if (NotificationNavigationService.canNavigate(item)) {
      final ok = await NotificationNavigationService.handle(context, item);
      if (ok) return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailPage(data: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: GWAppBar(
        title: 'notifications'.tr(),
        showBack: false,
        actions: unreadCount > 0
            ? [
                Material(
                  color: GW.primarySoft,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _markAllRead,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.done_all_rounded,
                          size: 18, color: GW.primary),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? AppLoadingView(message: 'loading'.tr())
          : RefreshIndicator(
              color: GW.primary,
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.notifications_none_rounded,
                            size: 64, color: GW.primaryMute),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'ยังไม่มีการแจ้งเตือน',
                            style: GW.text(size: 14, color: GW.inkMuted),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = _notifications[i];
                        final unread = item['isRead'] != true;
                        final title = item['title']?.toString() ?? 'แจ้งเตือน';
                        final body = item['body']?.toString() ?? '';
                        final time = item['displayTime']?.toString() ??
                            item['createDate']?.toString() ??
                            '';

                        return InkWell(
                          onTap: () => _openItem(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: unread
                                    ? GW.primary.withValues(alpha: 0.35)
                                    : GW.border,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: GW.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: GW.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: GW.text(
                                                size: 14,
                                                weight: unread
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (unread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: GW.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (body.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GW.text(
                                              size: 12, color: GW.inkMuted),
                                        ),
                                      ],
                                      if (time.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          time,
                                          style: GW.text(
                                              size: 11, color: GW.inkLight),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
