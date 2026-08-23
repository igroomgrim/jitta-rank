import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/queries/stock_detail_queries.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_datasource.dart';
import 'package:jitta_rank/features/stock_detail/data/models/stock_model.dart';

class StockDetailGraphqlDatasource extends StockDetailDatasource {
  StockDetailGraphqlDatasource(this.graphqlService);

  final GraphqlService graphqlService;

  /// Throws [ServerException] for a failed or empty response and
  /// [SerializationException] when the payload will not parse. The previous
  /// version caught everything and rethrew a bare
  /// `Exception('Failed to fetch stock detail')`, discarding the cause.
  @override
  Future<StockModel> getStockDetail(int stockId) async {
    final result = await graphqlService.performQuery(stockByIdQuery, {
      'stockId': stockId,
    });

    if (result.hasException) {
      throw ServerException(
        result.exception?.graphqlErrors.firstOrNull?.message ??
            result.exception?.linkException?.toString() ??
            'Request to Jitta server failed',
      );
    }

    final stock = result.data?['stock'];
    if (stock is! Map<String, dynamic>) {
      throw const ServerException('No stock data returned from Jitta server');
    }

    try {
      return StockModel.fromJson(stock);
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        SerializationException('Failed to parse stock detail: $e'),
        stackTrace,
      );
    }
  }
}
