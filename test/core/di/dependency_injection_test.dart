import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/auth/token_manager.dart';
import 'package:flutter_pernit/core/di/dependency_injection.dart';
import 'package:flutter_pernit/core/notifications/notification_lifecycle_coordinator.dart';
import 'package:flutter_pernit/core/notifications/push_notification_service.dart';
import 'package:flutter_pernit/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/login_cubit.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_entry_cubit.dart';

void main() {
  tearDown(() async {
    await sl.reset();
  });

  test('auth graph resolves registered dependencies', () {
    configureDependencies();

    expect(sl<TokenStore>(), same(sl<TokenManager>()));
    expect(sl<AuthRepository>(), isA<AuthRepository>());
    expect(sl<RawMaterialEntryRepository>(), isA<RawMaterialEntryRepository>());
    expect(sl<LoginCubit>(), isA<LoginCubit>());
    expect(sl<AuthSessionCubit>(), isA<AuthSessionCubit>());
    expect(sl<RawMaterialEntryCubit>(), isA<RawMaterialEntryCubit>());
    expect(sl<PushNotificationService>(), isA<PushNotificationService>());
    expect(
      sl<NotificationLifecycleCoordinator>(),
      isA<NotificationLifecycleCoordinator>(),
    );
  });
}
