import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';

/// Parses a real recorded API response from the Jitta staging endpoint.
void main() {
  late List<Map<String, dynamic>> items;

  setUpAll(() {
    final raw = File('test/fixtures/stocks_by_ranking.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final data = decoded['data']! as Map<String, dynamic>;
    final ranking = data['jittaRanking']! as Map<String, dynamic>;
    items = (ranking['data']! as List).cast<Map<String, dynamic>>();
  });

  group('RankedStockModel.fromJson on a real response', () {
    test('reads every field of the first item', () {
      final model = RankedStockModel.fromJson(items.first);

      expect(model.id, 'BKK:LST');
      expect(model.stockId, 439);
      expect(model.symbol, 'LST');
      expect(model.title, 'Lam Soon (Thailand)');
      expect(model.jittaScore, 5.3);
      expect(model.currency, '฿');
      expect(model.latestPrice, 4.9);
      expect(model.industry, 'Food Products');
      expect(model.sector?.id, 'CONSUMER_STAPLES');
      expect(model.sector?.name, 'Consumer staples');
      expect(model.updatedAt, DateTime.parse('2025-01-27T12:13:51.667Z'));
    });

    test('an int-valued jittaScore still parses as double', () {
      // jittaScore comes back as a bare int for whole-number scores.
      final model = RankedStockModel.fromJson({
        ...items.first,
        'jittaScore': 5,
        'latestPrice': 4,
      });

      expect(model.jittaScore, 5.0);
      expect(model.latestPrice, 4.0);
    });

    test('rank comes from the caller, not the payload', () {
      expect(RankedStockModel.fromJson(items.first).rank, isNull);
      expect(RankedStockModel.fromJson(items.first, rank: 27).rank, 27);
    });

    test('a missing market falls back rather than throwing', () {
      // This recorded response predates the market field being requested.
      expect(RankedStockModel.fromJson(items.first).market, 'Unknown');
    });

    test('a null sector is tolerated', () {
      final model = RankedStockModel.fromJson({...items.first, 'sector': null});

      expect(model.sector, isNull);
      expect(model.toEntity().sector, isNull);
    });

    test('a missing updatedAt falls back to now rather than throwing', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final model = RankedStockModel.fromJson({
        ...items.first,
        'updatedAt': null,
      });

      expect(model.updatedAt.isAfter(before), isTrue);
    });

    test('toEntity carries every value across the boundary', () {
      final model = RankedStockModel.fromJson(items.last, rank: 1);
      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.stockId, model.stockId);
      expect(entity.symbol, 'CWT');
      expect(entity.jittaScore, model.jittaScore);
      expect(entity.sector?.id, 'CONSUMER_DISCRETIONARY');
      expect(entity.rank, 1);
    });

    test('entities compare by value, not identity', () {
      final a = RankedStockModel.fromJson(items.first).toEntity();
      final b = RankedStockModel.fromJson(items.first).toEntity();

      expect(a, equals(b));
      expect([a], equals([b]));
    });
  });
}
