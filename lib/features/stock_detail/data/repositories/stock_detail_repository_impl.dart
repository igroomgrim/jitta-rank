import 'package:jitta_rank/features/stock_detail/domain/repositories/stock_detail_repository.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_local_datasource.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';

class StockDetailRepositoryImpl extends StockDetailRepository {
  final StockDetailGraphqlDatasource graphqlDatasource;
  final StockDetailLocalDatasource localDatasource;
  final NetworkInfoService networkInfoService;

  StockDetailRepositoryImpl(this.graphqlDatasource, this.localDatasource, this.networkInfoService);

  @override
  Future<Stock> getStockDetail(int stockId) async {
    if (await networkInfoService.isConnected) {
      try {
        final stockDetail = await graphqlDatasource.getStockDetail(stockId);
        await localDatasource.saveStockDetail(stockDetail);
        return stockDetail;
      } catch (e) {
        throw Exception('Failed to fetch stock detail');
      }
    } else {
      print('StockDetailRepositoryImpl: OFFLINE - loading from local');
      final stockDetailFromLocal = await localDatasource.getStockDetail(stockId);
      return stockDetailFromLocal;
    }
  }
}
