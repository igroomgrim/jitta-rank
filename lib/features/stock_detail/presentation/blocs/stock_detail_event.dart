import 'package:equatable/equatable.dart';

abstract class StockDetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetStockDetailEvent extends StockDetailEvent {
  GetStockDetailEvent(this.stockId);
  final int stockId;

  @override
  List<Object> get props => [stockId];
}

class RefreshStockDetailEvent extends StockDetailEvent {
  RefreshStockDetailEvent(this.stockId);
  final int stockId;

  @override
  List<Object> get props => [stockId];
}
