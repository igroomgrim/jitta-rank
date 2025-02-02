import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';

class StockRankingRepositoryImpl extends StockRankingRepository {
  final StockRankingGraphqlDatasource _graphqlDatasource;
  final StockRankingLocalDatasource _localDatasource;
  final NetworkInfoService _networkInfoService;

  StockRankingRepositoryImpl({
    StockRankingGraphqlDatasource? graphqlDatasource,
    StockRankingLocalDatasource? localDatasource,
    NetworkInfoService? networkInfoService,
  })  : _graphqlDatasource =
            graphqlDatasource ?? StockRankingGraphqlDatasource(),
        _localDatasource = localDatasource ?? StockRankingLocalDatasourceImpl(),
        _networkInfoService = networkInfoService ?? NetworkInfoServiceImpl();

  @override
  Future<Either<Failure, List<RankedStock>>> getStockRankings(
      int limit, String market, int page, List<String> sectors) async {
    if (await _networkInfoService.isConnected) {
      // ONLINE
      try {
        final rankedStocks = await _graphqlDatasource.getStockRankings(
            limit: limit, market: market, page: page, sectors: sectors);
        try {
          await _localDatasource.saveStockRankings(rankedStocks);
        } catch (e) {
          return left(CacheFailure(
              'Failed to save stock rankings to local datasource'));
        }

        return right(rankedStocks);
      } catch (e) {
        return left(ServerFailure(
            'Failed to fetch stock rankings from remote datasource'));
      }
    } else {
      // OFFLINE
      try {
        final rankedStocksFromLocal = await _localDatasource.getStockRankings(
            market: market, sectors: sectors);

        if (rankedStocksFromLocal.isEmpty) {
          // OFFLINE + NO DATA
          return left(CustomFailure(
              message:
                  'You are offline, and we couldn’t find any stock rankings data. Please check your connection!'));
        }

        return right(rankedStocksFromLocal);
      } catch (e) {
        return left(CacheFailure(
            'Failed to fetch stock rankings from local datasource'));
      }
    }
  }

  @override
  Future<Either<Failure, List<RankedStock>>> filterStockRankings(
      String keyword, String market, List<String> sectors) async {
    if (await _networkInfoService.isConnected) {
      // ONLINE
      try {
        final rankedStocks = await _graphqlDatasource.getStockRankings(
            market: market, sectors: sectors);
        try {
          await _localDatasource.saveStockRankings(rankedStocks);
        } catch (e) {
          return left(CacheFailure(
              'Failed to save stock rankings to local datasource'));
        }

        if (keyword.isEmpty) {
          final filteredStocksByMarket = _filterByMarket(rankedStocks, market);
          final filteredStocksBySectors =
              _filterBySectors(filteredStocksByMarket, sectors);
          return right(filteredStocksBySectors);
        } else {
          final filteredStocksByKeyword =
              _filterByKeyword(rankedStocks, keyword);
          final filteredStocksByMarket =
              _filterByMarket(filteredStocksByKeyword, market);
          final filteredStocksBySectors =
              _filterBySectors(filteredStocksByMarket, sectors);
          return right(filteredStocksBySectors);
        }
      } catch (e) {
        return left(ServerFailure(
            'Failed to fetch stock rankings from remote datasource'));
      }
    } else {
      // OFFLINE
      try {
        final rankedStocksFromLocal = await _localDatasource.getStockRankings();

        if (rankedStocksFromLocal.isEmpty) {
          // OFFLINE + NO DATA
          return left(CustomFailure(
              message:
                  'You are offline, and we couldn’t find any stock rankings data. Please check your connection!'));
        }

        if (keyword.isEmpty) {
          final filteredStocksByMarket =
              _filterByMarket(rankedStocksFromLocal, market);
          final filteredStocksBySectors =
              _filterBySectors(filteredStocksByMarket, sectors);
          return right(filteredStocksBySectors);
        } else {
          final filteredStocksByKeyword =
              _filterByKeyword(rankedStocksFromLocal, keyword);
          final filteredStocksByMarket =
              _filterByMarket(filteredStocksByKeyword, market);
          final filteredStocksBySectors =
              _filterBySectors(filteredStocksByMarket, sectors);
          return right(filteredStocksBySectors);
        }
      } catch (e) {
        return left(CacheFailure(
            'Failed to fetch stock rankings from local datasource'));
      }
    }
  }

  // UTILITY FILTER FUNCTIONS
  List<RankedStockModel> _filterByKeyword(
      List<RankedStockModel> rankedStocks, String keyword) {
    return rankedStocks
        .where((stock) =>
            stock.symbol.toLowerCase().contains(keyword.toLowerCase()) ||
            stock.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  List<RankedStockModel> _filterByMarket(
      List<RankedStockModel> rankedStocks, String market) {
    return rankedStocks.where((stock) => stock.market == market).toList();
  }

  List<RankedStockModel> _filterBySectors(
      List<RankedStockModel> rankedStocks, List<String> sectors) {
    if (sectors.isEmpty) return rankedStocks;
    return rankedStocks
        .where((stock) => sectors.contains(stock.sector?.id ?? ''))
        .toList();
  }
}
