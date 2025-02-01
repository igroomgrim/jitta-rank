import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/features/stock_detail/domain/usecases/get_stock_detail.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_repository.mocks.dart';
import '../../../mocks/features/stock_detail/mock_stock_detail_data.dart';
import 'package:jitta_rank/core/error/error.dart';

void main() {
  late GetStockDetailUsecase getStockDetailUsecase;
  late MockStockDetailRepository mockStockDetailRepository;

  setUp(() {
    mockStockDetailRepository = MockStockDetailRepository();
    getStockDetailUsecase = GetStockDetailUsecase(mockStockDetailRepository);
  });

  test('should return stock detail from repository', () async {
    when(mockStockDetailRepository.getStockDetail(any))
        .thenAnswer((_) async => Right(MockStockDetailData.getMockStock()));

    final result = await getStockDetailUsecase.call(1);

    expect(result, isA<Right>());
  });

  test('should return error when repository returns error', () async {
    when(mockStockDetailRepository.getStockDetail(any))
        .thenAnswer((_) async => Left(CustomFailure(message: 'Error')));

    final result = await getStockDetailUsecase.call(1);

    expect(result, isA<Left>());
  });
}
