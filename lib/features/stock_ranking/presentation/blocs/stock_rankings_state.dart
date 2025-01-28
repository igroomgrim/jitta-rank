import 'package:equatable/equatable.dart';
import '../../domain/entities/ranked_stock.dart';
abstract class StockRankingsState extends Equatable {
  @override
  List<Object> get props => [];
}

class StockRankingsInitial extends StockRankingsState {}

class StockRankingsLoading extends StockRankingsState {}

class StockRankingsLoaded extends StockRankingsState {
  final List<RankedStock> rankedStocks;
  final bool hasReachedMaxData;

  StockRankingsLoaded({
    this.rankedStocks = const [], 
    this.hasReachedMaxData = false
  });

  @override
  List<Object> get props => [rankedStocks, hasReachedMaxData];
}

class StockRankingsError extends StockRankingsState {
  final String message;

  StockRankingsError(this.message);

  @override
  List<Object> get props => [message];
}
