import 'notification_model.dart';

class NotificationPageModel {
  final List<NotificationModel> items;
  final int totalCount;
  final bool hasMore;

  const NotificationPageModel({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });

  factory NotificationPageModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('results') && json.containsKey('count')) {
      final results = json['results'] as List<dynamic>? ?? [];
      final count = json['count'] as int? ?? 0;
      final next = json['next'];
      return NotificationPageModel(
        items: results
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList(),
        totalCount: count,
        hasMore: next != null,
      );
    }

    final notifications = json['notifications'] as List<dynamic>?;
    if (notifications != null) {
      return NotificationPageModel(
        items: notifications
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList(),
        totalCount: json['count'] as int? ?? notifications.length,
        hasMore: json['next'] != null || notifications.length >= 20,
      );
    }

    throw ArgumentError('Unexpected notification response format: $json');
  }
}
