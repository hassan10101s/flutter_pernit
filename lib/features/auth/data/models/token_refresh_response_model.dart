import '../../../../core/auth/token_pair.dart';

class TokenRefreshResponseModel {
  final String accessToken;
  final String refreshToken;

  const TokenRefreshResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenRefreshResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponseModel(
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
    );
  }

  TokenPair toEntity() {
    return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }
}
