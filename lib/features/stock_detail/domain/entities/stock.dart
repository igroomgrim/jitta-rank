class Stock {
  final int stockId;
  final String symbol;
  final String name;
  final String nativeName;
  final StockPrice price;
  final String currency;
  final String currencySign;
  final String industry;
  final String market;
  final double jittaRankScore;
  final StockJitta jitta;
  final double lossChance; // loss_chance.last
  final String sectorName; // sector.name
  final DateTime? ipoDate; // company.ipo_date
  final String companyLink; // company.link[0].url
  final StockGraphPrice graphPrice;
  final String summary;
  final DateTime? updatedAt;

  Stock({
    required this.stockId,
    required this.symbol,
    required this.name,
    required this.nativeName,
    required this.price,
    required this.currency,
    required this.currencySign,
    required this.industry,
    required this.market,
    required this.jittaRankScore,
    required this.jitta,
    required this.lossChance,
    required this.sectorName,
    required this.ipoDate,
    required this.companyLink,
    required this.graphPrice,
    required this.summary,
    required this.updatedAt,
  });
}

class StockPrice {
  final double close; // latest.close
  final DateTime? latestPriceTimestamp; // latest.latest_price_timestamp

  StockPrice({
    required this.close,
    this.latestPriceTimestamp,
  });
}

class StockJitta {
  final int total; // score.total
  final double score; // score.last.value
  final double priceDiff; // priceDiff.last.value
  final StockJittaFactor factor;

  StockJitta({
    required this.total,
    required this.score,
    required this.priceDiff,
    required this.factor,
  });
}

class StockJittaFactor {
  final StockJittaFactorGrowth growth; // factor.last.value.growth
  final StockJittaFactorFinancial financial; // factor.last.value.financial
  final StockJittaFactorManagement management; // factor.last.value.management

  StockJittaFactor({
    required this.growth,
    required this.financial,
    required this.management,
  });
}

class StockJittaFactorGrowth {
  final int value;
  final String name;
  final String level;

  StockJittaFactorGrowth({
    required this.value,
    required this.name,
    required this.level,
  });
}

class StockJittaFactorFinancial {
  final int value;
  final String name;
  final String level;

  StockJittaFactorFinancial({
    required this.value,
    required this.name,
    required this.level,
  });
}

class StockJittaFactorManagement {
  final int value;
  final String name;
  final String level;

  StockJittaFactorManagement({
    required this.value,
    required this.name,
    required this.level,
  });
}

class StockGraphPrice {
  final String firstGraphPeriod;
  final List<StockGraphPriceItem> graphs;

  StockGraphPrice({
    required this.firstGraphPeriod,
    required this.graphs,
  });
}

class StockGraphPriceItem {
  final double stockPrice;
  final double linePrice;

  StockGraphPriceItem({
    required this.stockPrice,
    required this.linePrice,
  });
}
