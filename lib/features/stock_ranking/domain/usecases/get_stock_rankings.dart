import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';

class GetStockRankingsUsecase {
  final StockRankingRepository repository;

  GetStockRankingsUsecase(this.repository);

  Future<Either<Failure, List<RankedStock>>> call(
      int limit, String market, int page, List<String> sectors) async {
    return await repository.getStockRankings(limit, market, page, sectors);
  }
}
