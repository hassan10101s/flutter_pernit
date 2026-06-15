import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/features/auth/data/models/token_refresh_response_model.dart';

void main() {
  test('maps refresh response access and refresh tokens', () {
    final model = TokenRefreshResponseModel.fromJson(const {
      'access': 'new-access',
      'refresh': 'new-refresh',
    });

    final tokenPair = model.toEntity();

    expect(tokenPair.accessToken, 'new-access');
    expect(tokenPair.refreshToken, 'new-refresh');
    expect(tokenPair.isComplete, isTrue);
  });
}
