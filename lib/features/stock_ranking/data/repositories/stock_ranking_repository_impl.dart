import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/repositories/stock_ranking_repository.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_local_datasource.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  final StockRankingGraphqlDatasource graphqlDatasource;
  final StockRankingLocalDatasource localDatasource;

  StockRankingRepositoryImpl(this.graphqlDatasource, this.localDatasource);

  @override
  Future<List<RankedStock>> getStockRankings(int limit, String market, int page, List<String> sectors) async {
    try {
      final rankedStocks = await graphqlDatasource.getStockRankings(limit, market, page, sectors);
      await localDatasource.saveStockRankings(rankedStocks);
      return rankedStocks;
    } catch (e) {
      final rankedStocksFromLocal = await localDatasource.getStockRankings(limit, market, page, sectors);
      return rankedStocksFromLocal;
    }
    // TODO: check internet connection or error, if error load from local
  }
}