import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_graphql_datasource.mocks.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_local_datasource.mocks.dart';
import '../../../mocks/core/networking/mock_network_info_service.mocks.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';

void main() {
  late StockRankingRepository stockRankingRepository;
  late MockStockRankingGraphqlDatasource mockStockRankingGraphqlDatasource;
  late MockStockRankingLocalDatasource mockStockRankingLocalDatasource;
  late MockNetworkInfoService mockNetworkInfoService;

  setUp(() {
    mockStockRankingGraphqlDatasource = MockStockRankingGraphqlDatasource();
    mockStockRankingLocalDatasource = MockStockRankingLocalDatasource();
    mockNetworkInfoService = MockNetworkInfoService();
    stockRankingRepository = StockRankingRepositoryImpl(
      graphqlDatasource: mockStockRankingGraphqlDatasource,
      localDatasource: mockStockRankingLocalDatasource,
      networkInfoService: mockNetworkInfoService,
    );
  });

  // getStockRankings
  test(
      'should return ranked stocks from remote data source when device is online',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => true);
    when(mockStockRankingGraphqlDatasource.getStockRankings(any, any, any, any))
        .thenAnswer(
            (_) async => [MockStockRankingData.getMockRankedStockModel()]);

    final result = await stockRankingRepository
        .getStockRankings(1, 'Test Market', 1, ['Test Sector']);
    expect(result, isA<Right>());
  });

  test(
      'should return ranked stocks from local data source when device is offline',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockRankingLocalDatasource.getStockRankings(any, any, any, any))
        .thenAnswer(
            (_) async => [MockStockRankingData.getMockRankedStockModel()]);

    final result = await stockRankingRepository
        .getStockRankings(1, 'Test Market', 1, ['Test Sector']);
    expect(result, isA<Right>());
  });

  test('should return error when remote data source fails', () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => true);
    when(mockStockRankingGraphqlDatasource.getStockRankings(any, any, any, any))
        .thenThrow(Exception('Error'));

    final result = await stockRankingRepository
        .getStockRankings(1, 'Test Market', 1, ['Test Sector']);
    expect(result, isA<Left>());
  });

  test('should return error when local data source fails', () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockRankingLocalDatasource.getStockRankings(any, any, any, any))
        .thenThrow(Exception('Error'));

    final result = await stockRankingRepository
        .getStockRankings(1, 'Test Market', 1, ['Test Sector']);
    expect(result, isA<Left>());
  });

  test('should return error when both remote and local data sources fail',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockRankingGraphqlDatasource.getStockRankings(any, any, any, any))
        .thenThrow(Exception('Error'));
    when(mockStockRankingLocalDatasource.getStockRankings(any, any, any, any))
        .thenThrow(Exception('Error'));

    final result = await stockRankingRepository
        .getStockRankings(1, 'Test Market', 1, ['Test Sector']);
    expect(result, isA<Left>());
  });

  // searchStockRankings
  test(
      'should return ranked stocks from local data source when search with keyword and device is online',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => true);
    when(mockStockRankingLocalDatasource.searchStockRankings(any, any, any))
        .thenAnswer(
            (_) async => [MockStockRankingData.getMockRankedStockModel()]);

    final result = await stockRankingRepository
        .searchStockRankings('Test Keyword', 'Test Market', ['Test Sector']);
    expect(result, isA<Right>());
  });

  test(
      'should return ranked stocks from local data source when search with keyword and device is offline',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockRankingLocalDatasource.searchStockRankings(any, any, any))
        .thenAnswer(
            (_) async => [MockStockRankingData.getMockRankedStockModel()]);

    final result = await stockRankingRepository
        .searchStockRankings('Test Keyword', 'Test Market', ['Test Sector']);
    expect(result, isA<Right>());
  });

  test('should return error when search with keyword and device is online',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => true);
    when(mockStockRankingLocalDatasource.searchStockRankings(any, any, any))
        .thenThrow(Exception('Error'));

    final result = await stockRankingRepository
        .searchStockRankings('Test Keyword', 'Test Market', ['Test Sector']);
    expect(result, isA<Left>());
  });

  test('should return error when search with keyword and device is offline',
      () async {
    when(mockNetworkInfoService.isConnected).thenAnswer((_) async => false);
    when(mockStockRankingLocalDatasource.searchStockRankings(any, any, any))
        .thenThrow(Exception('Error'));

    final result = await stockRankingRepository
        .searchStockRankings('Test Keyword', 'Test Market', ['Test Sector']);
    expect(result, isA<Left>());
  });
}
