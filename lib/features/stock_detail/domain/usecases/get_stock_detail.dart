import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import '../repositories/stock_detail_repository.dart';

class GetStockDetailUsecase {
  final StockDetailRepository repository;

  GetStockDetailUsecase(this.repository);

  Future<Stock> call(int stockId) async {
    return await repository.getStockDetail(stockId);
  }
}
