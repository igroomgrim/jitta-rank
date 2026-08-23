import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfoService {
  Future<bool> get isConnected;
}

class NetworkInfoServiceImpl implements NetworkInfoService {
  NetworkInfoServiceImpl({InternetConnectionChecker? internetConnectionChecker})
      : _internetConnectionChecker =
            internetConnectionChecker ?? _createInternetConnectionChecker();
  final InternetConnectionChecker _internetConnectionChecker;

  static InternetConnectionChecker _createInternetConnectionChecker() {
    return InternetConnectionChecker();
  }

  @override
  Future<bool> get isConnected => _internetConnectionChecker.hasConnection;
}
