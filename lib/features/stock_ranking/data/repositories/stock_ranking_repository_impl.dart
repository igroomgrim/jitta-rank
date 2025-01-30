import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/repositories/stock_ranking_repository.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_local_datasource.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  final StockRankingGraphqlDatasource graphqlDatasource;
  final StockRankingLocalDatasource localDatasource;
  final NetworkInfoService networkInfoService;

  StockRankingRepositoryImpl(this.graphqlDatasource, this.localDatasource, this.networkInfoService);

  @override
  Future<List<RankedStock>> getStockRankings(int limit, String market, int page, List<String> sectors) async {
    if (await networkInfoService.isConnected) {
      print('Internet connection - loading from remote');
      try {
        final rankedStocks = await graphqlDatasource.getStockRankings(limit, market, page, sectors);
        await localDatasource.saveStockRankings(rankedStocks);
        return rankedStocks;
      } catch (e) {
        throw Exception('Failed to fetch stock rankings from remote datasource');
      }
    } else {
      print('No internet connection - loading from local');
      final rankedStocksFromLocal = await localDatasource.getStockRankings(limit, market, page, sectors);
      return rankedStocksFromLocal;
    }
  }
}