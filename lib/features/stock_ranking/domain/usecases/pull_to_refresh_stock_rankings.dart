import '../repositories/stock_ranking_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'stock_rankings_result.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

class PullToRefreshStockRankingsUsecase {
  final StockRankingRepository repository;

  PullToRefreshStockRankingsUsecase(this.repository);

  Future<Either<Failure, StockRankingsResult>> call(
      String market, List<String> sectors) async {
    final result = await repository.getStockRankings(
        ApiConstants.defaultLimit, market, ApiConstants.defaultPage, sectors);
    return result.fold(
      (failure) => Left(failure),
      (rankedStocks) {
        final hasReachedMaxData =
            rankedStocks.length < ApiConstants.defaultLimit;
        return Right(StockRankingsResult(
            rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
      },
    );
  }
}
