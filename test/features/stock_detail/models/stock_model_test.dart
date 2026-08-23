import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';

/// Parses a real recorded API response, captured from the Jitta staging
/// endpoint. These payloads are the only coverage fromJson has — every other
/// test in the suite mocks the datasource and constructs models directly.
void main() {
  late Map<String, dynamic> stockJson;

  setUpAll(() {
    final raw = File('test/fixtures/stock_by_id.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final data = decoded['data']! as Map<String, dynamic>;
    stockJson = data['stock']! as Map<String, dynamic>;
  });

  group('StockModel.fromJson on a real response', () {
    test('reads the top-level scalars', () {
      final model = StockModel.fromJson(stockJson);

      expect(model.stockId, 185);
      expect(model.symbol, 'CPALL');
      expect(model.name, 'CP ALL Public Company Limited');
      expect(model.currency, 'THB');
      expect(model.currencySign, '฿');
      expect(model.market, 'TH');
      expect(model.jittaRankScore, closeTo(10645.542953824122, 1e-9));
      expect(model.updatedAt, DateTime.parse('2025-01-27T12:30:08.703Z'));
    });

    test('flattens the nested price node', () {
      final model = StockModel.fromJson(stockJson);

      expect(model.price.close, 55.75);
      expect(
        model.price.latestPriceTimestamp,
        DateTime.parse('2025-01-27T00:00:00.000Z'),
      );
    });

    test('flattens jitta.score / priceDiff / factor.last.value', () {
      final jitta = StockModel.fromJson(stockJson).jitta;

      expect(jitta.total, 129);
      expect(jitta.score, closeTo(5.9352425930151185, 1e-9));
      expect(jitta.priceDiff, closeTo(-0.5400368468051762, 1e-9));
      expect(jitta.factor.growth.value, 62);
      expect(jitta.factor.growth.name, 'Growth Opportunity');
      expect(jitta.factor.growth.level, 'MEDIUM');
      expect(jitta.factor.financial.value, 58);
      expect(jitta.factor.management.value, 68);
      expect(jitta.factor.management.name, 'Competitive Advantage');
    });

    test('flattens loss_chance.last, sector.name and company.*', () {
      final model = StockModel.fromJson(stockJson);

      expect(model.lossChance, closeTo(0.4275705606928843, 1e-9));
      expect(model.sectorName, 'Consumer staples');
      expect(model.companyLink, 'www.cpall.co.th');
      expect(model.ipoDate, DateTime.parse('2003-10-15T00:00:00.000Z'));
    });

    test('reads the price graph, coercing a null linePrice to 0', () {
      final graph = StockModel.fromJson(stockJson).graphPrice;

      expect(graph.firstGraphPeriod, '2015-1');
      expect(graph.graphs, hasLength(4));
      expect(graph.graphs.first.stockPrice, 41.5);
      expect(graph.graphs.first.linePrice, 32.1);
      // The recorded response really does contain "linePrice": null here.
      expect(graph.graphs.last.stockPrice, 42);
      expect(graph.graphs.last.linePrice, 0.0);
    });

    test('toEntity carries every value across the boundary', () {
      final model = StockModel.fromJson(stockJson);
      final entity = model.toEntity();

      expect(entity.stockId, model.stockId);
      expect(entity.symbol, model.symbol);
      expect(entity.price.close, model.price.close);
      expect(entity.jitta.factor.growth.value, model.jitta.factor.growth.value);
      expect(entity.graphPrice.graphs.length, model.graphPrice.graphs.length);
      expect(entity.companyLink, model.companyLink);
    });
  });

  group('StockModel.fromJson degrades instead of throwing', () {
    test('an empty payload yields zero values, not an exception', () {
      final model = StockModel.fromJson(const {});

      expect(model.stockId, 0);
      expect(model.symbol, '');
      expect(model.price.close, 0.0);
      expect(model.jitta.total, 0);
      expect(model.jitta.factor.growth.value, 0);
      expect(model.lossChance, 0.0);
      expect(model.companyLink, '');
      expect(model.graphPrice.graphs, isEmpty);
      expect(model.ipoDate, isNull);
    });

    test('null intermediate nodes do not throw', () {
      // The previous json['a']['b'] chains threw NoSuchMethodError here.
      final model = StockModel.fromJson(const {
        'stockId': 1,
        'price': null,
        'jitta': null,
        'loss_chance': null,
        'sector': null,
        'company': null,
        'graph_price': null,
      });

      expect(model.stockId, 1);
      expect(model.price.close, 0.0);
      expect(model.jitta.priceDiff, 0.0);
      expect(model.sectorName, '');
      expect(model.graphPrice.firstGraphPeriod, '');
    });

    test('an empty company.link list does not throw', () {
      final model = StockModel.fromJson(const {
        'company': {'link': <Object>[]},
      });

      expect(model.companyLink, '');
    });
  });
}
