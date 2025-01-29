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

class RefreshStockRankingsEvent extends StockRankingsEvent {
  final String market;
  final List<String> sectors;

  RefreshStockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
  });

  @override
  List<Object> get props => [market, sectors];
}

class SearchStockRankingsEvent extends StockRankingsEvent {
  final String query;

  SearchStockRankingsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearLoadedStockRankingsEvent extends StockRankingsEvent {}
