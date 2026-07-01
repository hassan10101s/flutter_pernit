import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/features/notifications/data/models/push_device_registration_model.dart';

void main() {
  group('PushDeviceRegistrationRequest', () {
    test('toJson produces correct map', () {
      final request = PushDeviceRegistrationRequest(
        token: 'fcm-token-123',
        platform: 'android',
        environment: 'dev',
        locale: 'ar',
        timezone: 'UTC+02:00',
      );

      final json = request.toJson();

      expect(json['token'], 'fcm-token-123');
      expect(json['platform'], 'android');
      expect(json['environment'], 'dev');
      expect(json['locale'], 'ar');
      expect(json['timezone'], 'UTC+02:00');
    });
  });

  group('PushDeviceRegistrationResponse', () {
    test('fromJson parses response correctly', () {
      final json = {
        'id': 'dev-001',
        'token_preview': 'fcm-t***',
        'platform': 'android',
        'is_active': true,
      };

      final response = PushDeviceRegistrationResponse.fromJson(json);

      expect(response.id, 'dev-001');
      expect(response.tokenPreview, 'fcm-t***');
      expect(response.platform, 'android');
      expect(response.isActive, true);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final response = PushDeviceRegistrationResponse.fromJson(json);

      expect(response.id, '');
      expect(response.tokenPreview, isNull);
      expect(response.platform, '');
      expect(response.isActive, true);
    });
  });
}
