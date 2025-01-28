import '../entities/ranked_stock.dart';

abstract class StockRankingRepository {
  Future<List<RankedStock>> getStockRankings(int limit, String market, int page, List<String> sectors);
}
