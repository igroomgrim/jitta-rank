import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/filter_stock_rankings.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/stock_rankings_result.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_repository.mocks.dart';

void main() {
  late FilterStockRankingsUsecase filterStockRankingsUsecase;
  late MockStockRankingRepository mockStockRankingRepository;

  setUp(() {
    mockStockRankingRepository = MockStockRankingRepository();
    filterStockRankingsUsecase =
        FilterStockRankingsUsecase(mockStockRankingRepository);
  });

  test('should return ranked stocks from repository', () async {
    when(mockStockRankingRepository.filterStockRankings(any, any, any))
        .thenAnswer(
      (_) async => Right<Failure, List<RankedStock>>(
        MockStockRankingData.getMockStockRankings(),
      ),
    );

    final result =
        await filterStockRankingsUsecase.call('keyword', 'market', ['sector']);

    expect(result, isA<Right<Failure, StockRankingsResult>>());
  });

  test('should return error when repository returns error', () async {
    when(mockStockRankingRepository.filterStockRankings(any, any, any))
        .thenAnswer(
      (_) async => const Left<Failure, List<RankedStock>>(
        CustomFailure(message: 'Error'),
      ),
    );

    final result =
        await filterStockRankingsUsecase.call('keyword', 'market', ['sector']);

    expect(result, isA<Left<Failure, StockRankingsResult>>());
  });
}
