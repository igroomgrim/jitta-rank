import '../entities/ranked_stock.dart';

abstract class StockRankingRepository {
  Future<List<RankedStock>> getStockRankings(int limit, String market, int page, List<String> sectors);
  Future<List<RankedStock>> searchStockRankings(String keyword, String market, List<String> sectors);
}
