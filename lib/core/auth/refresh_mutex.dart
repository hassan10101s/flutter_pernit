import 'token_pair.dart';

class RefreshMutex {
  static const defaultTimeout = Duration(seconds: 15);

  final Duration timeout;
  Future<TokenPair?>? _inFlightRefresh;

  RefreshMutex({this.timeout = defaultTimeout});

  Future<TokenPair?> run(Future<TokenPair?> Function() refresh) {
    final runningRefresh = _inFlightRefresh;
    if (runningRefresh != null) {
      return runningRefresh;
    }

    final operation = refresh()
        .timeout(timeout, onTimeout: () => null)
        .whenComplete(() {
          _inFlightRefresh = null;
        });

    _inFlightRefresh = operation;
    return operation;
  }
}
