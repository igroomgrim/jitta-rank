import '../entities/ranked_stock.dart';
import 'package:dartz/dartz.dart';
import 'package:jitta_rank/core/error/error.dart';

abstract class StockRankingRepository {
  Future<Either<Failure, List<RankedStock>>> getStockRankings(
      int limit, String market, int page, List<String> sectors);
  Future<Either<Failure, List<RankedStock>>> searchStockRankings(
      String keyword, String market, List<String> sectors);
  Future<Either<Failure, List<RankedStock>>> filterStockRankings(
      String keyword, String market, List<String> sectors);
}
