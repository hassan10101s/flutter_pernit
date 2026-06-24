import 'package:equatable/equatable.dart';

enum NotificationType {
  info,
  success,
  warning,
  error;

  static NotificationType fromJson(String value) {
    return switch (value) {
      'success' => NotificationType.success,
      'warning' => NotificationType.warning,
      'error' => NotificationType.error,
      _ => NotificationType.info,
    };
  }
}

enum NotificationReferenceType {
  receivedRawMaterial,
  qualityCheck,
  productionOrder,
  salesOrder,
  labSample,
  inventoryMovement;

  static NotificationReferenceType? fromJson(String? value) {
    if (value == null || value.isEmpty) return null;
    return switch (value) {
      'received_raw_material' => NotificationReferenceType.receivedRawMaterial,
      'quality_check' => NotificationReferenceType.qualityCheck,
      'production_order' => NotificationReferenceType.productionOrder,
      'sales_order' => NotificationReferenceType.salesOrder,
      'lab_sample' => NotificationReferenceType.labSample,
      'inventory_movement' => NotificationReferenceType.inventoryMovement,
      _ => null,
    };
  }
}

class Notification extends Equatable {
  final int id;
  final String title;
  final String message;
  final NotificationType notificationType;
  final NotificationReferenceType? referenceType;
  final String? referenceId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const Notification({
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

  factory Notification.fromJson(Map<String, dynamic> json) {
    final typeValue = json['notification_type'] as String?
        ?? json['type'] as String?
        ?? 'info';

    return Notification(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      notificationType: NotificationType.fromJson(typeValue),
      referenceType: NotificationReferenceType.fromJson(
        json['reference_type'] as String?,
      ),
      referenceId: json['reference_id']?.toString(),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Notification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return Notification(
      id: id,
      title: title,
      message: message,
      notificationType: notificationType,
      referenceType: referenceType,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        notificationType,
        referenceType,
        referenceId,
        isRead,
        readAt,
        createdAt,
        metadata,
      ];
}
