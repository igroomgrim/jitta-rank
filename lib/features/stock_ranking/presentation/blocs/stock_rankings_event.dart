import 'package:equatable/equatable.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

/// Every event carries the filter it applies to, so a handler never has to
/// guess at the current market/sectors.
///
/// searchFieldValue was previously declared on each subclass but left out of
/// props, meaning two events differing only by search term compared equal.
abstract class StockRankingsEvent extends Equatable {
  const StockRankingsEvent({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = '',
  });

  final String market;
  final List<String> sectors;
  final String searchFieldValue;

  @override
  List<Object?> get props => [market, sectors, searchFieldValue];
}

class GetStockRankingsEvent extends StockRankingsEvent {
  const GetStockRankingsEvent({
    super.market,
    super.sectors,
    super.searchFieldValue,
    this.limit = ApiConstants.defaultLimit,
    this.page = ApiConstants.defaultPage,
  });

  final int limit;
  final int page;

  @override
  List<Object?> get props => [...super.props, limit, page];
}

class LoadMoreStockRankingsEvent extends StockRankingsEvent {
  const LoadMoreStockRankingsEvent({
    super.market,
    super.sectors,
    super.searchFieldValue,
    this.page = ApiConstants.defaultPage,
  });

  final int page;

  @override
  List<Object?> get props => [...super.props, page];
}

class PullToRefreshStockRankingsEvent extends StockRankingsEvent {
  const PullToRefreshStockRankingsEvent({
    super.market,
    super.sectors,
    super.searchFieldValue,
  });
}

class FilterStockRankingsEvent extends StockRankingsEvent {
  const FilterStockRankingsEvent({
    super.market,
    super.sectors,
    super.searchFieldValue,
  });
}
