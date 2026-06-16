import '../../../../core/config/env_config.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../datasources/screen_record_remote_data_source.dart';

class ScreenRecordRepositoryDependencies {
  final ScreenRecordRemoteDataSource remoteDataSource;
  final ApiErrorHandler apiErrorHandler;
  final EnvConfig envConfig;

  const ScreenRecordRepositoryDependencies({
    required this.remoteDataSource,
    required this.apiErrorHandler,
    required this.envConfig,
  });
}
