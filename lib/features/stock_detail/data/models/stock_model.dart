import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

class StockModel extends Stock {
  StockModel({
    required super.stockId,
    required super.symbol,
    required super.name,
    required super.nativeName,
    required super.price,
    required super.currency,
    required super.currencySign,
    required super.industry,
    required super.market,
    required super.jittaRankScore,
    required super.jitta,
    required super.lossChance,
    required super.sectorName,
    required super.ipoDate,
    required super.companyLink,
    required super.graphPrice,
    required super.summary,
    required super.updatedAt,
  });

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

class StockPriceModel extends StockPrice {
  StockPriceModel({
    required super.close,
    super.latestPriceTimestamp,
  });

  factory StockPriceModel.fromJson(Map<String, dynamic>? json) {
    if (json?['latest'] == null) return StockPriceModel(close: 0.0);
    final latestPrice = json?['latest'];
    
    return StockPriceModel(
      close: latestPrice['close']?.toDouble() ?? 0.0,
      latestPriceTimestamp: parseDateString(latestPrice['latest_price_timestamp']),
    );
  }
}

class StockJittaModel extends StockJitta {
  StockJittaModel({
    required super.total,
    required super.score,
    required super.priceDiff,
    required super.factor,
  });

  factory StockJittaModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaModel(
      total: json?['score']['total']?.toInt() ?? 0,
      score: json?['score']['last']['value']?.toDouble() ?? 0.0,
      priceDiff: json?['priceDiff']['last']['value']?.toDouble() ?? 0.0,
      factor: StockJittaFactorModel.fromJson(json?['factor']['last']['value']),
    );
  }
}

class StockJittaFactorModel extends StockJittaFactor {
  StockJittaFactorModel({
    required super.growth,
    required super.financial,
    required super.management,
  });

  factory StockJittaFactorModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorModel(
      growth: StockJittaFactorGrowthModel.fromJson(json?['growth']),
      financial: StockJittaFactorFinancialModel.fromJson(json?['financial']),
      management: StockJittaFactorManagementModel.fromJson(json?['management']),
    );
  }
}

class StockJittaFactorGrowthModel extends StockJittaFactorGrowth {
  StockJittaFactorGrowthModel({
    required super.value,
    required super.name,
    required super.level,
  });

  factory StockJittaFactorGrowthModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorGrowthModel(
      value: json?['value']?.toInt() ?? 0,
      name: json?['name']?.toString() ?? '',
      level: json?['level']?.toString() ?? '',
    );
  }
}

class StockJittaFactorFinancialModel extends StockJittaFactorFinancial {
  StockJittaFactorFinancialModel({
    required super.value,
    required super.name,
    required super.level,
  });

  factory StockJittaFactorFinancialModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorFinancialModel(
      value: json?['value']?.toInt() ?? 0,
      name: json?['name']?.toString() ?? '',
      level: json?['level']?.toString() ?? '',
    );
  }
}

class StockJittaFactorManagementModel extends StockJittaFactorManagement {
  StockJittaFactorManagementModel({
    required super.value,
    required super.name,
    required super.level,
  });

  factory StockJittaFactorManagementModel.fromJson(Map<String, dynamic>? json) {
    return StockJittaFactorManagementModel(
      value: json?['value']?.toInt() ?? 0,
      name: json?['name']?.toString() ?? '',
      level: json?['level']?.toString() ?? '',
    );
  }
}

class StockGraphPriceModel extends StockGraphPrice {
  StockGraphPriceModel({
    required super.firstGraphPeriod,
    required super.graphs,
  });

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

class StockGraphPriceItemModel extends StockGraphPriceItem {
  StockGraphPriceItemModel({
    required super.stockPrice,
    required super.linePrice,
  });

  factory StockGraphPriceItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StockGraphPriceItemModel(stockPrice: 0.0, linePrice: 0.0);
    return StockGraphPriceItemModel(
      stockPrice: 0.0,
      linePrice: 0.0,
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