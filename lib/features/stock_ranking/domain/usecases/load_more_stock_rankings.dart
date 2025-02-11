import 'package:jitta_rank/core/core.dart';
import '../repositories/stock_ranking_repository.dart';
import 'stock_rankings_result.dart';
import 'package:dartz/dartz.dart';

class LoadMoreStockRankingsUsecase {
  final StockRankingRepository repository;

  LoadMoreStockRankingsUsecase(this.repository);

  Future<Either<Failure, StockRankingsResult>> call(
      String market, int page, List<String> sectors,
      {int limit = ApiConstants.defaultLimit}) async {
    final result =
        await repository.getStockRankings(limit, market, page, sectors);
    return result.fold(
      (failure) => Left(failure),
      (rankedStocks) {
        final hasReachedMaxData = rankedStocks.length < limit;
        return Right(StockRankingsResult(
            rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
      },
    );
  }
}
