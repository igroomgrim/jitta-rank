import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/core/networking/mock_network_info_service.mocks.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_graphql_datasource.mocks.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_local_datasource.mocks.dart';

void main() {
  late StockRankingRepository repository;
  late MockStockRankingGraphqlDatasource remote;
  late MockStockRankingLocalDatasource local;
  late MockNetworkInfoService network;

  setUp(() {
    remote = MockStockRankingGraphqlDatasource();
    local = MockStockRankingLocalDatasource();
    network = MockNetworkInfoService();
    repository = StockRankingRepositoryImpl(
      graphqlDatasource: remote,
      localDatasource: local,
      networkInfoService: network,
    );
  });

  void online({required bool value}) =>
      when(network.isConnected).thenAnswer((_) async => value);

  void stubRemote(List<RankedStockModel> models) {
    when(
      remote.getStockRankings(
        limit: anyNamed('limit'),
        market: anyNamed('market'),
        page: anyNamed('page'),
        sectors: anyNamed('sectors'),
      ),
    ).thenAnswer((_) async => models);
  }

  void stubRemoteThrows(Object error) {
    when(
      remote.getStockRankings(
        limit: anyNamed('limit'),
        market: anyNamed('market'),
        page: anyNamed('page'),
        sectors: anyNamed('sectors'),
      ),
    ).thenThrow(error);
  }

  void stubLocal(List<RankedStockModel> models) {
    when(
      local.getStockRankings(
        limit: anyNamed('limit'),
        market: anyNamed('market'),
        page: anyNamed('page'),
        sectors: anyNamed('sectors'),
      ),
    ).thenAnswer((_) async => models);
  }

  Failure failureOf(Either<Failure, Object?> either) =>
      either.fold((f) => f, (_) => fail('expected a Left'));

  group('online', () {
    test('returns entities from remote and caches them', () async {
      online(value: true);
      stubRemote(MockStockRankingData.getMockStockRankingModels(count: 2));
      when(local.saveStockRankings(any)).thenAnswer((_) async {});

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(result, isA<Right<Failure, List<RankedStock>>>());
      expect(result.getOrElse(() => const []), hasLength(2));
      verify(local.saveStockRankings(any)).called(1);
    });

    // The typed exceptions existed in core/error from the start and were never
    // thrown anywhere; the repository caught bare Exceptions and guessed.
    test('maps ServerException to ServerFailure', () async {
      online(value: true);
      stubRemoteThrows(const ServerException('upstream 500'));

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(failureOf(result), isA<ServerFailure>());
      expect(failureOf(result).message, 'upstream 500');
    });

    test('maps SerializationException to SerializationFailure', () async {
      online(value: true);
      stubRemoteThrows(const SerializationException('bad payload'));

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(failureOf(result), isA<SerializationFailure>());
    });

    test('maps a cache write failure to CacheFailure', () async {
      online(value: true);
      stubRemote(MockStockRankingData.getMockStockRankingModels());
      when(local.saveStockRankings(any))
          .thenThrow(const CacheException('full'));

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(failureOf(result), isA<CacheFailure>());
    });

    test('an unexpected throw still becomes a Failure, not a crash', () async {
      online(value: true);
      stubRemoteThrows(StateError('something nobody anticipated'));

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(result, isA<Left<Failure, List<RankedStock>>>());
    });
  });

  group('offline', () {
    test('returns cached entities', () async {
      online(value: false);
      stubLocal(MockStockRankingData.getMockStockRankingModels(count: 3));

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(result.getOrElse(() => const []), hasLength(3));
      verifyNever(
        remote.getStockRankings(
          limit: anyNamed('limit'),
          market: anyNamed('market'),
          page: anyNamed('page'),
          sectors: anyNamed('sectors'),
        ),
      );
    });

    test('an empty first page reports that nothing is cached', () async {
      online(value: false);
      stubLocal(const []);

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(failureOf(result), isA<CustomFailure>());
    });

    test('an empty later page is the end of the cache, not an error', () async {
      // Page 2 coming back empty just means the cache ran out. Treating it as
      // a failure would put a full-page error over an already-populated list.
      online(value: false);
      stubLocal(const []);

      final result = await repository.getStockRankings(20, 'TH', 2, const []);

      expect(result, isA<Right<Failure, List<RankedStock>>>());
      expect(result.getOrElse(() => const <RankedStock>[]), isEmpty);
    });

    test('maps CacheException to CacheFailure', () async {
      online(value: false);
      when(
        local.getStockRankings(
          limit: anyNamed('limit'),
          market: anyNamed('market'),
          page: anyNamed('page'),
          sectors: anyNamed('sectors'),
        ),
      ).thenThrow(const CacheException('corrupt box'));

      final result = await repository.getStockRankings(20, 'TH', 1, const []);

      expect(failureOf(result), isA<CacheFailure>());
    });

    test('passes limit/market/page/sectors through to the cache', () async {
      // The local datasource used to declare all four and use none of them.
      online(value: false);
      stubLocal(MockStockRankingData.getMockStockRankingModels());

      await repository.getStockRankings(20, 'US', 3, const ['ENERGY']);

      verify(
        local.getStockRankings(
          limit: 20,
          market: 'US',
          page: 3,
          sectors: const ['ENERGY'],
        ),
      ).called(1);
    });
  });

  group('filterStockRankings', () {
    test('offline, filters from the cache only', () async {
      online(value: false);
      when(
        local.filterStockRankings(
          keyword: anyNamed('keyword'),
          market: anyNamed('market'),
          sectors: anyNamed('sectors'),
        ),
      ).thenAnswer(
        (_) async => MockStockRankingData.getMockStockRankingModels(count: 1),
      );

      final result = await repository.filterStockRankings('ab', 'TH', const []);

      expect(result.getOrElse(() => const []), hasLength(1));
    });

    test('an empty filter result is success, not a failure', () async {
      online(value: false);
      when(
        local.filterStockRankings(
          keyword: anyNamed('keyword'),
          market: anyNamed('market'),
          sectors: anyNamed('sectors'),
        ),
      ).thenAnswer((_) async => const []);

      final result = await repository.filterStockRankings('zz', 'TH', const []);

      expect(result, isA<Right<Failure, List<RankedStock>>>());
    });
  });
}
