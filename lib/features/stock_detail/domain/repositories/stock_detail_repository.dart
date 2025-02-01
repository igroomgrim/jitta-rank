import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';

abstract class StockDetailRepository {
  Future<Either<Failure, Stock>> getStockDetail(int stockId);
}
