import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';

/// Exercises the cache against a real Hive box on a temp directory rather than
/// a mock, since the bug being fixed here was that the datasource ignored the
/// parameters it declared.
void main() {
  late Directory tempDir;
  late Box<RankedStockModel> box;
  late StockRankingLocalDatasourceImpl datasource;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('jitta_local_ds_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive
        ..registerAdapter(RankedStockModelAdapter())
        ..registerAdapter(SectorModelAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<RankedStockModel>('test_ranked_stocks');
    await box.clear();
    datasource = StockRankingLocalDatasourceImpl(box: box);
  });

  tearDown(() => box.close());

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  /// [noRank] models a row cached before the rank field existed. A plain
  /// `rank: null` would be indistinguishable from "not specified" here.
  RankedStockModel stock({
    required int index,
    String market = 'TH',
    String sectorId = 'ENERGY',
    int? rank,
    bool noRank = false,
  }) {
    final effectiveRank = noRank ? null : (rank ?? index);
    final base = MockStockRankingData.getMockRankedStockModel(
      index: index,
      rank: effectiveRank,
    );
    return RankedStockModel(
      id: base.id,
      stockId: base.stockId,
      symbol: base.symbol,
      title: base.title,
      jittaScore: base.jittaScore,
      currency: base.currency,
      latestPrice: base.latestPrice,
      industry: base.industry,
      sector: SectorModel(id: sectorId, name: sectorId),
      market: market,
      updatedAt: base.updatedAt,
      rank: effectiveRank,
    );
  }

  group('getStockRankings paging', () {
    setUp(() async {
      await box.addAll([for (var i = 0; i < 30; i++) stock(index: i, rank: i)]);
    });

    test('page 1 returns the first `limit` rows, not the whole box', () async {
      // The old implementation ignored limit and page and returned everything,
      // so offline scrolling appended the same rows over and over: 30, 60, 90.
      final page1 = await datasource.getStockRankings(limit: 20, market: 'TH');

      expect(page1, hasLength(20));
      expect(page1.first.rank, 0);
      expect(page1.last.rank, 19);
    });

    test('page 2 continues where page 1 stopped, with no overlap', () async {
      final page1 = await datasource.getStockRankings(limit: 20, market: 'TH');
      final page2 = await datasource.getStockRankings(
        limit: 20,
        market: 'TH',
        page: 2,
      );

      expect(page2, hasLength(10));
      expect(page2.first.rank, 20);

      final symbols = {...page1.map((s) => s.symbol)};
      expect(
        page2.every((s) => !symbols.contains(s.symbol)),
        isTrue,
        reason: 'pages must not overlap',
      );
    });

    test('a page past the end is empty rather than wrapping', () async {
      final page = await datasource.getStockRankings(
        limit: 20,
        market: 'TH',
        page: 5,
      );

      expect(page, isEmpty);
    });

    test('restores the API ordering regardless of insertion order', () async {
      await box.clear();
      await box.addAll([
        stock(index: 3, rank: 3),
        stock(index: 1, rank: 1),
        stock(index: 2, rank: 2),
      ]);

      final result = await datasource.getStockRankings(market: 'TH');

      expect(result.map((s) => s.rank), [1, 2, 3]);
    });

    test('rows cached before rank existed sort last, not first', () async {
      await box.clear();
      await box.addAll([
        stock(index: 9, noRank: true),
        stock(index: 1, rank: 1),
      ]);

      final result = await datasource.getStockRankings(market: 'TH');

      expect(result.first.rank, 1);
      expect(result.last.rank, isNull);
    });
  });

  group('getStockRankings filtering', () {
    test('filters by market before paging', () async {
      // rank is per-market: TH and US rows both start at 0, so mixing them
      // before sorting would interleave two separate rankings.
      await box.addAll([
        for (var i = 0; i < 5; i++) stock(index: i, rank: i),
        for (var i = 0; i < 5; i++)
          stock(index: 100 + i, market: 'US', rank: i),
      ]);

      final th = await datasource.getStockRankings(market: 'TH');
      final us = await datasource.getStockRankings(market: 'US');

      expect(th, hasLength(5));
      expect(us, hasLength(5));
      expect(th.every((s) => s.market == 'TH'), isTrue);
      expect(us.every((s) => s.market == 'US'), isTrue);
    });

    test('filters by sector when sectors are given', () async {
      await box.addAll([
        stock(index: 1, rank: 1),
        stock(index: 2, sectorId: 'FINANCIALS', rank: 2),
      ]);

      final result = await datasource.getStockRankings(
        market: 'TH',
        sectors: const ['FINANCIALS'],
      );

      expect(result, hasLength(1));
      expect(result.single.sector?.id, 'FINANCIALS');
    });
  });

  group('filterStockRankings', () {
    setUp(() async {
      await box.addAll([stock(index: 1, rank: 1), stock(index: 2, rank: 2)]);
    });

    test('matches on symbol, case-insensitively', () async {
      final result = await datasource.filterStockRankings(
        keyword: 'sym1',
        market: 'TH',
        sectors: const [],
      );

      expect(result, hasLength(1));
      expect(result.single.symbol, 'SYM1');
    });

    test('an empty keyword returns everything in the market', () async {
      final result = await datasource.filterStockRankings(
        keyword: '',
        market: 'TH',
        sectors: const [],
      );

      expect(result, hasLength(2));
    });

    test('a non-matching keyword returns empty, not everything', () async {
      final result = await datasource.filterStockRankings(
        keyword: 'nothing-matches-this',
        market: 'TH',
        sectors: const [],
      );

      expect(result, isEmpty);
    });
  });

  group('saveStockRankings', () {
    test('deduplicates on symbol instead of appending duplicates', () async {
      await datasource.saveStockRankings([stock(index: 1, rank: 1)]);
      await datasource.saveStockRankings([stock(index: 1, rank: 1)]);

      expect(box.values, hasLength(1));
    });

    test('caps the cache at maxStorageLimit', () async {
      await datasource.saveStockRankings([
        for (var i = 0; i < 60; i++) stock(index: i, rank: i),
      ]);

      expect(
        box.values,
        hasLength(StockRankingLocalDatasourceImpl.maxStorageLimit),
      );
    });

    test('an empty write leaves the cache untouched', () async {
      await datasource.saveStockRankings([stock(index: 1, rank: 1)]);
      await datasource.saveStockRankings([]);

      expect(box.values, hasLength(1));
    });

    test('reading a closed box surfaces as CacheException', () async {
      await box.close();

      expect(
        () => datasource.getStockRankings(market: 'TH'),
        throwsA(isA<CacheException>()),
      );

      box = await Hive.openBox<RankedStockModel>('test_ranked_stocks');
    });
  });
}
