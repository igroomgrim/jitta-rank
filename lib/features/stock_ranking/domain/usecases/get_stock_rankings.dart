import '../repositories/stock_ranking_repository.dart';
import '../entities/ranked_stock.dart';

class GetStockRankingsUsecase {
  final StockRankingRepository repository;

  GetStockRankingsUsecase(this.repository);

  Future<List<RankedStock>> call(int limit, String market, int page, List<String> sectors) async {
    return await repository.getStockRankings(limit, market, page, sectors);
  }
}
