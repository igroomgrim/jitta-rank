import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/search_stock_rankings.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_repository.mocks.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';
import 'package:jitta_rank/core/error/error.dart';

void main() {
  late SearchStockRankingsUsecase searchStockRankingsUsecase;
  late MockStockRankingRepository mockStockRankingRepository;

  setUp(() {
    mockStockRankingRepository = MockStockRankingRepository();
    searchStockRankingsUsecase = SearchStockRankingsUsecase(mockStockRankingRepository);
  });

  test('should return ranked stocks from repository', () async {
    when(mockStockRankingRepository.searchStockRankings(any, any, any)).thenAnswer((_) async => Right(MockStockRankingData.getMockStockRankings()));

    final result = await searchStockRankingsUsecase.call('keyword', 'market', ['sector']);

    expect(result, isA<Right>());
  });

  test('should return error when repository returns error', () async {
    when(mockStockRankingRepository.searchStockRankings(any, any, any)).thenAnswer((_) async => Left(CustomFailure(message: 'Error')));

    final result = await searchStockRankingsUsecase.call('keyword', 'market', ['sector']);

    expect(result, isA<Left>());
  });
}