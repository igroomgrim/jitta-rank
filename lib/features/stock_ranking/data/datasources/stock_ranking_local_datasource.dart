import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:hive/hive.dart';

abstract class StockRankingLocalDatasource extends StockRankingDatasource {
  @override
  Future<List<RankedStockModel>> getStockRankings(
      int limit, String market, int page, List<String> sectors);
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings);
  Future<List<RankedStockModel>> searchStockRankings(
      String keyword, String market, List<String> sectors);
}

class StockRankingLocalDatasourceImpl extends StockRankingLocalDatasource {
  final Box<RankedStockModel> _box;

  StockRankingLocalDatasourceImpl([Box<RankedStockModel>? box])
      : _box = box ?? Hive.box<RankedStockModel>('ranked_stocks');

  @override
  Future<List<RankedStockModel>> getStockRankings(
      int limit, String market, int page, List<String> sectors) async {
    final List<RankedStockModel> rankedStocks = _box.values.toList();
    final filteredByMarketStocks = _filterByMarket(rankedStocks, market);
    final filteredBySectorsStocks =
        _filterBySectors(filteredByMarketStocks, sectors);
    return filteredBySectorsStocks.toList();
  }

  @override
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings) async {
    if (stockRankings.isEmpty) return;
    const maxStorageLimit = 40;

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
  }

  @override
  Future<List<RankedStockModel>> searchStockRankings(
      String keyword, String market, List<String> sectors) async {
    final rankedStocks = _box.values.toList();
    final filteredByKeywordStocks = rankedStocks
        .where((stock) =>
            stock.symbol.toLowerCase().contains(keyword.toLowerCase()) ||
            stock.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    final filteredByMarketStocks =
        _filterByMarket(filteredByKeywordStocks, market);
    final filteredBySectorsStocks =
        _filterBySectors(filteredByMarketStocks, sectors);
    return filteredBySectorsStocks.toList();
  }

  List<RankedStockModel> _filterByMarket(
      List<RankedStockModel> rankedStocks, String market) {
    return rankedStocks.where((stock) => stock.market == market).toList();
  }

  List<RankedStockModel> _filterBySectors(
      List<RankedStockModel> rankedStocks, List<String> sectors) {
    if (sectors.isEmpty) return rankedStocks;
    return rankedStocks
        .where((stock) => sectors.contains(stock.sector?.id ?? ''))
        .toList();
  }
}
