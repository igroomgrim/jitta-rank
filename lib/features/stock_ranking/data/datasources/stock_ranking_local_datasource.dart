import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:hive/hive.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

abstract class StockRankingLocalDatasource extends StockRankingDatasource {
  @override
  Future<List<RankedStockModel>> getStockRankings(
      {int limit, String market, int page, List<String> sectors});
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings);
}

class StockRankingLocalDatasourceImpl extends StockRankingLocalDatasource {
  final Box<RankedStockModel> _box;

  StockRankingLocalDatasourceImpl([Box<RankedStockModel>? box])
      : _box = box ?? Hive.box<RankedStockModel>('ranked_stocks');

  @override
  Future<List<RankedStockModel>> getStockRankings(
      {int limit = ApiConstants.defaultLimit,
      String market = ApiConstants.defaultMarket,
      int page = ApiConstants.defaultPage,
      List<String> sectors = ApiConstants.defaultSectors}) async {
    try {
      final List<RankedStockModel> rankedStocks = _box.values.toList();
      return rankedStocks;
    } catch (e) {
      throw Exception('Failed to fetch stock rankings from local datasource');
    }
  }

  @override
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings) async {
    if (stockRankings.isEmpty) return;
    const maxStorageLimit = 40;

    try {
      final existingStocks = _box.values.toList();
      final deduplicatedExistingStocks = existingStocks
          .where((stock) =>
              !stockRankings.any((newStock) => newStock.symbol == stock.symbol))
          .toList();
      final allStocks = [...deduplicatedExistingStocks, ...stockRankings];
      final stocksToSave = allStocks.length <= maxStorageLimit
          ? allStocks
          : allStocks.sublist(allStocks.length - maxStorageLimit);

      await _box.clear();
      await _box.addAll(stocksToSave);
    } catch (e) {
      throw Exception('Failed to save stock rankings on local datasource');
    }
  }
  /*
  @override
  Future<List<RankedStockModel>> filterStockRankings(
      String keyword, String market, List<String> sectors) async {
    try {
      final rankedStocks = _box.values.toList();
      if (rankedStocks.isEmpty) return [];
      if (keyword.isEmpty) {
        final filteredByMarketStocks =
            _filterByMarket(rankedStocks, market);
        final filteredBySectorsStocks =
            _filterBySectors(filteredByMarketStocks, sectors);
        return filteredBySectorsStocks.toList();
      } else {
        final filteredByKeywordStocks =
            _filterByKeyword(rankedStocks, keyword);
        final filteredByMarketStocks =
            _filterByMarket(filteredByKeywordStocks, market);
        final filteredBySectorsStocks =
            _filterBySectors(filteredByMarketStocks, sectors);
        return filteredBySectorsStocks.toList();
      }
    } catch (e) {
      throw Exception('Failed to filter stock rankings on local datasource');
    }
  }
  */
}
