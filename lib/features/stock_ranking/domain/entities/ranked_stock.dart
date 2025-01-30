class RankedStock {
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

  RankedStock({
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
  });
}

class Sector {
  final String id;
  final String name;

  Sector({
    required this.id,
    required this.name,
  });
}