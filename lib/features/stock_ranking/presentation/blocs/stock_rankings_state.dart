import 'package:equatable/equatable.dart';
import '../../domain/entities/ranked_stock.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

class StockRankingsFilter {
  final String market;
  final List<String> sectors;
  final String searchFieldValue;

  const StockRankingsFilter({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = "",
  });
}

abstract class StockRankingsState extends Equatable {
  final StockRankingsFilter filter;

  const StockRankingsState({
    required this.filter,
  });

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
  final List<RankedStock> rankedStocks;
  final bool hasReachedMaxData;

  const StockRankingsLoaded({
    required super.filter,
    required this.rankedStocks,
    required this.hasReachedMaxData,
  });

  @override
  List<Object> get props => [...super.props, rankedStocks, hasReachedMaxData];
}

class StockRankingsError extends StockRankingsState {
  final String message;

  const StockRankingsError({
    required super.filter,
    required this.message,
  });

  @override
  List<Object> get props => [...super.props, message];
}
