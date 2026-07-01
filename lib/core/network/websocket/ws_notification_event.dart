import 'package:equatable/equatable.dart';

import '../../../features/notifications/domain/entities/notification.dart';

sealed class WsNotificationEvent extends Equatable {
  const WsNotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitialNotifications extends WsNotificationEvent {
  final int unreadCount;
  final List<Notification> notifications;

  const InitialNotifications({
    required this.unreadCount,
    required this.notifications,
  });

  @override
  List<Object?> get props => [unreadCount, notifications];
}

class NewNotificationEvent extends WsNotificationEvent {
  final Notification notification;

  const NewNotificationEvent({required this.notification});

  @override
  List<Object?> get props => [notification];
}

class ReadConfirmed extends WsNotificationEvent {
  final int notificationId;
  final bool success;
  final Notification? notification;

  const ReadConfirmed({
    required this.notificationId,
    required this.success,
    this.notification,
  });

  @override
  List<Object?> get props => [notificationId, success, notification];
}

class AllReadConfirmed extends WsNotificationEvent {
  final int count;
  final int unreadCount;

  const AllReadConfirmed({required this.count, required this.unreadCount});

  @override
  List<Object?> get props => [count, unreadCount];
}

class UnreadCountEvent extends WsNotificationEvent {
  final int count;

  const UnreadCountEvent({required this.count});

  @override
  List<Object?> get props => [count];
}

class NotificationsListEvent extends WsNotificationEvent {
  final List<Notification> notifications;
  final int count;

  const NotificationsListEvent({
    required this.notifications,
    required this.count,
  });

  @override
  List<Object?> get props => [notifications, count];
}
