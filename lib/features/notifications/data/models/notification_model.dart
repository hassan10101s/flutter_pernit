import '../../domain/entities/notification.dart' as domain;

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String? referenceType;
  final String? referenceId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    this.referenceType,
    this.referenceId,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = (rawId is int)
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final typeValue =
        json['notification_type'] as String? ??
        json['type'] as String? ??
        'info';

    return NotificationModel(
      id: id,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      notificationType: typeValue,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id']?.toString(),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  domain.Notification toEntity() {
    return domain.Notification(
      id: id,
      title: title,
      message: message,
      notificationType: domain.NotificationType.fromJson(notificationType),
      referenceType: domain.NotificationReferenceType.fromJson(referenceType),
      referenceId: referenceId,
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt,
      metadata: metadata,
    );
  }
}
