import 'dart:async';
import 'dart:io';

abstract class ConnectionChecker {
  Future<bool> get hasConnection;
}

class RemoteConnectionChecker implements ConnectionChecker {
  const RemoteConnectionChecker();

  @override
  Future<bool> get hasConnection async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}
