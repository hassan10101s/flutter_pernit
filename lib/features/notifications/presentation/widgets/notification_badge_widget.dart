import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/network/websocket/notification_web_socket_service.dart';
import '../../../../core/network/websocket/ws_notification_event.dart';
import '../../../../design_system/tokens/pernit_colors.dart';

class NotificationBadgeWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const NotificationBadgeWidget({super.key, this.onTap});

  @override
  State<NotificationBadgeWidget> createState() =>
      _NotificationBadgeWidgetState();
}

class _NotificationBadgeWidgetState extends State<NotificationBadgeWidget> {
  int _unreadCount = 0;
  StreamSubscription<WsNotificationEvent>? _sub;
  late final NotificationWebSocketService _service;

  @override
  void initState() {
    super.initState();
    _service = sl<NotificationWebSocketService>();
    _sub = _service.events.listen(_onEvent);
    _service.getUnreadCount();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(WsNotificationEvent event) {
    if (!mounted) return;
    setState(() {
      switch (event) {
        case InitialNotifications e:
          _unreadCount = e.unreadCount;
        case UnreadCountEvent e:
          _unreadCount = e.count;
        case NewNotificationEvent _:
          _unreadCount++;
        case AllReadConfirmed e:
          _unreadCount = e.unreadCount;
        case ReadConfirmed e:
          if (e.success && _unreadCount > 0) _unreadCount--;
        case NotificationsListEvent _:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: AppLocalizations.of(context)!.notificationButton,
          onPressed: widget.onTap,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: PernitColors.danger,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
