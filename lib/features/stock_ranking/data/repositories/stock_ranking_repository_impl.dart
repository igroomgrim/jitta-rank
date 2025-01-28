import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/repositories/stock_ranking_repository.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  @override
  Future<List<RankedStock>> getStockRankings() async {
    List<RankedStock> mockRankedStocks = [
      RankedStock(
        id: '1',
        stockId: 1,
        symbol: 'AAPL',
        title: 'Apple',
        jittaScore: 100,
        currency: 'USD',
        latestPrice: 100,
        industry: 'Technology',
        sector: Sector(id: '1', name: 'Consumer Electronics'),
        updatedAt: DateTime.now(),
      ),
      RankedStock(
        id: '2',
        stockId: 2,
        symbol: 'GOOGL',
        title: 'Google',
        jittaScore: 90,
        currency: 'USD',
        latestPrice: 200,
        industry: 'Technology',
        sector: Sector(id: '2', name: 'Consumer Electronics'),
        updatedAt: DateTime.now(),
      ),
    ];
    return mockRankedStocks;
  }
}