import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

abstract class StockDetailRepository {
  Future<Stock> getStockDetail(int stockId);
}