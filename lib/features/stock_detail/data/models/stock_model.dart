import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import 'package:hive/hive.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 11)
class StockModel extends Stock {
  @HiveField(0)
  final int stockId;
  @HiveField(1)
  final String symbol;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String nativeName;
  @HiveField(4)
  final StockPrice price;
  @HiveField(5)
  final String currency;
  @HiveField(6)
  final String currencySign;
  @HiveField(7)
  final String industry;
  @HiveField(8)
  final String market;
  @HiveField(9)
  final double jittaRankScore;
  @HiveField(10)
  final StockJitta jitta;
  @HiveField(11)
  final double lossChance;
  @HiveField(12)
  final String sectorName;
  @HiveField(13)
  final DateTime? ipoDate;
  @HiveField(14)
  final String companyLink;
  @HiveField(15)
  final StockGraphPrice graphPrice;
  @HiveField(16)
  final String summary;
  @HiveField(17)
  final DateTime? updatedAt;

  StockModel({
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
}

@HiveType(typeId: 12)
class StockPriceModel extends StockPrice {
  @HiveField(0)
  final double close;
  @HiveField(1)
  final DateTime? latestPriceTimestamp;

  StockPriceModel({
    required this.close,
    this.latestPriceTimestamp,
  }) : super(
    close: close,
    latestPriceTimestamp: latestPriceTimestamp,
  );

  factory StockPriceModel.fromJson(Map<String, dynamic>? json) {
    if (json?['latest'] == null) return StockPriceModel(close: 0.0);
    final latestPrice = json?['latest'];
    
    return StockPriceModel(
      close: latestPrice['close']?.toDouble() ?? 0.0,
      latestPriceTimestamp: parseDateString(latestPrice['latest_price_timestamp']),
    );
  }
}

@HiveType(typeId: 13)
class StockJittaModel extends StockJitta {
  @HiveField(0)
  final int total;
  @HiveField(1)
  final double score;
  @HiveField(2)
  final double priceDiff;
  @HiveField(3)
  final StockJittaFactor factor;

  StockJittaModel({
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
}

@HiveType(typeId: 14)
class StockJittaFactorModel extends StockJittaFactor {
  @HiveField(0)
  final StockJittaFactorGrowth growth;
  @HiveField(1)
  final StockJittaFactorFinancial financial;
  @HiveField(2)
  final StockJittaFactorManagement management;

  StockJittaFactorModel({
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
}

@HiveType(typeId: 15)
class StockJittaFactorGrowthModel extends StockJittaFactorGrowth {
  @HiveField(0)
  final int value;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String level;

  StockJittaFactorGrowthModel({
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
}

@HiveType(typeId: 16)
class StockJittaFactorFinancialModel extends StockJittaFactorFinancial {
  @HiveField(0)
  final int value;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String level;

  StockJittaFactorFinancialModel({
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
}

@HiveType(typeId: 17)
class StockJittaFactorManagementModel extends StockJittaFactorManagement {
  @HiveField(0)
  final int value;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String level;

  StockJittaFactorManagementModel({
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
}

@HiveType(typeId: 18)
class StockGraphPriceModel extends StockGraphPrice {
  @HiveField(0)
  final String firstGraphPeriod;
  @HiveField(1)
  final List<StockGraphPriceItem> graphs;

  StockGraphPriceModel({
    required this.firstGraphPeriod,
    required this.graphs,
  }) : super(
    firstGraphPeriod: firstGraphPeriod,
    graphs: graphs,
  );

  factory StockGraphPriceModel.fromJson(Map<String, dynamic>? json) {
    final emptyGraph = StockGraphPriceModel(firstGraphPeriod: '', graphs: []);
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
}

@HiveType(typeId: 19)
class StockGraphPriceItemModel extends StockGraphPriceItem {
  @HiveField(0)
  final double stockPrice;
  @HiveField(1)
  final double linePrice;

  StockGraphPriceItemModel({
    required this.stockPrice,
    required this.linePrice,
  }) : super(
    stockPrice: stockPrice,
    linePrice: linePrice,
  );

  factory StockGraphPriceItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StockGraphPriceItemModel(stockPrice: 0.0, linePrice: 0.0);
    return StockGraphPriceItemModel(
      stockPrice: json['stockPrice']?.toDouble() ?? 0.0,
      linePrice: json['linePrice']?.toDouble() ?? 0.0,
    );
  }
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