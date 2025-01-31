import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';
import 'package:jitta_rank/features/stock_ranking/domain/repositories/stock_ranking_repository.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_graphql_datasource.dart';
import 'package:jitta_rank/features/stock_ranking/data/datasources/stock_ranking_local_datasource.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  final StockRankingGraphqlDatasource graphqlDatasource;
  final StockRankingLocalDatasource localDatasource;
  final NetworkInfoService networkInfoService;

  StockRankingRepositoryImpl(this.graphqlDatasource, this.localDatasource, this.networkInfoService);

  @override
  Future<Either<Failure, List<RankedStock>>> getStockRankings(int limit, String market, int page, List<String> sectors) async {
    if (await networkInfoService.isConnected) { // ONLINE
      try {
        final rankedStocks = await graphqlDatasource.getStockRankings(limit, market, page, sectors);
        try {
          await localDatasource.saveStockRankings(rankedStocks);
        } catch (e) {
          print('StockRankingRepositoryImpl: OFFLINE - error: $e');
          return left(CacheFailure('Failed to save stock rankings to local datasource'));
        }

        return right(rankedStocks);        
      } catch (e) {
        print('StockRankingRepositoryImpl: ONLINE - error: $e');
        return left(ServerFailure('Failed to fetch stock rankings from remote datasource'));
      }

    } else { // OFFLINE
      try {
        final rankedStocksFromLocal = await localDatasource.getStockRankings(limit, market, page, sectors);

        if (rankedStocksFromLocal.isEmpty) { // OFFLINE + NO DATA
          return left(CustomFailure(message: 'You are offline, and we couldn’t find any stock rankings data. Please check your connection!'));
        }

        return right(rankedStocksFromLocal);
      } catch (e) {
        print('StockRankingRepositoryImpl: OFFLINE - error: $e');
        return left(CacheFailure('Failed to fetch stock rankings from local datasource'));
      }
    }
  }

  @override
  Future<Either<Failure, List<RankedStock>>> searchStockRankings(String keyword, String market, List<String> sectors) async {
    // Search stock rankings from local datasource - ONLY
    try {
      final rankedStocks = await localDatasource.searchStockRankings(keyword, market, sectors);
      return right(rankedStocks);
    } catch (e) {
      print('StockRankingRepositoryImpl: OFFLINE - error: $e');
      return left(CacheFailure('Failed to search stock rankings from local datasource'));
    }
  }
}

// TODO: Revise error massage and remove print statements