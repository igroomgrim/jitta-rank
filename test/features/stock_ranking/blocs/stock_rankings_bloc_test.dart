import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_repository.mocks.dart';
import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';
import 'package:jitta_rank/core/error/error.dart';

void main() {
  late StockRankingsBloc stockRankingsBloc;
  late MockStockRankingRepository mockStockRankingRepository;
  late GetStockRankingsUsecase getStockRankingsUsecase;
  late PullToRefreshStockRankingsUsecase pullToRefreshStockRankingsUsecase;
  late LoadMoreStockRankingsUsecase loadMoreStockRankingsUsecase;
  late SearchStockRankingsUsecase searchStockRankingsUsecase;

  setUp(() {
    mockStockRankingRepository = MockStockRankingRepository();
    getStockRankingsUsecase = GetStockRankingsUsecase(mockStockRankingRepository);
    pullToRefreshStockRankingsUsecase = PullToRefreshStockRankingsUsecase(mockStockRankingRepository);
    loadMoreStockRankingsUsecase = LoadMoreStockRankingsUsecase(mockStockRankingRepository);
    searchStockRankingsUsecase = SearchStockRankingsUsecase(mockStockRankingRepository);
    
    stockRankingsBloc = StockRankingsBloc(getStockRankingsUsecase, loadMoreStockRankingsUsecase, pullToRefreshStockRankingsUsecase, searchStockRankingsUsecase);
  });

  group('GetStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsLoading and StockRankingsLoaded when StockRankingsEvent is GetStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async =>
                Right(MockStockRankingData.getMockStockRankings()));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(GetStockRankingsEvent()),
      expect: () => [isA<StockRankingsLoading>(), isA<StockRankingsLoaded>()],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsError when StockRankingsEvent is GetStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async => Left(CustomFailure(message: 'Error')));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(GetStockRankingsEvent()),
      expect: () => [isA<StockRankingsLoading>(), isA<StockRankingsError>()],
    );
  });

  group('PullToRefreshStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsLoaded when StockRankingsEvent is PullToRefreshStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async =>
                Right(MockStockRankingData.getMockStockRankings()));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(PullToRefreshStockRankingsEvent()),
      expect: () => [isA<StockRankingsLoaded>()],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsError when StockRankingsEvent is PullToRefreshStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async => Left(CustomFailure(message: 'Error')));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(PullToRefreshStockRankingsEvent()),
      expect: () => [isA<StockRankingsError>()],
    );
  });

  group('FilterStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsLoaded when StockRankingsEvent is FilterStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async =>
                Right(MockStockRankingData.getMockStockRankings()));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(FilterStockRankingsEvent()),
      expect: () => [isA<StockRankingsLoading>(), isA<StockRankingsLoaded>()],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsError when StockRankingsEvent is FilterStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async => Left(CustomFailure(message: 'Error')));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(FilterStockRankingsEvent()),
      expect: () => [isA<StockRankingsLoading>(), isA<StockRankingsError>()],
    );
  });

  group('LoadMoreStockRankingsEvent', () {
    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsLoaded when StockRankingsEvent is LoadMoreStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async =>
                Right(MockStockRankingData.getMockStockRankingsWithLoadMore()));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(LoadMoreStockRankingsEvent()),
      expect: () => [isA<StockRankingsLoaded>()],
    );

    blocTest<StockRankingsBloc, StockRankingsState>(
      'should emit StockRankingsError when StockRankingsEvent is LoadMoreStockRankingsEvent',
      build: () {
        when(mockStockRankingRepository.getStockRankings(any, any, any, any))
            .thenAnswer((_) async => Left(CustomFailure(message: 'Error')));
        return stockRankingsBloc;
      },
      act: (bloc) => bloc.add(LoadMoreStockRankingsEvent()),
      expect: () => [isA<StockRankingsError>()],
    );
  });
}
