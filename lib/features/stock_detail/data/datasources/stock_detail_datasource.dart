import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';

abstract class StockDetailDatasource {
  Future<StockModel> getStockDetail(int stockId);
}
