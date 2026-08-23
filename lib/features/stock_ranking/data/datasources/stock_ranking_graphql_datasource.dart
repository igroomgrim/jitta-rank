import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';

class StockRankingGraphqlDatasource extends StockRankingDatasource {
  StockRankingGraphqlDatasource([GraphqlService? graphqlService])
      : _graphqlService = graphqlService ?? GraphqlService();
  final GraphqlService _graphqlService;

  @override
  Future<List<RankedStockModel>> getStockRankings({
    int limit = ApiConstants.defaultLimit,
    String market = ApiConstants.defaultMarket,
    int page = ApiConstants.defaultPage,
    List<String> sectors = ApiConstants.defaultSectors,
  }) async {
    String stockByRankingQuery = '''
    query stockByRanking(\$market: String!, \$sectors: [String], \$page: Int, \$limit: Int) {
      jittaRanking(filter: { market: \$market, sectors: \$sectors, page: \$page, limit: \$limit }) {
        count
        data {
          id
          stockId
          symbol
          title
          jittaScore
          currency
          latestPrice
          industry
          sector {
            id
            name
          }
          market
        updatedAt
        }
      }
    }
  ''';

    try {
      final result = await _graphqlService.performQuery(stockByRankingQuery, {
        'limit': limit,
        'market': market,
        'page': page,
        'sectors': sectors,
      });

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.firstOrNull?.message);
      }

      final ranking = result.data?['jittaRanking'];
      if (ranking is! Map<String, dynamic>) {
        throw Exception('No data returned from Jitta server');
      }

      final items = ranking['data'];
      if (items is! List) {
        throw Exception('No data returned from Jitta server');
      }

      try {
        final offset = (page - 1) * limit;
        return items
            .whereType<Map<String, dynamic>>()
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => RankedStockModel.fromJson(
                entry.value,
                rank: offset + entry.key,
              ),
            )
            .toList();
      } catch (e) {
        throw Exception('Failed to parse ranked stocks');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
