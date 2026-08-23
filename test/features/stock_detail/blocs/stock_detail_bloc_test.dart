import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/features/stock_detail/mock_stock_detail_data.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_repository.mocks.dart';

void main() {
  late StockDetailBloc bloc;
  late MockStockDetailRepository repository;
  late Stock stock;

  setUp(() {
    repository = MockStockDetailRepository();
    bloc = StockDetailBloc(GetStockDetailUsecase(repository));
    stock = MockStockDetailData.getMockStock();
  });

  tearDown(() => bloc.close());

  void stubSuccess() {
    when(
      repository.getStockDetail(any),
    ).thenAnswer((_) async => Right<Failure, Stock>(stock));
  }

  void stubFailure() {
    when(repository.getStockDetail(any)).thenAnswer(
      (_) async => const Left<Failure, Stock>(CustomFailure(message: 'Boom')),
    );
  }

  group('GetStockDetailEvent', () {
    blocTest<StockDetailBloc, StockDetailState>(
      'goes loading then success',
      build: () {
        stubSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetStockDetailEvent(1)),
      expect: () => [
        isA<StockDetailState>().having(
          (s) => s.status,
          'status',
          StockDetailStatus.loading,
        ),
        isA<StockDetailState>()
            .having((s) => s.status, 'status', StockDetailStatus.success)
            .having((s) => s.stock, 'stock', stock),
      ],
    );

    blocTest<StockDetailBloc, StockDetailState>(
      'a first-load failure has no stock, so the screen may show a full error',
      build: () {
        stubFailure();
        return bloc;
      },
      act: (bloc) => bloc.add(GetStockDetailEvent(1)),
      expect: () => [
        isA<StockDetailState>().having(
          (s) => s.status,
          'status',
          StockDetailStatus.loading,
        ),
        isA<StockDetailState>()
            .having((s) => s.status, 'status', StockDetailStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Boom')
            .having(
              (s) => s.hasFailedWithNoData,
              'hasFailedWithNoData',
              isTrue,
            ),
      ],
    );
  });

  group('RefreshStockDetailEvent', () {
    blocTest<StockDetailBloc, StockDetailState>(
      'actually re-fetches',
      // Regression test. The handler used to only emit StockDetailInitial and
      // never call the usecase — refresh worked solely because the screen
      // dispatched GetStockDetailEvent from build() on seeing Initial. With
      // the build-time side effect removed, this is the only thing keeping
      // pull-to-refresh alive.
      build: () {
        stubSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(RefreshStockDetailEvent(7)),
      expect: () => [
        isA<StockDetailState>().having(
          (s) => s.status,
          'status',
          StockDetailStatus.refreshing,
        ),
        isA<StockDetailState>()
            .having((s) => s.status, 'status', StockDetailStatus.success)
            .having((s) => s.stock, 'stock', stock),
      ],
      verify: (_) => verify(repository.getStockDetail(7)).called(1),
    );

    blocTest<StockDetailBloc, StockDetailState>(
      'a failed refresh keeps the stock already on screen',
      build: () {
        stubFailure();
        return bloc;
      },
      seed: () =>
          StockDetailState(status: StockDetailStatus.success, stock: stock),
      act: (bloc) => bloc.add(RefreshStockDetailEvent(1)),
      expect: () => [
        isA<StockDetailState>().having(
          (s) => s.status,
          'status',
          StockDetailStatus.refreshing,
        ),
        isA<StockDetailState>()
            .having((s) => s.status, 'status', StockDetailStatus.failure)
            .having((s) => s.stock, 'stock', stock)
            .having(
              (s) => s.hasFailedWithNoData,
              'hasFailedWithNoData',
              isFalse,
            ),
      ],
    );
  });
}
