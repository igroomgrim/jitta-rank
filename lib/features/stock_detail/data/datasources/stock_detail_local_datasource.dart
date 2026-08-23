import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_datasource.dart';
import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';

abstract class StockDetailLocalDatasource extends StockDetailDatasource {
  @override
  Future<StockModel> getStockDetail(int stockId);
  Future<void> saveStockDetail(StockModel stockDetail);
}

class StockDetailLocalDatasourceImpl extends StockDetailLocalDatasource {
  StockDetailLocalDatasourceImpl({required this.box});

  final Box<StockModel> box;

  /// Throws [CacheException] when nothing is cached for [stockId].
  @override
  Future<StockModel> getStockDetail(int stockId) async {
    final stock = box.get(stockId);
    if (stock == null) {
      throw CacheException('No cached stock detail for id $stockId');
    }
    return stock;
  }

  @override
  Future<void> saveStockDetail(StockModel stockDetail) async {
    try {
      await box.put(stockDetail.stockId, stockDetail);
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        CacheException('Failed to write stock detail to cache: $e'),
        stackTrace,
      );
    }
  }
}
