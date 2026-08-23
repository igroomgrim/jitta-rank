import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 11)
class StockModel extends Stock {
  const StockModel({
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
  }) : super(
          stockId: stockId,
          symbol: symbol,
          name: name,
          nativeName: nativeName,
          price: price,
          currency: currency,
          currencySign: currencySign,
          industry: industry,
          market: market,
          jittaRankScore: jittaRankScore,
          jitta: jitta,
          lossChance: lossChance,
          sectorName: sectorName,
          ipoDate: ipoDate,
          companyLink: companyLink,
          graphPrice: graphPrice,
          summary: summary,
          updatedAt: updatedAt,
        );

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      stockId: json['stockId']?.toInt() ?? 0,
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nativeName: json['nativeName']?.toString() ?? '',
      price: StockPriceModel.fromJson(json['price']),
      currency: json['currency']?.toString() ?? '',
      currencySign: json['currency_sign']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      market: json['market']?.toString() ?? '',
      jittaRankScore: json['jittaRankScore']?.toDouble() ?? 0.0,
      jitta: StockJittaModel.fromJson(json['jitta']),
      lossChance: json['loss_chance']['last']?.toDouble() ?? 0.0,
      sectorName: json['sector']['name']?.toString() ?? '',
      ipoDate: parseDateString(json['company']['ipo_date']),
      companyLink: json['company']['link'][0]['url']?.toString() ?? '',
      graphPrice: StockGraphPriceModel.fromJson(json['graph_price']),
      summary: json['summary']?.toString() ?? '',
      updatedAt: parseDateString(json['updatedAt']),
    );
  }
  @override
  @HiveField(0)
  final int stockId;
  @override
  @HiveField(1)
  final String symbol;
  @override
  @HiveField(2)
  final String name;
  @override
  @HiveField(3)
  final String nativeName;
  @override
  @HiveField(4)
  final StockPrice price;
  @override
  @HiveField(5)
  final String currency;
  @override
  @HiveField(6)
  final String currencySign;
  @override
  @HiveField(7)
  final String industry;
  @override
  @HiveField(8)
  final String market;
  @override
  @HiveField(9)
  final double jittaRankScore;
  @override
  @HiveField(10)
  final StockJitta jitta;
  @override
  @HiveField(11)
  final double lossChance;
  @override
  @HiveField(12)
  final String sectorName;
  @override
  @HiveField(13)
  final DateTime? ipoDate;
  @override
  @HiveField(14)
  final String companyLink;
  @override
  @HiveField(15)
  final StockGraphPrice graphPrice;
  @override
  @HiveField(16)
  final String summary;
  @override
  @HiveField(17)
  final DateTime? updatedAt;
}

@HiveType(typeId: 12)
class StockPriceModel extends StockPrice {
  const StockPriceModel({
    required this.close,
    this.latestPriceTimestamp,
  }) : super(
          close: close,
          latestPriceTimestamp: latestPriceTimestamp,
        );

  factory StockPriceModel.fromJson(Map<String, dynamic>? json) {
    if (json?['latest'] == null) return const StockPriceModel(close: 0.0);
    final latestPrice = json?['latest'];

    return StockPriceModel(
      close: latestPrice['close']?.toDouble() ?? 0.0,
      latestPriceTimestamp:
          parseDateString(latestPrice['latest_price_timestamp']),
    );
  }
  @override
  @HiveField(0)
  final double close;
  @override
  @HiveField(1)
  final DateTime? latestPriceTimestamp;
}

@HiveType(typeId: 13)
class StockJittaModel extends StockJitta {
  const StockJittaModel({
    required this.total,
    required this.score,
    required this.priceDiff,
    required this.factor,
  }) : super(
          total: total,
          score: score,
          priceDiff: priceDiff,
          factor: factor,
        );

  factory StockJittaModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaModel(
      total: json?['score']['total']?.toInt() ?? 0,
      score: json?['score']['last']['value']?.toDouble() ?? 0.0,
      priceDiff: json?['priceDiff']['last']['value']?.toDouble() ?? 0.0,
      factor: StockJittaFactorModel.fromJson(json?['factor']['last']['value']),
    );
  }
  @override
  @HiveField(0)
  final int total;
  @override
  @HiveField(1)
  final double score;
  @override
  @HiveField(2)
  final double priceDiff;
  @override
  @HiveField(3)
  final StockJittaFactor factor;
}

@HiveType(typeId: 14)
class StockJittaFactorModel extends StockJittaFactor {
  const StockJittaFactorModel({
    required this.growth,
    required this.financial,
    required this.management,
  }) : super(
          growth: growth,
          financial: financial,
          management: management,
        );

  factory StockJittaFactorModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorModel(
      growth: StockJittaFactorGrowthModel.fromJson(json?['growth']),
      financial: StockJittaFactorFinancialModel.fromJson(json?['financial']),
      management: StockJittaFactorManagementModel.fromJson(json?['management']),
    );
  }
  @override
  @HiveField(0)
  final StockJittaFactorGrowth growth;
  @override
  @HiveField(1)
  final StockJittaFactorFinancial financial;
  @override
  @HiveField(2)
  final StockJittaFactorManagement management;
}

@HiveType(typeId: 15)
class StockJittaFactorGrowthModel extends StockJittaFactorGrowth {
  const StockJittaFactorGrowthModel({
    required this.value,
    required this.name,
    required this.level,
  }) : super(
          value: value,
          name: name,
          level: level,
        );

  factory StockJittaFactorGrowthModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorGrowthModel(
      value: json?['value']?.toInt() ?? 0,
      name: json?['name']?.toString() ?? '',
      level: json?['level']?.toString() ?? '',
    );
  }
  @override
  @HiveField(0)
  final int value;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String level;
}

@HiveType(typeId: 16)
class StockJittaFactorFinancialModel extends StockJittaFactorFinancial {
  const StockJittaFactorFinancialModel({
    required this.value,
    required this.name,
    required this.level,
  }) : super(
          value: value,
          name: name,
          level: level,
        );

  factory StockJittaFactorFinancialModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorFinancialModel(
      value: json?['value']?.toInt() ?? 0,
      name: json?['name']?.toString() ?? '',
      level: json?['level']?.toString() ?? '',
    );
  }
  @override
  @HiveField(0)
  final int value;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String level;
}

@HiveType(typeId: 17)
class StockJittaFactorManagementModel extends StockJittaFactorManagement {
  const StockJittaFactorManagementModel({
    required this.value,
    required this.name,
    required this.level,
  }) : super(
          value: value,
          name: name,
          level: level,
        );

  factory StockJittaFactorManagementModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorManagementModel(
      value: json?['value']?.toInt() ?? 0,
      name: json?['name']?.toString() ?? '',
      level: json?['level']?.toString() ?? '',
    );
  }
  @override
  @HiveField(0)
  final int value;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String level;
}

@HiveType(typeId: 18)
class StockGraphPriceModel extends StockGraphPrice {
  const StockGraphPriceModel({
    required this.firstGraphPeriod,
    required this.graphs,
  }) : super(
          firstGraphPeriod: firstGraphPeriod,
          graphs: graphs,
        );

  factory StockGraphPriceModel.fromJson(Map<String, dynamic>? json) {
    const emptyGraph = StockGraphPriceModel(firstGraphPeriod: '', graphs: []);
    if (json == null) return emptyGraph;
    final graphs = json['graphs'];
    if (graphs == null) return emptyGraph;

    try {
      final graphsList = (graphs as List)
          .map((graph) => StockGraphPriceItemModel.fromJson(graph))
          .toList();

      return StockGraphPriceModel(
        firstGraphPeriod: json['first_graph_period']?.toString() ?? '',
        graphs: graphsList,
      );
    } catch (e) {
      return emptyGraph;
    }
  }
  @override
  @HiveField(0)
  final String firstGraphPeriod;
  @override
  @HiveField(1)
  final List<StockGraphPriceItem> graphs;
}

@HiveType(typeId: 19)
class StockGraphPriceItemModel extends StockGraphPriceItem {
  const StockGraphPriceItemModel({
    required this.stockPrice,
    required this.linePrice,
  }) : super(
          stockPrice: stockPrice,
          linePrice: linePrice,
        );

  factory StockGraphPriceItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StockGraphPriceItemModel(stockPrice: 0.0, linePrice: 0.0);
    }
    return StockGraphPriceItemModel(
      stockPrice: json['stockPrice']?.toDouble() ?? 0.0,
      linePrice: json['linePrice']?.toDouble() ?? 0.0,
    );
  }
  @override
  @HiveField(0)
  final double stockPrice;
  @override
  @HiveField(1)
  final double linePrice;
}

// Utility function to convert date string to DateTime
DateTime? parseDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    return null;
  }
}
