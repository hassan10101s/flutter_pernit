import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/notifications/domain/entities/notification.dart'
    as domain;

class NotificationPayload {
  final int id;
  final String title;
  final String message;
  final domain.NotificationType notificationType;
  final domain.NotificationReferenceType? referenceType;
  final String? referenceId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationPayload({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    this.referenceType,
    this.referenceId,
    required this.createdAt,
    this.metadata,
  });

  static NotificationPayload? fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return null;

    final id = int.tryParse(data['id'] ?? '');
    if (id == null) return null;

    return NotificationPayload(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? data['body'] ?? '',
      notificationType: domain.NotificationType.fromJson(
        data['notification_type'] ?? 'info',
      ),
      referenceType: domain.NotificationReferenceType.fromJson(
        data['reference_type'],
      ),
      referenceId: data['reference_id']?.toString(),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      metadata: _parseMetadata(data['metadata']),
    );
  }

  static Map<String, dynamic>? _parseMetadata(dynamic value) {
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return null;
  }

  static NotificationPayload? fromMap(Map<String, dynamic> data) {
    final id = int.tryParse(data['id'] ?? '');
    if (id == null) return null;

    return NotificationPayload(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      notificationType: domain.NotificationType.fromJson(
        data['notification_type'] ?? 'info',
      ),
      referenceType: domain.NotificationReferenceType.fromJson(
        data['reference_type'],
      ),
      referenceId: data['reference_id']?.toString(),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      metadata: _parseMetadata(data['metadata']),
    );
  }

  domain.Notification toEntity() {
    return domain.Notification(
      id: id,
      title: title,
      message: message,
      notificationType: notificationType,
      referenceType: referenceType,
      referenceId: referenceId,
      createdAt: createdAt,
      metadata: metadata,
    );
  }
}
