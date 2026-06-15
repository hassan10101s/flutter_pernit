import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repos/auth_repository_impl.dart';
import '../../features/auth/domain/repos/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/validators/login_validator.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/bloc/logout_cubit.dart';
import '../auth/auth_interceptor.dart';
import '../auth/token_manager.dart';
import '../config/env_config.dart';
import '../errors/api_error_handler.dart';
import '../network/connection_checker.dart';
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
    ..registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(sl()))
    ..registerLazySingleton<SecureDioFactory>(
      () => SecureDioFactory(sl(), sl()),
    )
    ..registerLazySingleton<Dio>(() => sl<SecureDioFactory>().create())
    ..registerLazySingleton<ConnectionChecker>(
      () => const RemoteConnectionChecker(),
    )
    ..registerLazySingleton<ApiErrorHandler>(() => const ApiErrorHandler())
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => DioAuthRemoteDataSource(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<LoginValidator>(() => const LoginValidator())
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl(), sl()))
    ..registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()))
    ..registerFactory<LoginCubit>(() => LoginCubit(sl()))
    ..registerFactory<LogoutCubit>(() => LogoutCubit(sl()))
    ..registerLazySingleton<AppRouter>(() => AppRouter());
}
