import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_detail/data/datasources/stock_detail_local_datasource.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import 'package:jitta_rank/features/stock_detail/domain/repositories/stock_detail_repository.dart';

class StockDetailRepositoryImpl extends StockDetailRepository {
  StockDetailRepositoryImpl(
    this.graphqlDatasource,
    this.localDatasource,
    this.networkInfoService,
  );
  final StockDetailGraphqlDatasource graphqlDatasource;
  final StockDetailLocalDatasource localDatasource;
  final NetworkInfoService networkInfoService;

  @override
  Future<Either<Failure, Stock>> getStockDetail(int stockId) async {
    if (await networkInfoService.isConnected) {
      // ONLINE
      try {
        final stockDetail = await graphqlDatasource.getStockDetail(stockId);
        try {
          await localDatasource.saveStockDetail(stockDetail);
        } catch (e) {
          return left(
            const CacheFailure(
              'Failed to save stock detail to local datasource',
            ),
          );
        }

        return right(stockDetail.toEntity());
      } catch (e) {
        return left(
          const ServerFailure(
            'Failed to fetch stock detail from remote datasource',
          ),
        );
      }
    } else {
      // OFFLINE
      try {
        final stockDetailFromLocal =
            await localDatasource.getStockDetail(stockId);
        return right(stockDetailFromLocal.toEntity());
      } catch (e) {
        return left(
          const CustomFailure(
            message:
                'You are offline, and we couldn’t find any stock detail data. Please check your connection!',
          ),
        );
      }
    }
  }
}
