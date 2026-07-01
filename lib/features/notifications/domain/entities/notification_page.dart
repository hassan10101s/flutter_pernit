import 'package:equatable/equatable.dart';

import 'notification.dart';

class NotificationPage extends Equatable {
  final List<Notification> items;
  final int totalCount;
  final bool hasMore;

  const NotificationPage({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, totalCount, hasMore];
}
