import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/auth/token_manager.dart';
import 'package:flutter_pernit/core/auth/token_pair.dart';
import 'package:flutter_pernit/core/config/env_config.dart';
import 'package:flutter_pernit/core/errors/api_error_handler.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/network/connection_checker.dart';
import 'package:flutter_pernit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_pernit/features/auth/data/models/login_request_model.dart';
import 'package:flutter_pernit/features/auth/data/models/login_response_model.dart';
import 'package:flutter_pernit/features/auth/data/repos/auth_repository_impl.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_session.dart';

void main() {
  test(
    'restoreSession uses locally stored access token without network work',
    () async {
      final remoteDataSource = _CountingAuthRemoteDataSource();
      final connectionChecker = _CountingConnectionChecker();
      final repository = AuthRepositoryImpl(
        remoteDataSource,
        _FakeTokenStore(
          accessToken: 'stored-access',
          refreshToken: 'stored-refresh',
          userJson: jsonEncode(const {
            'id': 1,
            'username': 'admin',
            'email': 'admin@example.com',
            'first_name': 'Ahmed',
            'last_name': 'Hassan',
            'groups': ['System Admin'],
          }),
        ),
        connectionChecker,
        const ApiErrorHandler(),
        EnvConfig.instance,
      );

      final result = await repository.restoreSession();

      expect(result, isA<ApiSuccess<AuthSession>>());
      final session = (result as ApiSuccess<AuthSession>).data;
      expect(session.accessToken, 'stored-access');
      expect(session.refreshToken, 'stored-refresh');
      expect(session.user.username, 'admin');
      expect(connectionChecker.lookups, 0);
      expect(remoteDataSource.verifyCalls, 0);
      expect(remoteDataSource.refreshCalls, 0);
    },
  );
}

class _FakeTokenStore implements TokenStore {
  String? accessToken;
  String? refreshToken;
  String? userJson;
  var clearCalls = 0;

  _FakeTokenStore({this.accessToken, this.refreshToken, this.userJson});

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveUserJson(String userJson) async {
    this.userJson = userJson;
  }

  @override
  Future<String?> readUserJson() async => userJson;

  @override
  Future<void> clearTokens() async {
    clearCalls++;
    accessToken = null;
    refreshToken = null;
    userJson = null;
  }
}

class _CountingConnectionChecker implements ConnectionChecker {
  var lookups = 0;

  @override
  Future<bool> get hasConnection async {
    lookups++;
    return true;
  }
}

class _CountingAuthRemoteDataSource implements AuthRemoteDataSource {
  var verifyCalls = 0;
  var refreshCalls = 0;

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<TokenPair> refreshToken(String refreshToken) async {
    refreshCalls++;
    return const TokenPair(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }

  @override
  Future<void> verifyToken(String token) async {
    verifyCalls++;
  }
}
