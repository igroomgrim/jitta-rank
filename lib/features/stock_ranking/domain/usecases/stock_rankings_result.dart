import '../entities/ranked_stock.dart';

class StockRankingsResult {
  final List<RankedStock> rankedStocks;
  final bool hasReachedMaxData;

  StockRankingsResult(
      {required this.rankedStocks, required this.hasReachedMaxData});
}
