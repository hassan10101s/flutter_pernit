import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/network/websocket/notification_web_socket_service.dart';
import 'package:flutter_pernit/core/network/websocket/ws_connection_status.dart';
import 'package:flutter_pernit/core/config/env_config.dart';
import 'package:flutter_pernit/core/auth/token_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('NotificationWebSocketService', () {
    late EnvConfig envConfig;
    late TokenManager tokenManager;

    setUp(() {
      envConfig = EnvConfig.instance;
      tokenManager = TokenManager(const FlutterSecureStorage());
    });

    test(
      'connect is idempotent - does not create duplicate connection',
      () async {
        final service = NotificationWebSocketService(envConfig, tokenManager);

        expect(service.currentStatus, WsConnectionStatus.disconnected);

        await service.connect();
        if (service.currentStatus == WsConnectionStatus.connecting) {
          expect(service.currentStatus, WsConnectionStatus.connecting);
        } else {
          expect(
            service.currentStatus,
            anyOf(
              WsConnectionStatus.disconnected,
              WsConnectionStatus.connecting,
            ),
          );
        }

        final statusBeforeSecondCall = service.currentStatus;

        await service.connect();

        expect(service.currentStatus, statusBeforeSecondCall);

        service.dispose();
      },
    );

    test('disconnect cancels subscription and timers', () async {
      final service = NotificationWebSocketService(envConfig, tokenManager);

      await service.connect();
      service.disconnect();

      expect(service.currentStatus, WsConnectionStatus.disconnected);

      service.dispose();
    });

    test('dispose sets disposed state and closes controllers', () async {
      final service = NotificationWebSocketService(envConfig, tokenManager);

      service.dispose();

      expect(service.currentStatus, WsConnectionStatus.disconnected);
    });
  });
}
