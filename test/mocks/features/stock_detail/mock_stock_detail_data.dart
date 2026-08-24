import 'package:jitta_rank/features/stock_detail/stock_detail.dart';

class MockStockDetailData {
  /// The model is the source of truth; the entity is derived from it so the
  /// two can never drift apart in tests.
  static StockModel getMockStockModel() {
    return StockModel(
      stockId: 1,
      symbol: 'Test Stock',
      name: 'Test Stock',
      nativeName: 'Test Stock',
      price: StockPriceModel(
        close: 100,
        latestPriceTimestamp: DateTime.now(),
      ),
      currency: 'Test Stock',
      currencySign: 'Test Stock',
      industry: 'Test Stock',
      market: 'Test Stock',
      jittaRankScore: 100,
      jitta: const StockJittaModel(
        total: 100,
        score: 100,
        priceDiff: 100,
        factor: StockJittaFactorModel(
          growth: StockJittaFactorGrowthModel(
            value: 100,
            name: 'Test Stock',
            level: 'Test Stock',
          ),
          financial: StockJittaFactorFinancialModel(
            value: 100,
            name: 'Test Stock',
            level: 'Test Stock',
          ),
          management: StockJittaFactorManagementModel(
            value: 100,
            name: 'Test Stock',
            level: 'Test Stock',
          ),
        ),
      ),
      lossChance: 100,
      sectorName: 'Test Stock',
      ipoDate: DateTime.now(),
      companyLink: 'Test Stock',
      graphPrice: const StockGraphPriceModel(
        firstGraphPeriod: 'Test Stock',
        graphs: [StockGraphPriceItemModel(stockPrice: 100, linePrice: 100)],
      ),
      summary: 'Test Stock',
      updatedAt: DateTime.now(),
    );
  }

  static Stock getMockStock() => getMockStockModel().toEntity();
}
