import 'package:jitta_rank/features/stock_detail/domain/repositories/stock_detail_repository.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_local_datasource.dart';

class StockDetailRepositoryImpl extends StockDetailRepository {
  final StockDetailGraphqlDatasource graphqlDatasource;
  final StockDetailLocalDatasource localDatasource;

  StockDetailRepositoryImpl(this.graphqlDatasource, this.localDatasource);

  @override
  Future<Stock> getStockDetail(int stockId) async {
    try {
      final stockDetail = await graphqlDatasource.getStockDetail(stockId);
      await localDatasource.saveStockDetail(stockDetail);
      return stockDetail;
    } catch (e) {
      final stockDetailFromLocal = await localDatasource.getStockDetail(stockId);
      return stockDetailFromLocal;
      // TODO: handle error from internet connection or another error
    }
  }
}