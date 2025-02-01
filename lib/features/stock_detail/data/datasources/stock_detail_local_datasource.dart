import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_datasource.dart';
import 'package:hive/hive.dart';

abstract class StockDetailLocalDatasource extends StockDetailDatasource {
  @override
  Future<StockModel> getStockDetail(int stockId);
  Future<void> saveStockDetail(StockModel stockDetail);
}

class StockDetailLocalDatasourceImpl extends StockDetailLocalDatasource {
  final Box<StockModel> box;

  StockDetailLocalDatasourceImpl([Box<StockModel>? box])
      : box = box ?? Hive.box<StockModel>('stock_detail');

  @override
  Future<StockModel> getStockDetail(int stockId) async {
    final stock = box.get(stockId);
    if (stock == null) {
      throw Exception(
          'Stock on local storage not found'); // or handle this case as needed
    }
    return stock;
  }

  @override
  Future<void> saveStockDetail(StockModel stockDetail) async {
    try {
      await box.put(stockDetail.stockId, stockDetail);
    } catch (e) {
      throw Exception(e);
    }
  }
}
