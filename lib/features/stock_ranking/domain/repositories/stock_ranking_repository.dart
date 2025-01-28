import '../entities/ranked_stock.dart';

abstract class StockRankingRepository {
  Future<List<RankedStock>> getStockRankings();
}
