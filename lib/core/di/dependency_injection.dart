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
import '../../features/raw_material_entry/data/datasources/raw_material_entry_remote_data_source.dart';
import '../../features/raw_material_entry/data/repos/raw_material_entry_repository_impl.dart';
import '../../features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import '../../features/raw_material_entry/presentation/bloc/raw_material_entry_cubit.dart';
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
      () => const RemoteConnectionChecker(),
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
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<LoginValidator>(() => const LoginValidator())
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl(), sl()))
    ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()))
    ..registerLazySingleton<RestoreSessionUseCase>(
      () => RestoreSessionUseCase(sl()),
    )
    ..registerFactory<AuthSessionCubit>(() => AuthSessionCubit(sl()))
    ..registerFactory<LoginCubit>(() => LoginCubit(sl()))
    ..registerFactory<LogoutCubit>(() => LogoutCubit(sl()))
    ..registerFactory<RawMaterialEntryCubit>(() => RawMaterialEntryCubit(sl()))
    ..registerLazySingleton<AppRouter>(() => AppRouter());
}
