import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';

part 'ranked_stock_model.g.dart';

@HiveType(typeId: 0)
class RankedStockModel extends RankedStock {
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
    required this.market,
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
          market: market,
          updatedAt: updatedAt,
        );

  factory RankedStockModel.fromJson(Map<String, dynamic> json) {
    final sectorJson = json['sector'];
    final sector = sectorJson != null
        ? SectorModel.fromJson(sectorJson as Map<String, dynamic>)
        : null;

    return RankedStockModel(
      id: json['id'],
      stockId: json['stockId'],
      symbol: json['symbol'] ?? '',
      title: json['title'] ?? '',
      jittaScore: json['jittaScore']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      latestPrice: json['latestPrice']?.toDouble() ?? 0.0,
      industry: json['industry']?.toString() ?? 'Unknown',
      sector: sector,
      market: json['market'] == null ? 'Unknown' : json['market'].toString(),
      updatedAt: parseDateString(json['updatedAt']) ?? DateTime.now(),
    );
  }
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final int stockId;
  @override
  @HiveField(2)
  final String symbol;
  @override
  @HiveField(3)
  final String title;
  @override
  @HiveField(4)
  final double jittaScore;
  @override
  @HiveField(5)
  final String currency;
  @override
  @HiveField(6)
  final double latestPrice;
  @override
  @HiveField(7)
  final String industry;
  @override
  @HiveField(8)
  final SectorModel? sector;
  @override
  @HiveField(9)
  final DateTime updatedAt;
  @override
  @HiveField(10)
  final String? market;
}

@HiveType(typeId: 1)
class SectorModel extends Sector {
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
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
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
