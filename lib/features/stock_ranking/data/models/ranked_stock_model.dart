import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';

part 'ranked_stock_model.g.dart';

/// Persistence/transport representation of [RankedStock].
///
/// Deliberately does NOT extend the entity: the data layer owns its own shape
/// (Hive annotations, JSON parsing) and hands the domain a plain entity via
/// [toEntity]. Extending the entity meant every field was declared twice and
/// Hive persisted the subclass copy.
@HiveType(typeId: 0)
class RankedStockModel {
  const RankedStockModel({
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
    this.rank,
  });

  /// [rank] is the item's position in the API's ranking. It is not part of the
  /// payload — the caller supplies it from the response array index so the
  /// server's ordering can be restored when reading back from the cache.
  factory RankedStockModel.fromJson(Map<String, dynamic> json, {int? rank}) {
    final sectorJson = json['sector'];
    return RankedStockModel(
      id: json['id'] as String,
      stockId: json['stockId'] as int,
      symbol: json['symbol'] as String? ?? '',
      title: json['title'] as String? ?? '',
      jittaScore: (json['jittaScore'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      latestPrice: (json['latestPrice'] as num?)?.toDouble() ?? 0.0,
      industry: json['industry']?.toString() ?? 'Unknown',
      sector: sectorJson == null
          ? null
          : SectorModel.fromJson(sectorJson as Map<String, dynamic>),
      market: json['market']?.toString() ?? 'Unknown',
      updatedAt:
          parseDateString(json['updatedAt'] as String?) ?? DateTime.now(),
      rank: rank,
    );
  }

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
  final SectorModel? sector;
  @HiveField(9)
  final DateTime updatedAt;
  @HiveField(10)
  final String? market;

  /// Null for entries written before this field existed; such entries sort
  /// last rather than breaking the cache.
  @HiveField(11)
  final int? rank;

  RankedStock toEntity() => RankedStock(
        id: id,
        stockId: stockId,
        symbol: symbol,
        title: title,
        jittaScore: jittaScore,
        currency: currency,
        latestPrice: latestPrice,
        industry: industry,
        updatedAt: updatedAt,
        sector: sector?.toEntity(),
        market: market,
        rank: rank,
      );
}

@HiveType(typeId: 1)
class SectorModel {
  const SectorModel({required this.id, required this.name});

  factory SectorModel.fromJson(Map<String, dynamic> json) =>
      SectorModel(id: json['id'] as String, name: json['name'] as String);

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  Sector toEntity() => Sector(id: id, name: name);
}

/// Lenient date parsing: the API has been seen to return null and empty
/// strings for `updatedAt`.
DateTime? parseDateString(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateTime.parse(dateString);
  } catch (_) {
    return null;
  }
}

extension RankedStockModelListX on List<RankedStockModel> {
  List<RankedStock> toEntities() => map((m) => m.toEntity()).toList();
}
