import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/config/env_config.dart';
import 'package:flutter_pernit/core/di/dependency_injection.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/core/network/websocket/notification_web_socket_service.dart';
import 'package:flutter_pernit/core/network/websocket/ws_connection_status.dart';
import 'package:flutter_pernit/core/network/websocket/ws_notification_event.dart';
import 'package:flutter_pernit/core/notifications/notification_lifecycle_coordinator.dart';
import 'package:flutter_pernit/core/notifications/notification_router.dart';
import 'package:flutter_pernit/core/notifications/push_notification_service.dart';
import 'package:flutter_pernit/design_system/tokens/pernit_colors.dart';
import 'package:flutter_pernit/design_system/tokens/pernit_text_theme.dart';
import 'package:flutter_pernit/features/notifications/domain/entities/notification_page.dart';
import 'package:flutter_pernit/features/notifications/domain/repos/notifications_repository.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/register_push_device_use_case.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/unregister_push_device_use_case.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_pernit/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_pernit/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/logout_cubit.dart';
import 'package:flutter_pernit/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/inventory_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/usecases/raw_material_entry_use_cases.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_entry_cubit.dart';

void main() {
  const adminUser = AuthUser(
    id: 1,
    username: 'admin',
    email: 'admin@example.com',
    firstName: 'Ahmed',
    lastName: 'Hassan',
    groups: ['System Admin'],
  );

  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('wide home layout shows branded side menu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpHome(adminUser);

    expect(find.text('Pernit ERP'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('mobile home layout uses compact bottom menu', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpHome(adminUser);

    expect(find.text('Pernit ERP'), findsNothing);
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
    expect(find.text('Overview'), findsWidgets);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });

  testWidgets('raw entry section opens the API-backed raw material screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _FakeRawMaterialEntryRepository(
      const ApiSuccess([
        RawMaterialEntry(
          id: 12,
          rawMaterialId: 7,
          purchaseOrderDetailId: null,
          warehouseId: 3,
          rawMaterialName: 'Home Corn',
          supplierName: 'Home Supplier',
          quantityFromSupplier: 20,
          unitName: 'ton',
          warehouseName: 'Main Warehouse',
          status: RawMaterialEntryStatus.arrived,
          isSampled: false,
          isLabDone: false,
          isQcDone: false,
          isInStock: false,
          acceptedQuantity: null,
          rejectedQuantity: null,
          availableQuantity: null,
          measuredQuantity: null,
          vehicleNo: null,
          driverName: null,
          lotNo: null,
          expiryDate: null,
          createdAt: null,
        ),
      ]),
    );
    sl.registerFactory<RawMaterialEntryCubit>(
      () => RawMaterialEntryCubit(
        LoadRawMaterialEntriesUseCase(repository),
        LoadRawMaterialEntryLookupsUseCase(repository),
        CreateRawMaterialEntryUseCase(repository),
      ),
    );

    await tester.pumpHome(adminUser);

    await tester.tap(find.text('Raw entry').first);
    await tester.pumpAndSettle();

    expect(repository.entryCalls, 1);
    expect(repository.lookupCalls, 1);
    expect(find.text('Home Corn'), findsOneWidget);
    expect(find.textContaining('Home Supplier'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpHome(AuthUser user) async {
    sl.registerLazySingleton<NotificationWebSocketService>(
      () => _FakeWsService(),
    );
    await pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        splitScreenMode: true,
        builder: (context, child) {
          final textTheme = PernitTextTheme.build();

          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: PernitTextTheme.cairoFontFamily,
              textTheme: textTheme,
              colorScheme: ColorScheme.fromSeed(
                seedColor: PernitColors.primary,
              ),
            ),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: BlocProvider(
              create: (_) => LogoutCubit(
                LogoutUseCase(_FakeAuthRepository()),
                AuthSessionCubit(RestoreSessionUseCase(_FakeAuthRepository())),
                _FakeNotificationLifecycleCoordinator(),
              ),
              child: HomeScreen(user: user),
            ),
          );
        },
      ),
    );
  }
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

class _FakeRawMaterialEntryRepository implements RawMaterialEntryRepository {
  final ApiResult<List<RawMaterialEntry>> result;
  var entryCalls = 0;
  var lookupCalls = 0;

  _FakeRawMaterialEntryRepository(this.result);

  @override
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) async {
    entryCalls++;
    return result;
  }

  @override
  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups() async {
    lookupCalls++;
    return const ApiSuccess(RawMaterialEntryLookups());
  }

  @override
  Future<ApiResult<RawMaterialEntry>> createEntry(RawMaterialEntryDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchPurchaseOrderDetails({
    String? search,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchRawMaterials({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchWarehouses({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> fetchAnalysisWorkspace(
    int sampleId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> submitAnalysis({
    required int sampleId,
    required RawMaterialAnalysisSubmission submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<bool>> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialSample>> takeSample(int batchId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialSamplePage>> fetchSamples({
    int? batchId,
    required int page,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ProductStockPage>> fetchProductStock({required int page}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ProductStockItem>> addProductStock(ProductStockDraft draft) {
    throw UnimplementedError();
  }
}

class _FakeNotificationLifecycleCoordinator
    extends NotificationLifecycleCoordinator {
  _FakeNotificationLifecycleCoordinator()
    : super(
        _FakePushNotificationService(),
        _FakeRegisterPushDeviceUseCase(),
        _FakeUnregisterPushDeviceUseCase(),
        _FakeWsService(),
        NotificationRouter(),
        EnvConfig.instance,
      );
}

class _FakePushNotificationService implements PushNotificationService {
  @override
  Future<NotificationSettings> requestPermission() async {
    return const NotificationSettings(
      alert: AppleNotificationSetting.notSupported,
      announcement: AppleNotificationSetting.notSupported,
      authorizationStatus: AuthorizationStatus.notDetermined,
      badge: AppleNotificationSetting.notSupported,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.notSupported,
      notificationCenter: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
      showPreviews: AppleShowPreviewSetting.notSupported,
      sound: AppleNotificationSetting.notSupported,
      timeSensitive: AppleNotificationSetting.notSupported,
    );
  }

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> deleteToken() async {}

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;
}

class _FakeRegisterPushDeviceUseCase extends RegisterPushDeviceUseCase {
  _FakeRegisterPushDeviceUseCase() : super(_FakeNotificationsRepository());
}

class _FakeUnregisterPushDeviceUseCase extends UnregisterPushDeviceUseCase {
  _FakeUnregisterPushDeviceUseCase() : super(_FakeNotificationsRepository());
}

class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<ApiResult<NotificationPage>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return const ApiSuccess(
      NotificationPage(items: [], totalCount: 0, hasMore: false),
    );
  }

  @override
  Future<ApiResult<int>> getUnreadCount() async {
    return const ApiSuccess(0);
  }

  @override
  Future<ApiResult<void>> markRead(int notificationId) async {
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> markAllRead() async {
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> registerPushDevice({
    required String token,
    required String platform,
    required String environment,
    required String locale,
    required String timezone,
  }) async {
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> unregisterPushDevice(String token) async {
    return const ApiSuccess(null);
  }
}
