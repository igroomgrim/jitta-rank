import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:hive/hive.dart';

abstract class StockRankingLocalDatasource extends StockRankingDatasource {
  @override
  Future<List<RankedStockModel>> getStockRankings(int limit, String market, int page, List<String> sectors);
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings);
}

class StockRankingLocalDatasourceImpl extends StockRankingLocalDatasource {
  final Box<RankedStockModel> box;

  StockRankingLocalDatasourceImpl([Box<RankedStockModel>? box]) 
      : box = box ?? Hive.box<RankedStockModel>('ranked_stocks');

  @override
  Future<List<RankedStockModel>> getStockRankings(int limit, String market, int page, List<String> sectors) async {
    final List<RankedStockModel> rankedStocks = box.values.toList();
    // TODO: filter by market, page, and sectors
    return rankedStocks;
  }

  @override
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings) async {
    if (stockRankings.isEmpty) return;
    const maxStorageLimit = 40;
    
    final existingStocks = box.values.toList();
    final deduplicatedExistingStocks = existingStocks.where((stock) => !stockRankings.any((newStock) => newStock.symbol == stock.symbol)).toList();
    final allStocks = [...deduplicatedExistingStocks, ...stockRankings];
    final stocksToSave = allStocks.length <= maxStorageLimit 
        ? allStocks 
        : allStocks.sublist(allStocks.length - maxStorageLimit);

    await box.clear();
    await box.addAll(stocksToSave);
  }
}