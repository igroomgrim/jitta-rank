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
    this.limit = ApiConstants.defaultLoadLimit,
    this.page = ApiConstants.defaultLoadPage,
  });

  @override
  List<Object> get props => [limit, market, page, sectors];
}

class LoadMoreStockRankingsEvent extends StockRankingsEvent {
  final int page;
  final String market;
  final List<String> sectors;

  LoadMoreStockRankingsEvent({
    this.page = ApiConstants.defaultLoadPage,
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
  });

  @override
  List<Object> get props => [page, market, sectors];
}

class PullToRefreshStockRankingsEvent extends StockRankingsEvent {
  final String market;
  final List<String> sectors;

  PullToRefreshStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
  });

  @override
  List<Object> get props => [market, sectors];
}

class SearchStockRankingsEvent extends StockRankingsEvent {
  final String searchFieldValue;
  final String market;
  final List<String> sectors;

  SearchStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    required this.searchFieldValue,
  });

  @override
  List<Object> get props => [searchFieldValue, market, sectors];
}

class FilterStockRankingsEvent extends StockRankingsEvent {
  final String market;
  final List<String> sectors;

  FilterStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
  });

  @override
  List<Object> get props => [market, sectors];
}
