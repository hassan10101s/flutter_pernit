import 'token_pair.dart';

abstract class TokenRefreshGateway {
  Future<TokenPair> refreshToken(String refreshToken);
}
