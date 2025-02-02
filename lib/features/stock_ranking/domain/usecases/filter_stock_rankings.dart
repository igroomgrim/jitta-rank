import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';
import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';

class FilterStockRankingsUsecase {
  final StockRankingRepository repository;

  FilterStockRankingsUsecase(this.repository);

  Future<Either<Failure, List<RankedStock>>> call(
      String keyword, String market, List<String> sectors) async {
    return await repository.filterStockRankings(keyword, market, sectors);
  }
}
