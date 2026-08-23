import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_detail/domain/usecases/get_stock_detail.dart';

import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  StockDetailBloc(this.getStockDetail) : super(const StockDetailState()) {
    on<GetStockDetailEvent>(_onGetStockDetail);
    on<RefreshStockDetailEvent>(_onRefreshStockDetail);
  }

  final GetStockDetailUsecase getStockDetail;

  Future<void> _onGetStockDetail(
    GetStockDetailEvent event,
    Emitter<StockDetailState> emit,
  ) async {
    emit(state.copyWith(status: StockDetailStatus.loading, clearError: true));
    await _fetch(event.stockId, emit);
  }

  /// Actually re-fetches. This previously emitted StockDetailInitial and
  /// nothing else — refresh only worked because the screen dispatched
  /// GetStockDetailEvent from build() whenever it saw the Initial state, so
  /// removing that side effect without fixing this would have silently killed
  /// pull-to-refresh.
  Future<void> _onRefreshStockDetail(
    RefreshStockDetailEvent event,
    Emitter<StockDetailState> emit,
  ) async {
    emit(
      state.copyWith(status: StockDetailStatus.refreshing, clearError: true),
    );
    await _fetch(event.stockId, emit);
  }

  Future<void> _fetch(int stockId, Emitter<StockDetailState> emit) async {
    final result = await getStockDetail.call(stockId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StockDetailStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stock) => emit(
        state.copyWith(
          status: StockDetailStatus.success,
          stock: stock,
          clearError: true,
        ),
      ),
    );
  }
}
