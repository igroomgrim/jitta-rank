import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_local_datasource.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import 'package:jitta_rank/features/stock_detail/domain/repositories/stock_detail_repository.dart';

class StockDetailRepositoryImpl extends StockDetailRepository {
  StockDetailRepositoryImpl({
    required this.graphqlDatasource,
    required this.localDatasource,
    required this.networkInfoService,
  });

  static const _offlineNoData =
      'You are offline, and we couldn’t find any stock detail data. '
      'Please check your connection!';

  final StockDetailGraphqlDatasource graphqlDatasource;
  final StockDetailLocalDatasource localDatasource;
  final NetworkInfoService networkInfoService;

  @override
  Future<Either<Failure, Stock>> getStockDetail(int stockId) async {
    if (await networkInfoService.isConnected) {
      return _fetchAndCache(stockId);
    }
    return _fromCache(stockId);
  }

  Future<Either<Failure, Stock>> _fetchAndCache(int stockId) async {
    final Stock stock;
    try {
      final model = await graphqlDatasource.getStockDetail(stockId);
      stock = model.toEntity();
      try {
        await localDatasource.saveStockDetail(model);
      } on CacheException catch (e) {
        return left(CacheFailure(e.message));
      }
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } on SerializationException catch (e) {
      return left(SerializationFailure(e.message));
    } on Object catch (e) {
      // Safety net: an unexpected throw must still surface as a Failure.
      return left(ServerFailure('Failed to fetch stock detail: $e'));
    }
    return right(stock);
  }

  Future<Either<Failure, Stock>> _fromCache(int stockId) async {
    try {
      final model = await localDatasource.getStockDetail(stockId);
      return right(model.toEntity());
    } on CacheException {
      return left(const CustomFailure(message: _offlineNoData));
    } on Object {
      return left(const CustomFailure(message: _offlineNoData));
    }
  }
}
