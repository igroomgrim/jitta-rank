import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/queries/stock_ranking_queries.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';

class StockRankingGraphqlDatasource extends StockRankingDatasource {
  StockRankingGraphqlDatasource({required GraphqlService graphqlService})
      : _graphqlService = graphqlService;

  final GraphqlService _graphqlService;

  /// Throws [ServerException] when the request or the response is bad, and
  /// [SerializationException] when a well-formed response will not parse.
  /// Previously every path threw a bare `Exception(e.toString())`, so the
  /// repository could not tell a network failure from a parse failure and
  /// mapped everything to ServerFailure.
  @override
  Future<List<RankedStockModel>> getStockRankings({
    int limit = ApiConstants.defaultLimit,
    String market = ApiConstants.defaultMarket,
    int page = ApiConstants.defaultPage,
    List<String> sectors = ApiConstants.defaultSectors,
  }) async {
    final result = await _graphqlService.performQuery(stockByRankingQuery, {
      'limit': limit,
      'market': market,
      'page': page,
      'sectors': sectors,
    });

    if (result.hasException) {
      throw ServerException(
        result.exception?.graphqlErrors.firstOrNull?.message ??
            result.exception?.linkException?.toString() ??
            'Request to Jitta server failed',
      );
    }

    final ranking = result.data?['jittaRanking'];
    if (ranking is! Map<String, dynamic>) {
      throw const ServerException('No data returned from Jitta server');
    }

    final items = ranking['data'];
    if (items is! List) {
      throw const ServerException('No data returned from Jitta server');
    }

    try {
      // rank is the item's position in this market's ranking, taken from the
      // response order so the cache can restore it offline.
      final offset = (page - 1) * limit;
      final maps = items.whereType<Map<String, dynamic>>().toList();
      return [
        for (var i = 0; i < maps.length; i++)
          RankedStockModel.fromJson(maps[i], rank: offset + i),
      ];
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        SerializationException('Failed to parse ranked stocks: $e'),
        stackTrace,
      );
    }
  }
}
