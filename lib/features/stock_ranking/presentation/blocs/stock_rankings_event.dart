import 'package:equatable/equatable.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

abstract class StockRankingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetStockRankingsEvent extends StockRankingsEvent {
  GetStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.limit = ApiConstants.defaultLimit,
    this.page = ApiConstants.defaultPage,
    this.searchFieldValue = '',
  });
  final int limit;
  final String market;
  final int page;
  final List<String> sectors;
  final String searchFieldValue;

  @override
  List<Object> get props => [limit, market, page, sectors];
}

class LoadMoreStockRankingsEvent extends StockRankingsEvent {
  LoadMoreStockRankingsEvent({
    this.page = ApiConstants.defaultPage,
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = '',
  });
  final int page;
  final String market;
  final List<String> sectors;
  final String searchFieldValue;

  @override
  List<Object> get props => [page, market, sectors];
}

class PullToRefreshStockRankingsEvent extends StockRankingsEvent {
  PullToRefreshStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = '',
  });
  final String market;
  final List<String> sectors;
  final String searchFieldValue;

  @override
  List<Object> get props => [market, sectors];
}

class FilterStockRankingsEvent extends StockRankingsEvent {
  FilterStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = '',
  });
  final String market;
  final List<String> sectors;
  final String searchFieldValue;

  @override
  List<Object> get props => [market, sectors];
}
