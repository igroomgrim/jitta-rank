import 'package:jitta_rank/features/stock_detail/stock_detail.dart';

class MockStockDetailData {
  static Stock getMockStock() {
    return Stock(
      stockId: 1,
      symbol: 'Test Stock',
      name: 'Test Stock',
      nativeName: 'Test Stock',
      price: StockPrice(
        close: 100,
        latestPriceTimestamp: DateTime.now(),
      ),
      currency: 'Test Stock',
      currencySign: 'Test Stock',
      industry: 'Test Stock',
      market: 'Test Stock',
      jittaRankScore: 100,
      jitta: StockJitta(
        total: 100,
        score: 100,
        priceDiff: 100,
        factor: StockJittaFactor(
          growth: StockJittaFactorGrowth(
            value: 100,
            name: 'Test Stock',
            level: 'Test Stock',
          ),
          financial: StockJittaFactorFinancial(
            value: 100,
            name: 'Test Stock',
            level: 'Test Stock',
          ),
          management: StockJittaFactorManagement(
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
      graphPrice: StockGraphPrice(
        firstGraphPeriod: 'Test Stock',
        graphs: [
          StockGraphPriceItem(
            stockPrice: 100,
            linePrice: 100,
          ),
        ],
      ),
      summary: 'Test Stock',
      updatedAt: DateTime.now(),
    );
  }

  static StockModel getMockStockModel() {
    final mockStock = getMockStock();
    return StockModel(
      stockId: mockStock.stockId,
      symbol: mockStock.symbol,
      name: mockStock.name,
      nativeName: mockStock.nativeName,
      price: mockStock.price,
      currency: mockStock.currency,
      currencySign: mockStock.currencySign,
      industry: mockStock.industry,
      market: mockStock.market,
      jittaRankScore: mockStock.jittaRankScore,
      jitta: mockStock.jitta,
      lossChance: mockStock.lossChance,
      sectorName: mockStock.sectorName,
      ipoDate: mockStock.ipoDate,
      companyLink: mockStock.companyLink,
      graphPrice: mockStock.graphPrice,
      summary: mockStock.summary,
      updatedAt: mockStock.updatedAt,
    );
  }
}
