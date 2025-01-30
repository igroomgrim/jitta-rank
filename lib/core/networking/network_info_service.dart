import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfoService {
  Future<bool> get isConnected;
}

class NetworkInfoServiceImpl implements NetworkInfoService {
  final InternetConnectionChecker _internetConnectionChecker;

  NetworkInfoServiceImpl({
    InternetConnectionChecker? internetConnectionChecker
  }) : _internetConnectionChecker = internetConnectionChecker ?? InternetConnectionChecker();
    
  @override
  Future<bool> get isConnected => _internetConnectionChecker.hasConnection;
}
