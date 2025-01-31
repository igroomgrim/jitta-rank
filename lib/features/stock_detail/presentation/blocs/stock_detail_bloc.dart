import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_detail/domain/usecases/get_stock_detail.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  final GetStockDetailUsecase getStockDetail;

  StockDetailBloc(this.getStockDetail) : super(StockDetailInitial()) {
    on<GetStockDetailEvent>(_onGetStockDetail);
    on<RefreshStockDetailEvent>(_onRefreshStockDetail);
  }

  void _onGetStockDetail(GetStockDetailEvent event, Emitter<StockDetailState> emit) async {
    emit(StockDetailLoading());
    final result = await getStockDetail.call(event.stockId);
    result.fold(
      (failure) => emit(StockDetailError(failure.message)),
      (stock) => emit(StockDetailLoaded(stock))
    );
  }

  void _onRefreshStockDetail(RefreshStockDetailEvent event, Emitter<StockDetailState> emit) async {
    emit(StockDetailInitial());
  }
}
