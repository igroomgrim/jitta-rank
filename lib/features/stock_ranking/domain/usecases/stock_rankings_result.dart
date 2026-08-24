import '../entities/ranked_stock.dart';

class StockRankingsResult {
  StockRankingsResult({
    required this.rankedStocks,
    required this.hasReachedMaxData,
  });
  final List<RankedStock> rankedStocks;
  final bool hasReachedMaxData;
}
