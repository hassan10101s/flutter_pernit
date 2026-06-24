import 'dart:async';
import 'dart:io';

import '../config/env_config.dart';

abstract class ConnectionChecker {
  Future<bool> get hasConnection;
}

class RemoteConnectionChecker implements ConnectionChecker {
  final EnvConfig _envConfig;

  const RemoteConnectionChecker(this._envConfig);

  @override
  Future<bool> get hasConnection async {
    try {
      final uri = Uri.parse(_envConfig.apiBaseUrl);
      final result = await InternetAddress.lookup(
        uri.host,
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}
