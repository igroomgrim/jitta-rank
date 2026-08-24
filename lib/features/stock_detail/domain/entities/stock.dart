import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  const Stock({
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

  @override
  List<Object?> get props => [
        stockId,
        symbol,
        name,
        nativeName,
        price,
        currency,
        currencySign,
        industry,
        market,
        jittaRankScore,
        jitta,
        lossChance,
        sectorName,
        ipoDate,
        companyLink,
        graphPrice,
        summary,
        updatedAt,
      ];
}

class StockPrice extends Equatable {
  // latest.latest_price_timestamp

  const StockPrice({
    required this.close,
    this.latestPriceTimestamp,
  });
  final double close; // latest.close
  final DateTime? latestPriceTimestamp;

  @override
  List<Object?> get props => [close, latestPriceTimestamp];
}

class StockJitta extends Equatable {
  const StockJitta({
    required this.total,
    required this.score,
    required this.priceDiff,
    required this.factor,
  });
  final int total; // score.total
  final double score; // score.last.value
  final double priceDiff; // priceDiff.last.value
  final StockJittaFactor factor;

  @override
  List<Object?> get props => [total, score, priceDiff, factor];
}

class StockJittaFactor extends Equatable {
  // factor.last.value.management

  const StockJittaFactor({
    required this.growth,
    required this.financial,
    required this.management,
  });
  final StockJittaFactorGrowth growth; // factor.last.value.growth
  final StockJittaFactorFinancial financial; // factor.last.value.financial
  final StockJittaFactorManagement management;

  @override
  List<Object?> get props => [growth, financial, management];
}

class StockJittaFactorGrowth extends Equatable {
  const StockJittaFactorGrowth({
    required this.value,
    required this.name,
    required this.level,
  });
  final int value;
  final String name;
  final String level;

  @override
  List<Object?> get props => [value, name, level];
}

class StockJittaFactorFinancial extends Equatable {
  const StockJittaFactorFinancial({
    required this.value,
    required this.name,
    required this.level,
  });
  final int value;
  final String name;
  final String level;

  @override
  List<Object?> get props => [value, name, level];
}

class StockJittaFactorManagement extends Equatable {
  const StockJittaFactorManagement({
    required this.value,
    required this.name,
    required this.level,
  });
  final int value;
  final String name;
  final String level;

  @override
  List<Object?> get props => [value, name, level];
}

class StockGraphPrice extends Equatable {
  const StockGraphPrice({
    required this.firstGraphPeriod,
    required this.graphs,
  });
  final String firstGraphPeriod;
  final List<StockGraphPriceItem> graphs;

  @override
  List<Object?> get props => [firstGraphPeriod, graphs];
}

class StockGraphPriceItem extends Equatable {
  const StockGraphPriceItem({
    required this.stockPrice,
    required this.linePrice,
  });
  final double stockPrice;
  final double linePrice;

  @override
  List<Object?> get props => [stockPrice, linePrice];
}
