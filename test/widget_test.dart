import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/core/network/websocket/notification_web_socket_service.dart';
import 'package:flutter_pernit/core/network/websocket/ws_connection_status.dart';
import 'package:flutter_pernit/core/network/websocket/ws_notification_event.dart';
import 'package:flutter_pernit/features/auth/data/models/login_response_model.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_pernit/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_pernit/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/login_use_case.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:flutter_pernit/features/auth/domain/validators/login_validator.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/login_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('login screen renders required inputs', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        builder: (context, child) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider(
            create: (_) => LoginCubit(
              LoginUseCase(_FakeAuthRepository(), const LoginValidator()),
              AuthSessionCubit(_FakeRestoreSessionUseCase(), _FakeWsService()),
            ),
            child: const LoginScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  test('login response maps user groups', () {
    final model = LoginResponseModel.fromJson(const {
      'access_token': 'access',
      'refresh_token': 'refresh',
      'user': {
        'id': 1,
        'username': 'admin',
        'email': 'admin@example.com',
        'first_name': 'Ahmed',
        'last_name': 'Hassan',
        'groups': ['Standard User'],
      },
    });

    final session = model.toEntity();

    expect(session.accessToken, 'access');
    expect(session.refreshToken, 'refresh');
    expect(session.user.displayName, 'Ahmed Hassan');
    expect(session.user.groups, ['Standard User']);
  });
}

class _FakeWsService implements NotificationWebSocketService {
  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void dispose() {}

  @override
  Stream<WsNotificationEvent> get events => const Stream.empty();

  @override
  Stream<WsConnectionStatus> get connectionStatus => const Stream.empty();

  @override
  WsConnectionStatus get currentStatus => WsConnectionStatus.disconnected;

  @override
  void manualReconnect() {}

  @override
  void markRead(int notificationId) {}

  @override
  void markAllRead() {}

  @override
  void getUnreadCount() {}

  @override
  void getNotifications({int limit = 20, int offset = 0}) {}
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<AuthSession>> login(LoginCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<ApiResult<AuthSession>> restoreSession() {
    throw UnimplementedError();
  }
}

class _FakeRestoreSessionUseCase extends RestoreSessionUseCase {
  _FakeRestoreSessionUseCase() : super(_FakeAuthRepository());
}
