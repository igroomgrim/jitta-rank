import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/models/ranked_stock_model.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';

class StockRankingGraphqlDatasource extends StockRankingDatasource {
  final GraphqlService graphqlService;

  StockRankingGraphqlDatasource(this.graphqlService);

  @override
  Future<List<RankedStockModel>> getStockRankings(int limit, String market, int page, List<String> sectors) async {
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
        updatedAt
        }
      }
    }
  ''';

    try {
      final result = await graphqlService.performQuery(stockByRankingQuery, {
        'limit': limit,
        'market': market,
        'page': page,
        'sectors': sectors,
      });

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.firstOrNull?.message);
      }

      final data = result.data?['jittaRanking'];
      if (data == null) {
        throw Exception('No data returned from Jitta server');
      }
      
      try {
        final List<RankedStockModel> rankedStocks = data['data']
            .map<RankedStockModel>((json) => RankedStockModel.fromJson(json))
            .toList();
        return rankedStocks;
      } catch (e) {
        throw Exception('Failed to parse ranked stocks');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
