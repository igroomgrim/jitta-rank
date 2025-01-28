import 'package:equatable/equatable.dart';

abstract class StockDetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetStockDetailEvent extends StockDetailEvent {
  final int stockId;

  GetStockDetailEvent(this.stockId);

  @override
  List<Object> get props => [stockId];
}
