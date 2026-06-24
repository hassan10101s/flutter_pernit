import 'package:dio/dio.dart';

import 'failure.dart';
import 'failure_code.dart';

class ApiErrorHandler {
  const ApiErrorHandler();

  Failure handle(Object error) {
    if (error is DioException) {
      return _handleDio(error);
    }

    return const Failure(
      code: FailureCode.unknown,
      messageKey: 'failureUnknown',
    );
  }

  Failure _handleDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const Failure(
        code: FailureCode.timeout,
        messageKey: 'failureTimeout',
      ),
      DioExceptionType.connectionError => const Failure(
        code: FailureCode.network,
        messageKey: 'failureNetwork',
      ),
      DioExceptionType.badCertificate => const Failure(
        code: FailureCode.sslPinning,
        messageKey: 'failureNetwork',
      ),
      DioExceptionType.badResponse => _handleResponse(error.response),
      DioExceptionType.cancel => const Failure(
        code: FailureCode.network,
        messageKey: 'failureNetwork',
      ),
      DioExceptionType.unknown => const Failure(
        code: FailureCode.unknown,
        messageKey: 'failureUnknown',
      ),
    };
  }

  Failure _handleResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final validationErrors = _extractFieldErrors(response?.data);

    if (statusCode == 400 || statusCode == 422) {
      return Failure(
        code: FailureCode.validation,
        messageKey: 'failureValidation',
        fieldErrors: validationErrors,
      );
    }

    if (statusCode == null) {
      return const Failure(
        code: FailureCode.unknown,
        messageKey: 'failureUnknown',
      );
    }

    if (statusCode >= 500 && statusCode <= 599) {
      return const Failure(
        code: FailureCode.server,
        messageKey: 'failureServer',
      );
    }

    return switch (statusCode) {
      401 => const Failure(
        code: FailureCode.unauthorized,
        messageKey: 'failureUnauthorized',
      ),
      403 => const Failure(
        code: FailureCode.forbidden,
        messageKey: 'failureForbidden',
      ),
      404 => const Failure(
        code: FailureCode.notFound,
        messageKey: 'failureNotFound',
      ),
      409 => const Failure(
        code: FailureCode.conflict,
        messageKey: 'failureConflict',
      ),
      _ => const Failure(
        code: FailureCode.unknown,
        messageKey: 'failureUnknown',
      ),
    };
  }

  Map<String, List<String>> _extractFieldErrors(Object? data) {
    if (data is! Map) {
      return const {};
    }

    final errors = <String, List<String>>{};
    for (final entry in data.entries) {
      if (entry.key is! String || entry.key == 'detail') {
        continue;
      }

      final value = entry.value;
      if (value is List) {
        errors[entry.key as String] = value.map((item) => '$item').toList();
      } else if (value is String) {
        errors[entry.key as String] = [value];
      }
    }
    return errors;
  }
}
