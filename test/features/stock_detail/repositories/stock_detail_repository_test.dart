import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_graphql_datasource.mocks.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_local_datasource.mocks.dart';
import '../../../mocks/mock_network_info_service.mocks.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_data.dart';

void main() {
  late StockDetailRepository stockDetailRepository;
  late MockStockDetailGraphqlDatasource mockStockDetailGraphqlDatasource;
  late MockStockDetailLocalDatasource mockStockDetailLocalDatasource;
  late MockNetworkInfoService mockNetworkInfoService;
  late StockModel mockStockModel;

  setUp(() {
    mockStockDetailGraphqlDatasource = MockStockDetailGraphqlDatasource();
    mockStockDetailLocalDatasource = MockStockDetailLocalDatasource();
    mockNetworkInfoService = MockNetworkInfoService();
    stockDetailRepository = StockDetailRepositoryImpl(
      mockStockDetailGraphqlDatasource,
      mockStockDetailLocalDatasource,
      mockNetworkInfoService,
    );

    mockStockModel = MockStockDetailData.getMockStockModel();
  });

  test('should return stock detail from remote data source when device is online', () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => true);
    when(mockStockDetailGraphqlDatasource.getStockDetail(any)).thenAnswer((_) async => mockStockModel);
    
    final result = await stockDetailRepository.getStockDetail(1);

    expect(result, isA<Right>());
  });

  test('should return stock detail from local data source when device is offline', () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockDetailLocalDatasource.getStockDetail(any)).thenAnswer((_) async => mockStockModel);

    final result = await stockDetailRepository.getStockDetail(1);

    expect(result, isA<Right>());
  });

  test('should return error when device is online and stock detail is not found in remote data source', () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => true);
    when(mockStockDetailGraphqlDatasource.getStockDetail(any)).thenThrow(Exception('Stock detail not found'));

    final result = await stockDetailRepository.getStockDetail(1);

    expect(result, isA<Left>());
  });

  test('should return error when device is offline and stock detail is not found in local data source', () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockDetailLocalDatasource.getStockDetail(any)).thenThrow(Exception('Stock detail not found'));

    final result = await stockDetailRepository.getStockDetail(1);

    expect(result, isA<Left>());
  });
}
