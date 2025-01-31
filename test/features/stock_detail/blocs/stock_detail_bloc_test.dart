import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_repository.mocks.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_data.dart';
import 'package:jitta_rank/core/error/error.dart';
import 'package:dartz/dartz.dart';

void main() {
  late StockDetailBloc stockDetailBloc;
  late MockStockDetailRepository mockStockDetailRepository;

  setUp(() {
    mockStockDetailRepository = MockStockDetailRepository();
    stockDetailBloc = StockDetailBloc(GetStockDetailUsecase(mockStockDetailRepository));
  });

  blocTest<StockDetailBloc, StockDetailState>(
    'should emit StockDetailLoading and StockDetailLoaded when StockDetailEvent is GetStockDetailEvent',
    build: () {
      when(mockStockDetailRepository.getStockDetail(any)).thenAnswer((_) async => Right(MockStockDetailData.getMockStock()));
      return stockDetailBloc;
    },
    act: (bloc) => bloc.add(GetStockDetailEvent(1)),
    expect: () => [isA<StockDetailLoading>(), isA<StockDetailLoaded>()],
  );

  blocTest<StockDetailBloc, StockDetailState>(
    'should emit StockDetailInitial when StockDetailEvent is RefreshStockDetailEvent',
    build: () {
      return stockDetailBloc;
    },
    act: (bloc) => bloc.add(RefreshStockDetailEvent(1)),
    expect: () => [isA<StockDetailInitial>()],
  );

  blocTest<StockDetailBloc, StockDetailState>(
    'should emit StockDetailError when StockDetailEvent is GetStockDetailEvent',
    build: () {
      when(mockStockDetailRepository.getStockDetail(any)).thenAnswer((_) async => Left(CustomFailure(message: 'Error')));
      return stockDetailBloc;
    },
    act: (bloc) => bloc.add(GetStockDetailEvent(1)),
    expect: () => [isA<StockDetailLoading>(),isA<StockDetailError>()],
  );
}


