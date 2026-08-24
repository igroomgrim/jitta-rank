import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/queries/stock_detail_queries.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/queries/stock_ranking_queries.dart';

/// Parses every GraphQL document the app ships.
///
/// Nothing else does. Both datasources are mocked in every other test, so a
/// malformed query compiles, analyzes and passes the whole suite — it only
/// fails at runtime, against the real server.
///
/// This exists because of a specific bug: moving the queries into their own
/// files copied the escaped `\$stockId` out of a non-raw Dart string and into a
/// raw one, where the backslash survived. The server rejected it with
/// "Syntax Error ... query stockById(\$stockId: Int)". gql() catches that.
void main() {
  const documents = <String, String>{
    'stockByRankingQuery': stockByRankingQuery,
    'stockByIdQuery': stockByIdQuery,
  };

  group('every shipped GraphQL document parses', () {
    documents.forEach((name, document) {
      test(name, () {
        expect(() => gql(document), returnsNormally);
      });
    });
  });

  group('variables are real GraphQL variables, not Dart escapes', () {
    documents.forEach((name, document) {
      test(name, () {
        // A literal backslash before a $ means the query was written in a
        // non-raw string, or copied out of one.
        expect(
          document.contains(r'\$'),
          isFalse,
          reason:
              '$name contains an escaped dollar; use a raw string (r\'\'\')',
        );
      });
    });
  });

  test('stockByIdQuery declares and uses its stockId variable', () {
    expect(stockByIdQuery, contains(r'query stockById($stockId: Int)'));
    expect(stockByIdQuery, contains(r'stock(stockId: $stockId)'));
  });

  test('stockByRankingQuery declares and uses all four filter variables', () {
    for (final variable in [r'$market', r'$sectors', r'$page', r'$limit']) {
      expect(
        RegExp(RegExp.escape(variable)).allMatches(stockByRankingQuery).length,
        greaterThanOrEqualTo(2),
        reason: '$variable should be both declared and used',
      );
    }
  });
}
