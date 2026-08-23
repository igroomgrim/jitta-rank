import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';

abstract class StockRankingLocalDatasource extends StockRankingDatasource {
  @override
  Future<List<RankedStockModel>> getStockRankings({
    int limit,
    String market,
    int page,
    List<String> sectors,
  });

  Future<List<RankedStockModel>> filterStockRankings({
    required String keyword,
    required String market,
    required List<String> sectors,
  });

  Future<void> saveStockRankings(List<RankedStockModel> stockRankings);
}

class StockRankingLocalDatasourceImpl extends StockRankingLocalDatasource {
  StockRankingLocalDatasourceImpl({required Box<RankedStockModel> box})
      : _box = box;

  /// Cached rows are capped so the box does not grow without bound.
  static const maxStorageLimit = 40;

  final Box<RankedStockModel> _box;

  /// Honours every parameter it declares.
  ///
  /// Previously this accepted limit/market/page/sectors and used none of them,
  /// returning the entire box. Offline that meant a page-2 request got the same
  /// rows back, which the bloc appended — the list grew 40, 80, 120 with
  /// duplicates as you scrolled.
  ///
  /// Filtering happens before paging, which matters: `rank` is the item's
  /// position within its own market's ranking, so TH and US rows both carry
  /// ranks 0..n and mixing them before sorting would interleave two rankings.
  @override
  Future<List<RankedStockModel>> getStockRankings({
    int limit = ApiConstants.defaultLimit,
    String market = ApiConstants.defaultMarket,
    int page = ApiConstants.defaultPage,
    List<String> sectors = ApiConstants.defaultSectors,
  }) async {
    try {
      final matching = _sortByRank(
        _filterBySectors(
          _filterByMarket(_box.values.toList(), market),
          sectors,
        ),
      );
      final offset = (page - 1) * limit;
      if (offset >= matching.length) return const [];
      return matching.skip(offset).take(limit).toList();
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        CacheException('Failed to read stock rankings from cache: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<List<RankedStockModel>> filterStockRankings({
    required String keyword,
    required String market,
    required List<String> sectors,
  }) async {
    try {
      var matching = _filterBySectors(
        _filterByMarket(_box.values.toList(), market),
        sectors,
      );
      if (keyword.isNotEmpty) {
        matching = _filterByKeyword(matching, keyword);
      }
      return _sortByRank(matching);
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        CacheException('Failed to filter stock rankings in cache: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> saveStockRankings(List<RankedStockModel> stockRankings) async {
    if (stockRankings.isEmpty) return;

    try {
      final incoming = stockRankings.map((s) => s.symbol).toSet();
      final retained = _box.values
          .where((stock) => !incoming.contains(stock.symbol))
          .toList();
      final all = [...retained, ...stockRankings];
      final toSave = all.length <= maxStorageLimit
          ? all
          : all.sublist(all.length - maxStorageLimit);

      // The full replacement list is built before the box is touched, so a
      // failure while assembling it cannot leave the cache empty.
      await _box.clear();
      await _box.addAll(toSave);
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        CacheException('Failed to write stock rankings to cache: $e'),
        stackTrace,
      );
    }
  }

  /// Restores the API's ordering. Entries cached before `rank` existed sort
  /// last rather than breaking the list.
  List<RankedStockModel> _sortByRank(List<RankedStockModel> stocks) {
    final sorted = [...stocks]..sort((a, b) {
        final ra = a.rank;
        final rb = b.rank;
        if (ra == null && rb == null) return 0;
        if (ra == null) return 1;
        if (rb == null) return -1;
        return ra.compareTo(rb);
      });
    return sorted;
  }

  List<RankedStockModel> _filterByMarket(
    List<RankedStockModel> stocks,
    String market,
  ) =>
      stocks.where((stock) => stock.market == market).toList();

  List<RankedStockModel> _filterBySectors(
    List<RankedStockModel> stocks,
    List<String> sectors,
  ) {
    if (sectors.isEmpty) return stocks;
    return stocks
        .where((stock) => sectors.contains(stock.sector?.id ?? ''))
        .toList();
  }

  List<RankedStockModel> _filterByKeyword(
    List<RankedStockModel> stocks,
    String keyword,
  ) {
    final needle = keyword.toLowerCase();
    return stocks
        .where(
          (stock) =>
              stock.symbol.toLowerCase().contains(needle) ||
              stock.title.toLowerCase().contains(needle),
        )
        .toList();
  }
}
