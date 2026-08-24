import 'package:equatable/equatable.dart';

class RankedStock extends Equatable {
  const RankedStock({
    required this.id,
    required this.stockId,
    required this.symbol,
    required this.title,
    required this.jittaScore,
    required this.currency,
    required this.latestPrice,
    required this.industry,
    required this.updatedAt,
    this.sector,
    this.market,
    this.rank,
  });

  final String id;
  final int stockId;
  final String symbol;
  final String title;
  final double jittaScore;
  final String currency;
  final double latestPrice;
  final String industry;
  final DateTime updatedAt;
  final Sector? sector;
  final String? market;

  /// Position in the ranking as returned by the API, used to restore the
  /// server's ordering when reading back from the local cache. Null for
  /// entries cached before this field existed.
  final int? rank;

  @override
  List<Object?> get props => [
        id,
        stockId,
        symbol,
        title,
        jittaScore,
        currency,
        latestPrice,
        industry,
        updatedAt,
        sector,
        market,
        rank,
      ];
}

class Sector extends Equatable {
  const Sector({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
