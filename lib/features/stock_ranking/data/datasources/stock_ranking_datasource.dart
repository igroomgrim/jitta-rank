import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';

abstract class StockRankingDatasource {
  Future<List<RankedStockModel>> getStockRankings(
      {int limit, String market, int page, List<String> sectors});
}
