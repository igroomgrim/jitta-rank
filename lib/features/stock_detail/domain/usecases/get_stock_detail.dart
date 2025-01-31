import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import '../repositories/stock_detail_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';

class GetStockDetailUsecase {
  final StockDetailRepository repository;

  GetStockDetailUsecase(this.repository);

  Future<Either<Failure, Stock>> call(int stockId) async {
    return await repository.getStockDetail(stockId);
  }
}
