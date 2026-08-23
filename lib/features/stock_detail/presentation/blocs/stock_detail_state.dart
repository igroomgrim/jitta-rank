import 'package:equatable/equatable.dart';
import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

enum StockDetailStatus {
  initial,
  loading,

  /// Refreshing while a stock is already on screen.
  refreshing,
  success,
  failure,
}

/// One state rather than four subclasses, matching StockRankingsState.
///
/// Keeping [stock] across a refresh failure means a failed pull-to-refresh
/// leaves the previously loaded detail visible instead of blanking the screen.
class StockDetailState extends Equatable {
  const StockDetailState({
    this.status = StockDetailStatus.initial,
    this.stock,
    this.errorMessage,
  });

  final StockDetailStatus status;
  final Stock? stock;
  final String? errorMessage;

  bool get isLoading =>
      status == StockDetailStatus.initial ||
      status == StockDetailStatus.loading;

  bool get hasFailed => status == StockDetailStatus.failure;

  bool get hasFailedWithNoData => hasFailed && stock == null;

  StockDetailState copyWith({
    StockDetailStatus? status,
    Stock? stock,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StockDetailState(
      status: status ?? this.status,
      stock: stock ?? this.stock,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, stock, errorMessage];
}
