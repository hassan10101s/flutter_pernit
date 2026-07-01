import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repos/auth_repository_impl.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/restore_session_use_case.dart';
import '../../features/auth/domain/validators/login_validator.dart';
import '../../features/auth/presentation/bloc/auth_session_cubit.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/bloc/logout_cubit.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repos/notifications_repository_impl.dart';
import '../../features/notifications/domain/repos/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_unread_count_use_case.dart';
import '../../features/notifications/domain/usecases/load_notifications_use_case.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import '../../features/notifications/domain/usecases/register_push_device_use_case.dart';
import '../../features/notifications/domain/usecases/unregister_push_device_use_case.dart';
import '../../features/notifications/presentation/bloc/notification_cubit.dart';
import '../../features/raw_material_entry/data/datasources/raw_material_entry_remote_data_source.dart';
import '../../features/raw_material_entry/data/repos/raw_material_entry_repository_impl.dart';
import '../../features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import '../../features/raw_material_entry/domain/usecases/raw_material_entry_use_cases.dart';
import '../../features/raw_material_entry/domain/usecases/raw_material_workflow_use_cases.dart';
import '../../features/raw_material_entry/presentation/bloc/raw_material_entry_cubit.dart';
import '../../features/raw_material_entry/presentation/bloc/raw_material_inventory_cubit.dart';
import '../../features/quality/data/datasources/production_quality_remote_data_source.dart';
import '../../features/quality/data/repos/production_quality_repository_impl.dart';
import '../../features/quality/domain/repos/production_quality_repository.dart';
import '../../features/quality/domain/usecases/create_production_lab_result_use_case.dart';
import '../../features/quality/domain/usecases/create_production_lab_sample_use_case.dart';
import '../../features/quality/domain/usecases/load_production_lab_results_use_case.dart';
import '../../features/quality/domain/usecases/load_production_lab_samples_use_case.dart';
import '../../features/quality/domain/usecases/load_production_quality_checks_use_case.dart';
import '../../features/quality/presentation/bloc/production_quality_cubit.dart';
import '../../features/raw_material_entry/presentation/bloc/raw_material_quality_cubit.dart';
import '../../features/raw_material_entry/presentation/bloc/product_inventory_cubit.dart';
import '../../features/screen_records/data/datasources/screen_record_remote_data_source.dart';
import '../../features/screen_records/data/repos/screen_record_repository_dependencies.dart';
import '../auth/auth_interceptor.dart';
import '../auth/refresh_mutex.dart';
import '../auth/token_manager.dart';
import '../auth/token_refresh_gateway.dart';
import '../config/env_config.dart';
import '../errors/api_error_handler.dart';
import '../network/connection_checker.dart';
import '../network/public_dio_factory.dart';
import '../network/secure_dio_factory.dart';
import '../network/websocket/notification_web_socket_service.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/notification_lifecycle_coordinator.dart';
import '../notifications/notification_router.dart';
import '../notifications/push_notification_service.dart';
import '../routing/app_router.dart';

final sl = GetIt.instance;

void configureDependencies() {
  sl
    ..registerLazySingleton<EnvConfig>(() => EnvConfig.instance)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<TokenManager>(() => TokenManager(sl()))
    ..registerLazySingleton<TokenStore>(() => sl<TokenManager>())
    ..registerLazySingleton<RefreshMutex>(() => RefreshMutex())
    ..registerLazySingleton<PublicDioFactory>(() => PublicDioFactory(sl()))
    ..registerLazySingleton<DioAuthRemoteDataSource>(
      () => DioAuthRemoteDataSource(sl<PublicDioFactory>().create()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => sl<DioAuthRemoteDataSource>(),
    )
    ..registerLazySingleton<TokenRefreshGateway>(
      () => sl<DioAuthRemoteDataSource>(),
    )
    ..registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(sl(), sl(), sl()),
    )
    ..registerLazySingleton<SecureDioFactory>(
      () => SecureDioFactory(sl(), sl()),
    )
    ..registerLazySingleton<Dio>(() => sl<SecureDioFactory>().create())
    ..registerLazySingleton<ConnectionChecker>(
      () => RemoteConnectionChecker(sl()),
    )
    ..registerLazySingleton<ApiErrorHandler>(() => const ApiErrorHandler())
    ..registerLazySingleton<ScreenRecordRemoteDataSource>(
      () => DioScreenRecordRemoteDataSource(sl()),
    )
    ..registerLazySingleton<ScreenRecordRepositoryDependencies>(
      () => ScreenRecordRepositoryDependencies(
        remoteDataSource: sl(),
        apiErrorHandler: sl(),
        envConfig: sl(),
      ),
    )
    ..registerLazySingleton<RawMaterialEntryRemoteDataSource>(
      () => DioRawMaterialEntryRemoteDataSource(sl()),
    )
    ..registerLazySingleton<RawMaterialEntryRepository>(
      () => RawMaterialEntryRepositoryImpl(sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<LoadRawMaterialEntriesUseCase>(
      () => LoadRawMaterialEntriesUseCase(sl()),
    )
    ..registerLazySingleton<LoadRawMaterialEntryLookupsUseCase>(
      () => LoadRawMaterialEntryLookupsUseCase(sl()),
    )
    ..registerLazySingleton<CreateRawMaterialEntryUseCase>(
      () => CreateRawMaterialEntryUseCase(sl()),
    )
    ..registerLazySingleton<LoadRawMaterialWorkflowUseCase>(
      () => LoadRawMaterialWorkflowUseCase(sl()),
    )
    ..registerLazySingleton<TakeRawMaterialSampleUseCase>(
      () => TakeRawMaterialSampleUseCase(sl()),
    )
    ..registerLazySingleton<LoadRawMaterialSamplesUseCase>(
      () => LoadRawMaterialSamplesUseCase(sl()),
    )
    ..registerLazySingleton<LoadRawMaterialAnalysisUseCase>(
      () => LoadRawMaterialAnalysisUseCase(sl()),
    )
    ..registerLazySingleton<SubmitRawMaterialAnalysisUseCase>(
      () => SubmitRawMaterialAnalysisUseCase(sl()),
    )
    ..registerLazySingleton<SubmitRawMaterialQualityDecisionUseCase>(
      () => SubmitRawMaterialQualityDecisionUseCase(sl()),
    )
    ..registerLazySingleton<RecordRawMaterialActualWeightUseCase>(
      () => RecordRawMaterialActualWeightUseCase(sl()),
    )
    ..registerLazySingleton<LoadRawMaterialStockUseCase>(
      () => LoadRawMaterialStockUseCase(sl()),
    )
    ..registerLazySingleton<LoadProductStockUseCase>(
      () => LoadProductStockUseCase(sl()),
    )
    ..registerLazySingleton<LoadProductStockLookupsUseCase>(
      () => LoadProductStockLookupsUseCase(sl()),
    )
    ..registerLazySingleton<AddProductStockUseCase>(
      () => AddProductStockUseCase(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<LoginValidator>(() => const LoginValidator())
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl(), sl()))
    ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()))
    ..registerLazySingleton<RestoreSessionUseCase>(
      () => RestoreSessionUseCase(sl()),
    )
    ..registerLazySingleton<AuthSessionCubit>(() => AuthSessionCubit(sl()))
    ..registerFactory<LoginCubit>(() => LoginCubit(sl(), sl()))
    ..registerFactory<LogoutCubit>(() => LogoutCubit(sl(), sl(), sl()))
    ..registerFactory<NotificationCubit>(
      () => NotificationCubit(sl(), sl(), sl(), sl(), sl()),
    )
    ..registerFactory<RawMaterialEntryCubit>(
      () => RawMaterialEntryCubit(sl(), sl(), sl()),
    )
    ..registerFactory<RawMaterialQualityCubit>(
      () => RawMaterialQualityCubit(sl(), sl(), sl(), sl(), sl(), sl()),
    )
    ..registerFactory<RawMaterialInventoryCubit>(
      () => RawMaterialInventoryCubit(sl(), sl(), sl()),
    )
    ..registerFactory<ProductInventoryCubit>(
      () => ProductInventoryCubit(sl(), sl(), sl()),
    )
    ..registerLazySingleton<ProductionQualityRemoteDataSource>(
      () => DioProductionQualityRemoteDataSource(sl()),
    )
    ..registerLazySingleton<ProductionQualityRepository>(
      () => ProductionQualityRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<LoadProductionLabSamplesUseCase>(
      () => LoadProductionLabSamplesUseCase(sl()),
    )
    ..registerLazySingleton<CreateProductionLabSampleUseCase>(
      () => CreateProductionLabSampleUseCase(sl()),
    )
    ..registerLazySingleton<LoadProductionLabResultsUseCase>(
      () => LoadProductionLabResultsUseCase(sl()),
    )
    ..registerLazySingleton<CreateProductionLabResultUseCase>(
      () => CreateProductionLabResultUseCase(sl()),
    )
    ..registerLazySingleton<LoadProductionQualityChecksUseCase>(
      () => LoadProductionQualityChecksUseCase(sl()),
    )
    ..registerFactory<ProductionQualityCubit>(
      () => ProductionQualityCubit(sl(), sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<NotificationWebSocketService>(
      () => NotificationWebSocketService(sl(), sl()),
    )
    ..registerLazySingleton<LocalNotificationService>(
      () => LocalNotificationService(),
    )
    ..registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(),
    )
    ..registerLazySingleton<NotificationLifecycleCoordinator>(
      () =>
          NotificationLifecycleCoordinator(sl(), sl(), sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<AppRouter>(() => AppRouter())
    ..registerLazySingleton<NotificationRouter>(() => NotificationRouter())
    ..registerLazySingleton<DioNotificationRemoteDataSource>(
      () => DioNotificationRemoteDataSource(sl()),
    )
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => sl<DioNotificationRemoteDataSource>(),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<LoadNotificationsUseCase>(
      () => LoadNotificationsUseCase(sl()),
    )
    ..registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(sl()),
    )
    ..registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(sl()),
    )
    ..registerLazySingleton<MarkAllNotificationsReadUseCase>(
      () => MarkAllNotificationsReadUseCase(sl()),
    )
    ..registerLazySingleton<RegisterPushDeviceUseCase>(
      () => RegisterPushDeviceUseCase(sl()),
    )
    ..registerLazySingleton<UnregisterPushDeviceUseCase>(
      () => UnregisterPushDeviceUseCase(sl()),
    );
}
