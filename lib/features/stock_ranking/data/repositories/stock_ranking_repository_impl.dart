import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

/// Coordinates remote and cache. It does no filtering of its own — that moved
/// back into the local datasource, where the same three-step chain used to be
/// duplicated across four branches here.
class StockRankingRepositoryImpl extends StockRankingRepository {
  StockRankingRepositoryImpl({
    required StockRankingGraphqlDatasource graphqlDatasource,
    required StockRankingLocalDatasource localDatasource,
    required NetworkInfoService networkInfoService,
  })  : _graphqlDatasource = graphqlDatasource,
        _localDatasource = localDatasource,
        _networkInfoService = networkInfoService;

  static const _offlineNoData =
      'You are offline, and we couldn’t find any stock rankings data. '
      'Please check your connection!';

  final StockRankingGraphqlDatasource _graphqlDatasource;
  final StockRankingLocalDatasource _localDatasource;
  final NetworkInfoService _networkInfoService;

  @override
  Future<Either<Failure, List<RankedStock>>> getStockRankings(
    int limit,
    String market,
    int page,
    List<String> sectors,
  ) async {
    if (await _networkInfoService.isConnected) {
      return _fetchAndCache(
        () => _graphqlDatasource.getStockRankings(
          limit: limit,
          market: market,
          page: page,
          sectors: sectors,
        ),
      );
    }

    return _fromCache(
      () => _localDatasource.getStockRankings(
        limit: limit,
        market: market,
        page: page,
        sectors: sectors,
      ),
      // Only the first page can report "nothing cached". A later page coming
      // back empty just means the cache ended, which is not an error.
      emptyIsFailure: page == ApiConstants.defaultPage,
    );
  }

  @override
  Future<Either<Failure, List<RankedStock>>> filterStockRankings(
    String keyword,
    String market,
    List<String> sectors,
  ) async {
    if (await _networkInfoService.isConnected) {
      final fetched = await _fetchAndCache(
        () => _graphqlDatasource.getStockRankings(
          market: market,
          sectors: sectors,
        ),
      );
      // The API filters by market and sector but has no keyword search, so the
      // keyword is applied to what was just cached.
      return fetched.fold(
        Left.new,
        (_) => _filterFromCache(keyword, market, sectors),
      );
    }

    return _filterFromCache(keyword, market, sectors);
  }

  Future<Either<Failure, List<RankedStock>>> _fetchAndCache(
    Future<List<RankedStockModel>> Function() fetch,
  ) async {
    final List<RankedStockModel> stocks;
    try {
      stocks = await fetch();
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } on SerializationException catch (e) {
      return left(SerializationFailure(e.message));
    } on Object catch (e) {
      // Safety net: a datasource that throws something unexpected must still
      // surface as a Failure rather than escaping into the bloc.
      return left(ServerFailure('Failed to fetch stock rankings: $e'));
    }

    try {
      await _localDatasource.saveStockRankings(stocks);
    } on CacheException catch (e) {
      return left(CacheFailure(e.message));
    } on Object catch (e) {
      return left(CacheFailure('Failed to cache stock rankings: $e'));
    }

    return right(stocks.toEntities());
  }

  Future<Either<Failure, List<RankedStock>>> _fromCache(
    Future<List<RankedStockModel>> Function() read, {
    required bool emptyIsFailure,
  }) async {
    try {
      final stocks = await read();
      if (stocks.isEmpty && emptyIsFailure) {
        return left(const CustomFailure(message: _offlineNoData));
      }
      return right(stocks.toEntities());
    } on CacheException catch (e) {
      return left(CacheFailure(e.message));
    } on Object catch (e) {
      return left(CacheFailure('Failed to read cached stock rankings: $e'));
    }
  }

  Future<Either<Failure, List<RankedStock>>> _filterFromCache(
    String keyword,
    String market,
    List<String> sectors,
  ) =>
      _fromCache(
        () => _localDatasource.filterStockRankings(
          keyword: keyword,
          market: market,
          sectors: sectors,
        ),
        emptyIsFailure: false,
      );
}
