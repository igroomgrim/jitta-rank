import '../repositories/stock_ranking_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'stock_rankings_result.dart';

class GetStockRankingsUsecase {
  final StockRankingRepository repository;

  GetStockRankingsUsecase(this.repository);

  Future<Either<Failure, StockRankingsResult>> call(
      {int limit = ApiConstants.defaultLimit,
      String market = ApiConstants.defaultMarket,
      int page = ApiConstants.defaultPage,
      List<String> sectors = const []}) async {
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
