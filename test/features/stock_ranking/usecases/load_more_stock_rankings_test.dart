import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/load_more_stock_rankings.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_repository.mocks.dart';

void main() {
  late LoadMoreStockRankingsUsecase loadMoreStockRankingsUsecase;
  late MockStockRankingRepository mockStockRankingRepository;

  setUp(() {
    mockStockRankingRepository = MockStockRankingRepository();
    loadMoreStockRankingsUsecase =
        LoadMoreStockRankingsUsecase(mockStockRankingRepository);
  });

  test('should return ranked stocks from repository', () async {
    when(mockStockRankingRepository.getStockRankings(any, any, any, any))
        .thenAnswer(
      (_) async => Right(MockStockRankingData.getMockStockRankings()),
    );

    final result =
        await loadMoreStockRankingsUsecase.call('market', 1, ['sector']);

    expect(result, isA<Right>());
  });

  test('should return error when repository returns error', () async {
    when(mockStockRankingRepository.getStockRankings(any, any, any, any))
        .thenAnswer((_) async => const Left(CustomFailure(message: 'Error')));

    final result =
        await loadMoreStockRankingsUsecase.call('market', 1, ['sector']);

    expect(result, isA<Left>());
  });
}
