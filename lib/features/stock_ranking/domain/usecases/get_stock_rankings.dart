import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';

class GetStockRankings {
  final StockRankingRepository repository;

  GetStockRankings(this.repository);

  Future<List<RankedStock>> call() async {
    return await repository.getStockRankings();
  }
}
