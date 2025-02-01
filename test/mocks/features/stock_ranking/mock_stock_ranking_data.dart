import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class MockStockRankingData {
  static RankedStock getMockRankedStock() {
    return RankedStock(
      id: '1',
      stockId: 1,
      symbol: 'Test Stock',
      title: 'Test Stock',
      jittaScore: 100,
      currency: 'Test Stock',
      latestPrice: 100,
      industry: 'Test Stock',
      updatedAt: DateTime.now(),
      sector: Sector(
        id: '1',
        name: 'Test Stock',
      ),
      market: 'Test Stock',
    );
  }

  static RankedStockModel getMockRankedStockModel() {
    final mockRankedStock = getMockRankedStock();
    return RankedStockModel(
      id: mockRankedStock.id,
      stockId: mockRankedStock.stockId,
      symbol: mockRankedStock.symbol,
      title: mockRankedStock.title,
      jittaScore: mockRankedStock.jittaScore,
      currency: mockRankedStock.currency,
      latestPrice: mockRankedStock.latestPrice,
      industry: mockRankedStock.industry,
      updatedAt: mockRankedStock.updatedAt,
      sector: mockRankedStock.sector != null
          ? SectorModel(
              id: mockRankedStock.sector!.id,
              name: mockRankedStock.sector!.name,
            )
          : null,
      market: mockRankedStock.market,
    );
  }

  static List<RankedStock> getMockStockRankings() {
    return [getMockRankedStock()];
  }

  static List<RankedStock> getMockStockRankingsWithLoadMore() {
    return [getMockRankedStock(), getMockRankedStock()];
  }
}
