import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

EventTransformer<Event> throttleDroppable<Event>() {
  const throttleDuration = Duration(milliseconds: 100);
  return (events, mapper) {
    return droppable<Event>().call(events.throttle(throttleDuration), mapper);
  };
}

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  final GetStockRankingsUsecase getStockRankings;
  final LoadMoreStockRankingsUsecase loadMoreStockRankings;
  final PullToRefreshStockRankingsUsecase pullToRefreshStockRankings;
  final FilterStockRankingsUsecase filterStockRankings;

  StockRankingsBloc({
    required this.getStockRankings,
    required this.loadMoreStockRankings,
    required this.pullToRefreshStockRankings,
    required this.filterStockRankings,
  }) : super(StockRankingsInitial()) {
    on<GetStockRankingsEvent>(_onGetStockRankings);
    on<LoadMoreStockRankingsEvent>(_onLoadMoreStockRankings,
        transformer: throttleDroppable());
    on<PullToRefreshStockRankingsEvent>(_onPullToRefreshStockRankings);
    on<FilterStockRankingsEvent>(_onFilterStockRankings);
  }

  void _onGetStockRankings(
      GetStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    if (state is StockRankingsInitial) {
      emit(StockRankingsLoading(filter: StockRankingsFilter()));
    }

    final filter = StockRankingsFilter(
        market: event.market,
        sectors: event.sectors,
        searchFieldValue: event.searchFieldValue);
    final result = await getStockRankings.call(
        limit: event.limit,
        market: event.market,
        page: event.page,
        sectors: event.sectors);
    result.fold(
      (failure) =>
          emit(StockRankingsError(filter: filter, message: failure.message)),
      (stockRankingsResult) {
        emit(StockRankingsLoaded(
            filter: filter,
            rankedStocks: stockRankingsResult.rankedStocks,
            hasReachedMaxData: stockRankingsResult.hasReachedMaxData));
      },
    );
  }

  void _onLoadMoreStockRankings(LoadMoreStockRankingsEvent event,
      Emitter<StockRankingsState> emit) async {
    final filter = StockRankingsFilter(
        market: event.market,
        sectors: event.sectors,
        searchFieldValue: event.searchFieldValue);
    final result = await loadMoreStockRankings.call(
        event.market, event.page, event.sectors);
    result.fold(
      (failure) =>
          emit(StockRankingsError(filter: filter, message: failure.message)),
      (stockRankingsResult) {
        if (stockRankingsResult.rankedStocks.isNotEmpty) {
          if (state is StockRankingsLoaded) {
            emit(StockRankingsLoaded(
                filter: filter,
                rankedStocks: [
                  ...(state as StockRankingsLoaded).rankedStocks,
                  ...stockRankingsResult.rankedStocks
                ],
                hasReachedMaxData: stockRankingsResult.hasReachedMaxData));
          } else {
            emit(StockRankingsLoaded(
                filter: filter,
                rankedStocks: stockRankingsResult.rankedStocks,
                hasReachedMaxData: stockRankingsResult.hasReachedMaxData));
          }
        }
      },
    );
  }

  void _onPullToRefreshStockRankings(PullToRefreshStockRankingsEvent event,
      Emitter<StockRankingsState> emit) async {
    final filter = StockRankingsFilter(
        market: event.market,
        sectors: event.sectors,
        searchFieldValue: event.searchFieldValue);
    final result =
        await pullToRefreshStockRankings.call(event.market, event.sectors);
    result.fold(
      (failure) =>
          emit(StockRankingsError(filter: filter, message: failure.message)),
      (stockRankingsResult) {
        emit(StockRankingsLoaded(
            filter: filter,
            rankedStocks: stockRankingsResult.rankedStocks,
            hasReachedMaxData: stockRankingsResult.hasReachedMaxData));
      },
    );
  }

  void _onFilterStockRankings(
      FilterStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    final filter = StockRankingsFilter(
        market: event.market,
        sectors: event.sectors,
        searchFieldValue: event.searchFieldValue);
    emit(StockRankingsLoading(filter: filter));

    final result = await filterStockRankings.call(
        event.searchFieldValue, event.market, event.sectors);
    result.fold(
      (failure) =>
          emit(StockRankingsError(filter: filter, message: failure.message)),
      (stockRankingsResult) {
        emit(StockRankingsLoaded(
            filter: filter,
            rankedStocks: stockRankingsResult.rankedStocks,
            hasReachedMaxData: stockRankingsResult.hasReachedMaxData));
      },
    );
  }
}
