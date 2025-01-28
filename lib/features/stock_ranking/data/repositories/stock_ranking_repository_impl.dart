import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/repositories/stock_ranking_repository.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_graphql_datasource.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  final StockRankingGraphqlDatasource stockRankingGraphqlDatasource;

  StockRankingRepositoryImpl(this.stockRankingGraphqlDatasource);

  @override
  Future<List<RankedStock>> getStockRankings(int limit, String market, int page, List<String> sectors) async {
    return await stockRankingGraphqlDatasource.getStockRankings(limit, market, page, sectors);
  }
}