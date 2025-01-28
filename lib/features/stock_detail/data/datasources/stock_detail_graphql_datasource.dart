import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_datasource.dart';
import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';

class StockDetailGraphqlDatasource extends StockDetailDatasource {
  final GraphqlService graphqlService;

  StockDetailGraphqlDatasource(this.graphqlService);

  @override
  Future<StockModel> getStockDetail(int stockId) async {
    String stockByIdQuery = '''
    query stockById(\$stockId: Int) {
      stock(stockId: \$stockId) {
        id
        stockId
        currency_sign
        currency
        title
        symbol
        summary
        fundamental {
          eps
          market_cap
          shares
          dividend_per_share
          pe
          dividend
          beta
          yield
        }
      }
    }
  ''';

    try {
      final result = await graphqlService.performQuery(stockByIdQuery, {
        'stockId': stockId,
      });
      
      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.firstOrNull?.message);
      }

      final data = result.data;
      if (data == null) {
        throw Exception('No data returned from Jitta server');
      }

      final stock = data['stock'];
      if (stock == null) {
        throw Exception('No stock data returned from Jitta server');
      }
      
      final stockModel = StockModel.fromJson(stock);
      return stockModel;
    } catch (e) {
      throw Exception('Failed to fetch stock detail');
    }
  }
}
