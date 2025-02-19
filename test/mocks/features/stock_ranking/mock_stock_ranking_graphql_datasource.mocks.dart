// Mocks generated by Mockito 5.4.5 from annotations
// in jitta_rank/test/mocks/features/stock_ranking/mock_stock_ranking_graphql_datasource.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:jitta_rank/core/networking/graphql_service.dart' as _i2;
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_graphql_datasource.dart'
    as _i3;
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart'
    as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeGraphqlService_0 extends _i1.SmartFake
    implements _i2.GraphqlService {
  _FakeGraphqlService_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [StockRankingGraphqlDatasource].
///
/// See the documentation for Mockito's code generation for more information.
class MockStockRankingGraphqlDatasource extends _i1.Mock
    implements _i3.StockRankingGraphqlDatasource {
  MockStockRankingGraphqlDatasource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.GraphqlService get graphqlService => (super.noSuchMethod(
        Invocation.getter(#graphqlService),
        returnValue: _FakeGraphqlService_0(
          this,
          Invocation.getter(#graphqlService),
        ),
      ) as _i2.GraphqlService);

  @override
  _i4.Future<List<_i5.RankedStockModel>> getStockRankings(
    int? limit,
    String? market,
    int? page,
    List<String>? sectors,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getStockRankings,
          [
            limit,
            market,
            page,
            sectors,
          ],
        ),
        returnValue: _i4.Future<List<_i5.RankedStockModel>>.value(
            <_i5.RankedStockModel>[]),
      ) as _i4.Future<List<_i5.RankedStockModel>>);
}
