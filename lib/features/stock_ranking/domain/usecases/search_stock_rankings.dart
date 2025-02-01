import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';

class SearchStockRankingsUsecase {
  final StockRankingRepository repository;

  SearchStockRankingsUsecase(this.repository);

  Future<Either<Failure, List<RankedStock>>> call(
      String keyword, String market, List<String> sectors) async {
    return await repository.searchStockRankings(keyword, market, sectors);
  }
}
