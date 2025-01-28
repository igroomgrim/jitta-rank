import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/repositories/stock_ranking_repository.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_graphql_datasource.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  final StockRankingGraphqlDatasource stockRankingGraphqlDatasource;

  StockRankingRepositoryImpl(this.stockRankingGraphqlDatasource);

  @override
  Future<List<RankedStock>> getStockRankings() async {
    // List<RankedStock> mockRankedStocks = [
    //   RankedStock(
    //     id: '1',
    //     stockId: 1,
    //     symbol: 'AAPL',
    //     title: 'Apple',
    //     jittaScore: 100,
    //     currency: 'USD',
    //     latestPrice: 100,
    //     industry: 'Technology',
    //     sector: Sector(id: '1', name: 'Consumer Electronics'),
    //     updatedAt: DateTime.now(),
    //   ),
    //   RankedStock(
    //     id: '2',
    //     stockId: 2,
    //     symbol: 'GOOGL',
    //     title: 'Google',
    //     jittaScore: 90,
    //     currency: 'USD',
    //     latestPrice: 200,
    //     industry: 'Technology',
    //     sector: Sector(id: '2', name: 'Consumer Electronics'),
    //     updatedAt: DateTime.now(),
    //   ),
    // ];
    return await stockRankingGraphqlDatasource.getStockRankings();
  }
}