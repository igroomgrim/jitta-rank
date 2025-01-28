import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/get_stock_rankings.dart';
import 'stock_rankings_event.dart';
import 'stock_rankings_state.dart';

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  final GetStockRankingsUsecase getStockRankings;

  StockRankingsBloc(this.getStockRankings) : super(StockRankingsInitial()) {
    on<GetStockRankingsEvent>((event, emit) async {
      emit(StockRankingsLoading());
      try {
        final rankedStocks = await getStockRankings.call(event.limit, event.market, event.page, event.sectors);
        emit(StockRankingsLoaded(rankedStocks));
      } catch (e) {
        emit(StockRankingsError(e.toString()));
      }
    });
  }
}
