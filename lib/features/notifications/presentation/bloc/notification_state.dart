import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/notification.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  final int unreadCount;
  final int totalCount;
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
    this.isLoadingMore = false,
  });

  NotificationLoaded copyWith({
    List<Notification>? notifications,
    int? unreadCount,
    int? totalCount,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        totalCount,
        isLoadingMore,
      ];
}

final class NotificationError extends NotificationState {
  final Failure failure;

  const NotificationError(this.failure);

  @override
  List<Object?> get props => [failure];
}
