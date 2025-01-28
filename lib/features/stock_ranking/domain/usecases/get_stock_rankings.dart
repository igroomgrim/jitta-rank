import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';

class GetStockRankingsUsecase {
  final StockRankingRepository repository;

  GetStockRankingsUsecase(this.repository);

  Future<List<RankedStock>> call() async {
    return await repository.getStockRankings();
  }
}
