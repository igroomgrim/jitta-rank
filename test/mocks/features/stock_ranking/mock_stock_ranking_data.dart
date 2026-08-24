import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class MockStockRankingData {
  /// The model is the source of truth; the entity is derived from it so the
  /// two cannot drift apart.
  static RankedStockModel getMockRankedStockModel({int index = 1, int? rank}) {
    return RankedStockModel(
      id: '$index',
      stockId: index,
      symbol: 'SYM$index',
      title: 'Test Stock $index',
      jittaScore: 100,
      currency: 'Test Stock',
      latestPrice: 100,
      industry: 'Test Stock',
      updatedAt: DateTime.utc(2025),
      sector: const SectorModel(id: '1', name: 'Test Stock'),
      market: 'TH',
      rank: rank,
    );
  }

  static RankedStock getMockRankedStock({int index = 1, int? rank}) =>
      getMockRankedStockModel(index: index, rank: rank).toEntity();

  /// [count] entries with distinct symbols, so an append can be told apart
  /// from a replace.
  static List<RankedStock> getMockStockRankings({int count = 1, int from = 1}) {
    return List.generate(count, (i) => getMockRankedStock(index: from + i));
  }

  static List<RankedStockModel> getMockStockRankingModels({
    int count = 1,
    int from = 1,
  }) {
    return List.generate(
      count,
      (i) => getMockRankedStockModel(index: from + i, rank: from + i - 1),
    );
  }
}
