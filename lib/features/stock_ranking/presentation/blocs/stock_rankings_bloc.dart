import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<Event> throttleDroppable<Event>() {
  const throttleDuration = Duration(milliseconds: 100);
  return (events, mapper) {
    return droppable<Event>().call(events.throttle(throttleDuration), mapper);
  };
}

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  StockRankingsBloc({
    required this.getStockRankings,
    required this.loadMoreStockRankings,
    required this.pullToRefreshStockRankings,
    required this.filterStockRankings,
  }) : super(const StockRankingsState()) {
    on<GetStockRankingsEvent>(_onGetStockRankings);
    on<LoadMoreStockRankingsEvent>(
      _onLoadMoreStockRankings,
      transformer: throttleDroppable(),
    );
    on<PullToRefreshStockRankingsEvent>(_onPullToRefreshStockRankings);
    on<FilterStockRankingsEvent>(_onFilterStockRankings);
  }

  final GetStockRankingsUsecase getStockRankings;
  final LoadMoreStockRankingsUsecase loadMoreStockRankings;
  final PullToRefreshStockRankingsUsecase pullToRefreshStockRankings;
  final FilterStockRankingsUsecase filterStockRankings;

  static StockRankingsFilter _filterOf(StockRankingsEvent event) =>
      StockRankingsFilter(
        market: event.market,
        sectors: event.sectors,
        searchFieldValue: event.searchFieldValue,
      );

  Future<void> _onGetStockRankings(
    GetStockRankingsEvent event,
    Emitter<StockRankingsState> emit,
  ) async {
    final filter = _filterOf(event);
    // Carry the event's filter into the loading state: emitting a default
    // filter here made the app bar flash "Thailand" mid-load even when the
    // user had switched market.
    emit(
      state.copyWith(
        status: StockRankingsStatus.loading,
        filter: filter,
        clearError: true,
      ),
    );

    final result = await getStockRankings.call(
      limit: event.limit,
      market: event.market,
      page: event.page,
      sectors: event.sectors,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StockRankingsStatus.failure,
          filter: filter,
          errorMessage: failure.message,
        ),
      ),
      (success) => emit(
        state.copyWith(
          status: StockRankingsStatus.success,
          filter: filter,
          rankedStocks: success.rankedStocks,
          hasReachedMaxData: success.hasReachedMaxData,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreStockRankings(
    LoadMoreStockRankingsEvent event,
    Emitter<StockRankingsState> emit,
  ) async {
    if (state.hasReachedMaxData) return;

    emit(state.copyWith(status: StockRankingsStatus.loadingMore));

    final result = await loadMoreStockRankings.call(
      event.market,
      event.page,
      event.sectors,
    );

    result.fold(
      // Keep rankedStocks: a network blip mid-scroll used to replace the whole
      // list with a full-page error.
      (failure) => emit(
        state.copyWith(
          status: StockRankingsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (success) {
        // Always emit, including on an empty page. The previous version
        // returned without emitting when the page came back empty, so
        // hasReachedMaxData never flipped, the trailing spinner never went
        // away, and the list kept re-requesting the same empty page forever.
        if (success.rankedStocks.isEmpty) {
          emit(
            state.copyWith(
              status: StockRankingsStatus.success,
              hasReachedMaxData: true,
              clearError: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: StockRankingsStatus.success,
            rankedStocks: [...state.rankedStocks, ...success.rankedStocks],
            hasReachedMaxData: success.hasReachedMaxData,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onPullToRefreshStockRankings(
    PullToRefreshStockRankingsEvent event,
    Emitter<StockRankingsState> emit,
  ) async {
    final filter = _filterOf(event);
    final result = await pullToRefreshStockRankings.call(
      event.market,
      event.sectors,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StockRankingsStatus.failure,
          filter: filter,
          errorMessage: failure.message,
        ),
      ),
      (success) => emit(
        state.copyWith(
          status: StockRankingsStatus.success,
          filter: filter,
          rankedStocks: success.rankedStocks,
          hasReachedMaxData: success.hasReachedMaxData,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onFilterStockRankings(
    FilterStockRankingsEvent event,
    Emitter<StockRankingsState> emit,
  ) async {
    final filter = _filterOf(event);
    emit(
      state.copyWith(
        status: StockRankingsStatus.loading,
        filter: filter,
        clearError: true,
      ),
    );

    final result = await filterStockRankings.call(
      event.searchFieldValue,
      event.market,
      event.sectors,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StockRankingsStatus.failure,
          filter: filter,
          errorMessage: failure.message,
        ),
      ),
      (success) => emit(
        state.copyWith(
          status: StockRankingsStatus.success,
          filter: filter,
          rankedStocks: success.rankedStocks,
          hasReachedMaxData: success.hasReachedMaxData,
          clearError: true,
        ),
      ),
    );
  }
}
