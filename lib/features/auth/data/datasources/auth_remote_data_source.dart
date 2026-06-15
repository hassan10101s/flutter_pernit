import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);

  Future<void> logout(String refreshToken);
}

class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  final Dio _dio;

  const DioAuthRemoteDataSource(this._dio);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: request.toJson(),
    );

    return LoginResponseModel.fromJson(response.data ?? const {});
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(ApiConstants.logout, data: {'refresh': refreshToken});
  }
}
