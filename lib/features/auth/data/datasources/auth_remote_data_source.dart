import 'package:dio/dio.dart';

import '../../../../core/auth/token_pair.dart';
import '../../../../core/auth/token_refresh_gateway.dart';
import '../../../../core/network/api_constants.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/token_refresh_response_model.dart';

abstract class AuthRemoteDataSource implements TokenRefreshGateway {
  Future<LoginResponseModel> login(LoginRequestModel request);

  Future<void> logout(String refreshToken);

  Future<void> verifyToken(String token);
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

  @override
  Future<TokenPair> refreshToken(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.tokenRefresh,
      data: {'refresh': refreshToken},
    );

    return TokenRefreshResponseModel.fromJson(
      response.data ?? const {},
    ).toEntity();
  }

  @override
  Future<void> verifyToken(String token) async {
    await _dio.post<void>(ApiConstants.tokenVerify, data: {'token': token});
  }
}
