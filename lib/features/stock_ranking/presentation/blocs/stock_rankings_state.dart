import 'package:equatable/equatable.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

import '../../domain/entities/ranked_stock.dart';

class StockRankingsFilter {
  const StockRankingsFilter({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = '',
  });
  final String market;
  final List<String> sectors;
  final String searchFieldValue;
}

abstract class StockRankingsState extends Equatable {
  const StockRankingsState({
    required this.filter,
  });
  final StockRankingsFilter filter;

  @override
  List<Object> get props => [filter];
}

class StockRankingsInitial extends StockRankingsState {
  const StockRankingsInitial({
    super.filter = const StockRankingsFilter(),
  });
}

class StockRankingsLoading extends StockRankingsState {
  const StockRankingsLoading({
    required super.filter,
  });
}

class StockRankingsLoaded extends StockRankingsState {
  const StockRankingsLoaded({
    required super.filter,
    required this.rankedStocks,
    required this.hasReachedMaxData,
  });
  final List<RankedStock> rankedStocks;
  final bool hasReachedMaxData;

  @override
  List<Object> get props => [...super.props, rankedStocks, hasReachedMaxData];
}

class StockRankingsError extends StockRankingsState {
  const StockRankingsError({
    required super.filter,
    required this.message,
  });
  final String message;

  @override
  List<Object> get props => [...super.props, message];
}
