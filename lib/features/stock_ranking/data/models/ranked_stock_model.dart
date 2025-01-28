import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';

class RankedStockModel extends RankedStock {
  RankedStockModel({
    required super.id,
    required super.stockId,
    required super.symbol,
    required super.title,
    required super.jittaScore,
    required super.currency,
    required super.latestPrice,
    required super.industry,
    super.sector,
    required super.updatedAt,
  });

  factory RankedStockModel.fromJson(Map<String, dynamic> json) {
    final sectorJson = json['sector'];
    final sector = sectorJson != null 
      ? SectorModel.fromJson(sectorJson as Map<String, dynamic>)
      : Sector(id: 'Unknown', name: 'Unknown');

    return RankedStockModel(
      id: json['id'],
      stockId: json['stockId'],
      symbol: json['symbol'],
      title: json['title'],
      jittaScore: json['jittaScore']?.toDouble() ?? 0.0,
      currency: json['currency'],
      latestPrice: json['latestPrice']?.toDouble() ?? 0.0,
      industry: json['industry']?.toString() ?? 'Unknown',
      sector: sector,
      updatedAt: json['updatedAt'],
    );
  }
}

class SectorModel extends Sector {
  SectorModel({
    required super.id,
    required super.name,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
