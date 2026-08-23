import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfoService {
  Future<bool> get isConnected;

  /// Emits whenever connectivity changes.
  ///
  /// Without this the app only learned about connectivity when something
  /// explicitly asked — on initState and on pull-to-refresh — so coming back
  /// online left the UI saying "Offline Mode" until the user acted.
  Stream<bool> get onStatusChange;
}

class NetworkInfoServiceImpl implements NetworkInfoService {
  NetworkInfoServiceImpl({InternetConnectionChecker? internetConnectionChecker})
      : _checker = internetConnectionChecker ?? InternetConnectionChecker();

  final InternetConnectionChecker _checker;

  @override
  Future<bool> get isConnected => _checker.hasConnection;

  @override
  Stream<bool> get onStatusChange => _checker.onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
      );
}
