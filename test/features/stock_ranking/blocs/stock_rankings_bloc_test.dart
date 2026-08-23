import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_repository.mocks.dart';

void main() {
  late StockRankingsBloc bloc;
  late MockStockRankingRepository repository;

  setUp(() {
    repository = MockStockRankingRepository();
    bloc = StockRankingsBloc(
      getStockRankings: GetStockRankingsUsecase(repository),
      loadMoreStockRankings: LoadMoreStockRankingsUsecase(repository),
      pullToRefreshStockRankings: PullToRefreshStockRankingsUsecase(repository),
      filterStockRankings: FilterStockRankingsUsecase(repository),
    );
  });

  tearDown(() => bloc.close());

  void stubGet(List<RankedStock> stocks) {
    when(
      repository.getStockRankings(any, any, any, any),
    ).thenAnswer((_) async => Right<Failure, List<RankedStock>>(stocks));
  }

  void stubGetFailure() {
    when(repository.getStockRankings(any, any, any, any)).thenAnswer(
      (_) async => const Left<Failure, List<RankedStock>>(
        CustomFailure(message: 'Boom'),
      ),
    );
  }

  group('GetStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'goes loading then success, carrying the event filter throughout',
      build: () {
        stubGet(MockStockRankingData.getMockStockRankings(count: 3));
        return bloc;
      },
      act: (bloc) => bloc
          .add(const GetStockRankingsEvent(market: 'US', sectors: ['TECH'])),
      expect: () => [
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.loading)
            // The loading state used to be emitted with a DEFAULT filter,
            // making the app bar flash "Thailand" mid-load after a switch.
            .having((s) => s.filter.market, 'filter.market', 'US'),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.success)
            .having((s) => s.rankedStocks, 'rankedStocks', hasLength(3))
            .having((s) => s.filter.market, 'filter.market', 'US')
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'a first-load failure has no data, so the screen may show a full error',
      build: () {
        stubGetFailure();
        return bloc;
      },
      act: (bloc) => bloc.add(const GetStockRankingsEvent()),
      expect: () => [
        isA<StockRankingsState>().having(
          (s) => s.status,
          'status',
          StockRankingsStatus.loading,
        ),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Boom')
            .having(
              (s) => s.hasFailedWithNoData,
              'hasFailedWithNoData',
              isTrue,
            ),
      ],
    );
  });

  group('LoadMoreStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'appends the new page to what is already loaded',
      build: () {
        stubGet(MockStockRankingData.getMockStockRankings(count: 20, from: 21));
        return bloc;
      },
      seed: () => StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 20),
      ),
      act: (bloc) => bloc.add(const LoadMoreStockRankingsEvent(page: 2)),
      expect: () => [
        isA<StockRankingsState>().having(
          (s) => s.status,
          'status',
          StockRankingsStatus.loadingMore,
        ),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.success)
            .having((s) => s.rankedStocks, 'rankedStocks', hasLength(40)),
      ],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'an empty page ends pagination instead of looping forever',
      // Regression test. The handler used to guard its whole emit with
      // `if (stocks.isNotEmpty)`, so an empty page emitted nothing,
      // hasReachedMaxData stayed false, the trailing spinner never went away
      // and the list re-requested the same empty page indefinitely.
      build: () {
        stubGet(const []);
        return bloc;
      },
      seed: () => StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 20),
      ),
      act: (bloc) => bloc.add(const LoadMoreStockRankingsEvent(page: 2)),
      expect: () => [
        isA<StockRankingsState>().having(
          (s) => s.status,
          'status',
          StockRankingsStatus.loadingMore,
        ),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.success)
            .having((s) => s.hasReachedMaxData, 'hasReachedMaxData', isTrue)
            .having((s) => s.rankedStocks, 'rankedStocks', hasLength(20)),
      ],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'a failure keeps the already-loaded list on screen',
      // Regression test. A network blip mid-scroll used to emit an error state
      // carrying no stocks, replacing the whole list with a full-page error.
      build: () {
        stubGetFailure();
        return bloc;
      },
      seed: () => StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 20),
      ),
      act: (bloc) => bloc.add(const LoadMoreStockRankingsEvent(page: 2)),
      expect: () => [
        isA<StockRankingsState>().having(
          (s) => s.status,
          'status',
          StockRankingsStatus.loadingMore,
        ),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.failure)
            .having((s) => s.rankedStocks, 'rankedStocks', hasLength(20))
            .having(
              (s) => s.hasFailedWithNoData,
              'hasFailedWithNoData',
              isFalse,
            ),
      ],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'is a no-op once the end of the data has been reached',
      build: () {
        stubGet(MockStockRankingData.getMockStockRankings());
        return bloc;
      },
      seed: () => const StockRankingsState(
        status: StockRankingsStatus.success,
        hasReachedMaxData: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreStockRankingsEvent(page: 2)),
      expect: () => <StockRankingsState>[],
      verify: (_) => verifyNever(
        repository.getStockRankings(any, any, any, any),
      ),
    );
  });

  group('PullToRefreshStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'replaces the list rather than appending',
      build: () {
        stubGet(MockStockRankingData.getMockStockRankings(count: 2, from: 90));
        return bloc;
      },
      seed: () => StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 20),
      ),
      act: (bloc) => bloc.add(const PullToRefreshStockRankingsEvent()),
      expect: () => [
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.success)
            .having((s) => s.rankedStocks, 'rankedStocks', hasLength(2)),
      ],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'a failure keeps the existing list',
      build: () {
        stubGetFailure();
        return bloc;
      },
      seed: () => StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 5),
      ),
      act: (bloc) => bloc.add(const PullToRefreshStockRankingsEvent()),
      expect: () => [
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.failure)
            .having((s) => s.rankedStocks, 'rankedStocks', hasLength(5)),
      ],
    );
  });

  group('FilterStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'goes loading then success and records the new filter',
      build: () {
        when(repository.filterStockRankings(any, any, any)).thenAnswer(
          (_) async => Right<Failure, List<RankedStock>>(
            MockStockRankingData.getMockStockRankings(count: 2),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        const FilterStockRankingsEvent(
          market: 'SG',
          sectors: ['ENERGY'],
          searchFieldValue: 'abc',
        ),
      ),
      expect: () => [
        isA<StockRankingsState>().having(
          (s) => s.status,
          'status',
          StockRankingsStatus.loading,
        ),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.success)
            .having((s) => s.filter.market, 'filter.market', 'SG')
            .having(
          (s) => s.filter.sectors,
          'filter.sectors',
          ['ENERGY'],
        ).having(
          (s) => s.filter.searchFieldValue,
          'filter.searchFieldValue',
          'abc',
        ),
      ],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'a failure reports the message',
      build: () {
        when(repository.filterStockRankings(any, any, any)).thenAnswer(
          (_) async => const Left<Failure, List<RankedStock>>(
            CustomFailure(message: 'Boom'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const FilterStockRankingsEvent()),
      expect: () => [
        isA<StockRankingsState>().having(
          (s) => s.status,
          'status',
          StockRankingsStatus.loading,
        ),
        isA<StockRankingsState>()
            .having((s) => s.status, 'status', StockRankingsStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Boom'),
      ],
    );
  });
}
