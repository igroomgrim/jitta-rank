import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

part 'stock_model.g.dart';

/// Persistence/transport representation of [Stock].
///
/// Does NOT extend the entity — the data layer owns Hive annotations and JSON
/// parsing, and hands the domain a plain entity via [toEntity]. Nested fields
/// are typed as models, not entities, so the Hive adapters registered for the
/// model types match what is actually written.
@HiveType(typeId: 11)
class StockModel {
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
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      stockId: json.asInt('stockId'),
      symbol: json.asString('symbol'),
      name: json.asString('name'),
      nativeName: json.asString('nativeName'),
      price: StockPriceModel.fromJson(json.asMap('price')),
      currency: json.asString('currency'),
      currencySign: json.asString('currency_sign'),
      industry: json.asString('industry'),
      market: json.asString('market'),
      jittaRankScore: json.asDouble('jittaRankScore'),
      jitta: StockJittaModel.fromJson(json.asMap('jitta')),
      lossChance: json.asMap('loss_chance').asDouble('last'),
      sectorName: json.asMap('sector').asString('name'),
      ipoDate:
          parseDateString(json.asMap('company').asStringOrNull('ipo_date')),
      companyLink: json
          .asMap('company')
          .asMapList('link')
          .firstMapOrEmpty
          .asString('url'),
      graphPrice: StockGraphPriceModel.fromJson(json.asMap('graph_price')),
      summary: json.asString('summary'),
      updatedAt: parseDateString(json.asStringOrNull('updatedAt')),
    );
  }

  @HiveField(0)
  final int stockId;
  @HiveField(1)
  final String symbol;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String nativeName;
  @HiveField(4)
  final StockPriceModel price;
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
  final StockJittaModel jitta;
  @HiveField(11)
  final double lossChance;
  @HiveField(12)
  final String sectorName;
  @HiveField(13)
  final DateTime? ipoDate;
  @HiveField(14)
  final String companyLink;
  @HiveField(15)
  final StockGraphPriceModel graphPrice;
  @HiveField(16)
  final String summary;
  @HiveField(17)
  final DateTime? updatedAt;

  Stock toEntity() => Stock(
        stockId: stockId,
        symbol: symbol,
        name: name,
        nativeName: nativeName,
        price: price.toEntity(),
        currency: currency,
        currencySign: currencySign,
        industry: industry,
        market: market,
        jittaRankScore: jittaRankScore,
        jitta: jitta.toEntity(),
        lossChance: lossChance,
        sectorName: sectorName,
        ipoDate: ipoDate,
        companyLink: companyLink,
        graphPrice: graphPrice.toEntity(),
        summary: summary,
        updatedAt: updatedAt,
      );
}

@HiveType(typeId: 12)
class StockPriceModel {
  const StockPriceModel({required this.close, this.latestPriceTimestamp});

  factory StockPriceModel.fromJson(Map<String, dynamic> json) {
    final latest = json.asMap('latest');
    if (latest.isEmpty) return const StockPriceModel(close: 0.0);
    return StockPriceModel(
      close: latest.asDouble('close'),
      latestPriceTimestamp: parseDateString(
        latest.asStringOrNull('latest_price_timestamp'),
      ),
    );
  }

  @HiveField(0)
  final double close;
  @HiveField(1)
  final DateTime? latestPriceTimestamp;

  StockPrice toEntity() =>
      StockPrice(close: close, latestPriceTimestamp: latestPriceTimestamp);
}

@HiveType(typeId: 13)
class StockJittaModel {
  const StockJittaModel({
    required this.total,
    required this.score,
    required this.priceDiff,
    required this.factor,
  });

  factory StockJittaModel.fromJson(Map<String, dynamic> json) {
    final score = json.asMap('score');
    return StockJittaModel(
      total: score.asInt('total'),
      score: score.asMap('last').asDouble('value'),
      priceDiff: json.asMap('priceDiff').asMap('last').asDouble('value'),
      factor: StockJittaFactorModel.fromJson(
        json.asMap('factor').asMap('last').asMap('value'),
      ),
    );
  }

  @HiveField(0)
  final int total;
  @HiveField(1)
  final double score;
  @HiveField(2)
  final double priceDiff;
  @HiveField(3)
  final StockJittaFactorModel factor;

  StockJitta toEntity() => StockJitta(
        total: total,
        score: score,
        priceDiff: priceDiff,
        factor: factor.toEntity(),
      );
}

@HiveType(typeId: 14)
class StockJittaFactorModel {
  const StockJittaFactorModel({
    required this.growth,
    required this.financial,
    required this.management,
  });

  factory StockJittaFactorModel.fromJson(Map<String, dynamic> json) =>
      StockJittaFactorModel(
        growth: StockJittaFactorGrowthModel.fromJson(json.asMap('growth')),
        financial: StockJittaFactorFinancialModel.fromJson(
          json.asMap('financial'),
        ),
        management: StockJittaFactorManagementModel.fromJson(
          json.asMap('management'),
        ),
      );

  @HiveField(0)
  final StockJittaFactorGrowthModel growth;
  @HiveField(1)
  final StockJittaFactorFinancialModel financial;
  @HiveField(2)
  final StockJittaFactorManagementModel management;

  StockJittaFactor toEntity() => StockJittaFactor(
        growth: growth.toEntity(),
        financial: financial.toEntity(),
        management: management.toEntity(),
      );
}

@HiveType(typeId: 15)
class StockJittaFactorGrowthModel {
  const StockJittaFactorGrowthModel({
    required this.value,
    required this.name,
    required this.level,
  });

  factory StockJittaFactorGrowthModel.fromJson(Map<String, dynamic> json) =>
      StockJittaFactorGrowthModel(
        value: json.asInt('value'),
        name: json.asString('name'),
        level: json.asString('level'),
      );

  @HiveField(0)
  final int value;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String level;

  StockJittaFactorGrowth toEntity() =>
      StockJittaFactorGrowth(value: value, name: name, level: level);
}

@HiveType(typeId: 16)
class StockJittaFactorFinancialModel {
  const StockJittaFactorFinancialModel({
    required this.value,
    required this.name,
    required this.level,
  });

  factory StockJittaFactorFinancialModel.fromJson(Map<String, dynamic> json) =>
      StockJittaFactorFinancialModel(
        value: json.asInt('value'),
        name: json.asString('name'),
        level: json.asString('level'),
      );

  @HiveField(0)
  final int value;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String level;

  StockJittaFactorFinancial toEntity() =>
      StockJittaFactorFinancial(value: value, name: name, level: level);
}

@HiveType(typeId: 17)
class StockJittaFactorManagementModel {
  const StockJittaFactorManagementModel({
    required this.value,
    required this.name,
    required this.level,
  });

  factory StockJittaFactorManagementModel.fromJson(Map<String, dynamic> json) =>
      StockJittaFactorManagementModel(
        value: json.asInt('value'),
        name: json.asString('name'),
        level: json.asString('level'),
      );

  @HiveField(0)
  final int value;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String level;

  StockJittaFactorManagement toEntity() =>
      StockJittaFactorManagement(value: value, name: name, level: level);
}

@HiveType(typeId: 18)
class StockGraphPriceModel {
  const StockGraphPriceModel({
    required this.firstGraphPeriod,
    required this.graphs,
  });

  factory StockGraphPriceModel.fromJson(Map<String, dynamic> json) {
    const empty = StockGraphPriceModel(firstGraphPeriod: '', graphs: []);
    if (json.isEmpty) return empty;
    final graphs = json.asMapList('graphs');
    if (graphs.isEmpty) return empty;
    return StockGraphPriceModel(
      firstGraphPeriod: json.asString('first_graph_period'),
      graphs: graphs.map(StockGraphPriceItemModel.fromJson).toList(),
    );
  }

  @HiveField(0)
  final String firstGraphPeriod;
  @HiveField(1)
  final List<StockGraphPriceItemModel> graphs;

  StockGraphPrice toEntity() => StockGraphPrice(
        firstGraphPeriod: firstGraphPeriod,
        graphs: graphs.map((g) => g.toEntity()).toList(),
      );
}

@HiveType(typeId: 19)
class StockGraphPriceItemModel {
  const StockGraphPriceItemModel({
    required this.stockPrice,
    required this.linePrice,
  });

  factory StockGraphPriceItemModel.fromJson(Map<String, dynamic> json) =>
      StockGraphPriceItemModel(
        stockPrice: json.asDouble('stockPrice'),
        linePrice: json.asDouble('linePrice'),
      );

  @HiveField(0)
  final double stockPrice;
  @HiveField(1)
  final double linePrice;

  StockGraphPriceItem toEntity() =>
      StockGraphPriceItem(stockPrice: stockPrice, linePrice: linePrice);
}

/// Lenient date parsing: the API returns null and empty strings for several
/// date fields.
DateTime? parseDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateTime.parse(dateString);
  } catch (_) {
    return null;
  }
}

/// Typed, total accessors over a decoded JSON map.
///
/// The GraphQL schema makes almost everything nullable and the response nests
/// deeply (`jitta.factor.last.value.growth`). These return a zero value rather
/// than throwing, which keeps a partial response renderable — the same
/// behaviour the previous `json['a']['b']` chains had, but without the dynamic
/// calls and without a NoSuchMethodError when an intermediate node is null.
extension _JsonMapX on Map<String, dynamic> {
  Map<String, dynamic> asMap(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : const <String, dynamic>{};
  }

  List<Map<String, dynamic>> asMapList(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  String asString(String key) => this[key]?.toString() ?? '';

  String? asStringOrNull(String key) => this[key]?.toString();

  int asInt(String key) => (this[key] as num?)?.toInt() ?? 0;

  double asDouble(String key) => (this[key] as num?)?.toDouble() ?? 0.0;
}

extension _MapListX on List<Map<String, dynamic>> {
  Map<String, dynamic> get firstMapOrEmpty =>
      isEmpty ? const <String, dynamic>{} : first;
}
