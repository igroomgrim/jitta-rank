import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:hive/hive.dart';

part 'ranked_stock_model.g.dart';

@HiveType(typeId: 0)
class RankedStockModel extends RankedStock {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int stockId;
  @HiveField(2)
  final String symbol;
  @HiveField(3)
  final String title;
  @HiveField(4)
  final double jittaScore;
  @HiveField(5)
  final String currency;
  @HiveField(6)
  final double latestPrice;
  @HiveField(7)
  final String industry;
  @HiveField(8)
  final Sector sector;
  @HiveField(9)
  final DateTime updatedAt;

  RankedStockModel({
    required this.id,
    required this.stockId,
    required this.symbol,
    required this.title,
    required this.jittaScore,
    required this.currency,
    required this.latestPrice,
    required this.industry,
    required this.sector,
    required this.updatedAt,
  }) : super(
    id: id,
    stockId: stockId,
    symbol: symbol,
    title: title,
    jittaScore: jittaScore,
    currency: currency,
    latestPrice: latestPrice,
    industry: industry,
    sector: sector,
    updatedAt: updatedAt,
  );

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
      updatedAt: parseDateString(json['updatedAt']) ?? DateTime.now(),
    );
  }
}

@HiveType(typeId: 1)
class SectorModel extends Sector {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  SectorModel({
    required this.id,
    required this.name,
  }) : super(id: id, name: name);

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'],
      name: json['name'],
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