import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import '../../mocks/mock_network_info_service.mocks.dart';

void main() {
  late NetworkInfoService networkInfoService;
  late MockInternetConnectionChecker mockInternetConnectionChecker;
  
    setUp(() {
      mockInternetConnectionChecker = MockInternetConnectionChecker();
      networkInfoService = NetworkInfoServiceImpl(internetConnectionChecker: mockInternetConnectionChecker);
    });

  test('should return true when device is connected to internet', () async {
    when(mockInternetConnectionChecker.hasConnection).thenAnswer((_) async => true);

    final result = await networkInfoService.isConnected;

    expect(result, true);
  });
}
