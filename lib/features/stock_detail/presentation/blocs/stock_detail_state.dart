import 'package:equatable/equatable.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

abstract class StockDetailState extends Equatable {
  @override
  List<Object> get props => [];
}

class StockDetailInitial extends StockDetailState {}

class StockDetailLoading extends StockDetailState {}

class StockDetailLoaded extends StockDetailState {
  StockDetailLoaded(this.stock);
  final Stock stock;

  @override
  List<Object> get props => [stock];
}

class StockDetailError extends StockDetailState {
  StockDetailError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
