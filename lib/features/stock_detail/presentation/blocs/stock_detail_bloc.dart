import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_detail/domain/usecases/get_stock_detail.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  final GetStockDetailUsecase getStockDetail;

  StockDetailBloc(this.getStockDetail) : super(StockDetailInitial()) {
    on<GetStockDetailEvent>((event, emit) async {
      emit(StockDetailLoading());
      try {
        final stock = await getStockDetail.call(event.stockId);
        emit(StockDetailLoaded(stock));
      } catch (e) {
        emit(StockDetailError(e.toString()));
      }
    });
  }
}
