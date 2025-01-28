import 'package:equatable/equatable.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

abstract class StockRankingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetStockRankingsEvent extends StockRankingsEvent {
  final int limit;
  final String market;
  final int page;
  final List<String> sectors;

  GetStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.limit = 5, // TODO: make this dynamic or set to proper value
    this.page = 1,
  });
}