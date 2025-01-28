import 'package:jitta_rank/features/stock_detail/domain/repositories/stock_detail_repository.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
class StockDetailRepositoryImpl extends StockDetailRepository {
  final StockDetailGraphqlDatasource stockDetailGraphqlDatasource;

  StockDetailRepositoryImpl(this.stockDetailGraphqlDatasource);

  @override
  Future<Stock> getStockDetail(int stockId) async {
    return await stockDetailGraphqlDatasource.getStockDetail(stockId);
  }
}