import 'package:equatable/equatable.dart';
import '../../domain/entities/ranked_stock.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

abstract class StockRankingsState extends Equatable {
  final String market;
  final List<String> sectors;
  final String searchFieldValue;
  const StockRankingsState({
    required this.market,
    required this.sectors,
    required this.searchFieldValue,
  });

  @override
  List<Object> get props => [market, sectors];
}

class StockRankingsInitial extends StockRankingsState {
  const StockRankingsInitial({
    super.market = ApiConstants.defaultMarket,
    super.sectors = const [],
    super.searchFieldValue = "",
  });
}

class StockRankingsLoading extends StockRankingsState {
  const StockRankingsLoading({
    required super.market,
    required super.sectors,
    required super.searchFieldValue,
  });
}

class StockRankingsLoaded extends StockRankingsState {
  final List<RankedStock> rankedStocks;
  final bool hasReachedMaxData;

  const StockRankingsLoaded({
    required super.market,
    required super.sectors,
    required super.searchFieldValue,
    required this.rankedStocks,
    required this.hasReachedMaxData,
  });

  @override
  List<Object> get props => [rankedStocks, hasReachedMaxData];
}

class StockRankingsError extends StockRankingsState {
  final String message;

  const StockRankingsError({
    required super.market,
    required super.sectors,
    required super.searchFieldValue,
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
