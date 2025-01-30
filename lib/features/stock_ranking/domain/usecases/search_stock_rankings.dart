import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';

class SearchStockRankingsUsecase {
  final StockRankingRepository repository;

  SearchStockRankingsUsecase(this.repository);

  Future<List<RankedStock>> call(String keyword, String market, List<String> sectors) async {
    return await repository.searchStockRankings(keyword, market, sectors);
  }
}