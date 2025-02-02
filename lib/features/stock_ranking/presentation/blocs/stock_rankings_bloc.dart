import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  final GetStockRankingsUsecase getStockRankings;
  final LoadMoreStockRankingsUsecase loadMoreStockRankings;
  final PullToRefreshStockRankingsUsecase pullToRefreshStockRankings;
  final FilterStockRankingsUsecase filterStockRankings;

  final int _defaultLimit = ApiConstants.defaultLimit;
  final int _defaultPage = ApiConstants.defaultPage;
  List<RankedStock> _loadedRankedStocks = [];

  StockRankingsBloc(
    this.getStockRankings,
    this.loadMoreStockRankings,
    this.pullToRefreshStockRankings,
    this.filterStockRankings,
  ) : super(StockRankingsInitial()) {
    on<GetStockRankingsEvent>(_onGetStockRankings);
    on<LoadMoreStockRankingsEvent>(_onLoadMoreStockRankings);
    on<PullToRefreshStockRankingsEvent>(_onPullToRefreshStockRankings);
    on<FilterStockRankingsEvent>(_onFilterStockRankings);
  }

  void _onGetStockRankings(
      GetStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    if (state is StockRankingsInitial) {
      emit(StockRankingsLoading(
          market: event.market,
          sectors: event.sectors,
          searchFieldValue: event.searchFieldValue));
    }

    final result = await getStockRankings.call(
        _defaultLimit, event.market, _defaultPage, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(
          market: event.market,
          sectors: event.sectors,
          searchFieldValue: event.searchFieldValue,
          message: failure.message)),
      (rankedStocks) {
        _loadedRankedStocks = rankedStocks;
        final hasReachedMaxData =
            (rankedStocks.length < _defaultLimit) && rankedStocks.isNotEmpty;
        emit(StockRankingsLoaded(
            market: event.market,
            sectors: event.sectors,
            searchFieldValue: event.searchFieldValue,
            rankedStocks: rankedStocks,
            hasReachedMaxData: hasReachedMaxData));
      },
    );
  }

  void _onPullToRefreshStockRankings(PullToRefreshStockRankingsEvent event,
      Emitter<StockRankingsState> emit) async {
    final result = await pullToRefreshStockRankings.call(
        _defaultLimit, event.market, _defaultPage, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(
          market: event.market,
          sectors: event.sectors,
          searchFieldValue: event.searchFieldValue,
          message: failure.message)),
      (rankedStocks) {
        _loadedRankedStocks = rankedStocks;
        final hasReachedMaxData =
            (rankedStocks.length < _defaultLimit) && rankedStocks.isNotEmpty;
        emit(StockRankingsLoaded(
            market: event.market,
            sectors: event.sectors,
            searchFieldValue: event.searchFieldValue,
            rankedStocks: rankedStocks,
            hasReachedMaxData: hasReachedMaxData));
      },
    );
  }

  void _onFilterStockRankings(
      FilterStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    emit(StockRankingsLoading(
        market: event.market,
        sectors: event.sectors,
        searchFieldValue: event.searchFieldValue));

    final result = await filterStockRankings.call(
        event.searchFieldValue, event.market, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(
          market: event.market,
          sectors: event.sectors,
          searchFieldValue: event.searchFieldValue,
          message: failure.message)),
      (rankedStocks) {
        _loadedRankedStocks = rankedStocks;
        final hasReachedMaxData =
            (rankedStocks.length < _defaultLimit) && rankedStocks.isNotEmpty;
        emit(StockRankingsLoaded(
            market: event.market,
            sectors: event.sectors,
            searchFieldValue: event.searchFieldValue,
            rankedStocks: rankedStocks,
            hasReachedMaxData: hasReachedMaxData));
      },
    );
  }

  void _onLoadMoreStockRankings(LoadMoreStockRankingsEvent event,
      Emitter<StockRankingsState> emit) async {
    final result = await loadMoreStockRankings.call(
        _defaultLimit, event.market, event.page, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(
          market: event.market,
          sectors: event.sectors,
          searchFieldValue: event.searchFieldValue,
          message: failure.message)),
      (rankedStocks) {
        if (rankedStocks.length < _defaultLimit && rankedStocks.isNotEmpty) {
          _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
          emit(StockRankingsLoaded(
              market: event.market,
              sectors: event.sectors,
              searchFieldValue: event.searchFieldValue,
              rankedStocks: _loadedRankedStocks,
              hasReachedMaxData: true));
          return;
        }

        if (rankedStocks.isNotEmpty) {
          _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
          emit(StockRankingsLoaded(
              market: event.market,
              sectors: event.sectors,
              searchFieldValue: event.searchFieldValue,
              rankedStocks: _loadedRankedStocks,
              hasReachedMaxData: false));
        } else {
          emit(StockRankingsLoaded(
              market: event.market,
              sectors: event.sectors,
              searchFieldValue: event.searchFieldValue,
              rankedStocks: _loadedRankedStocks,
              hasReachedMaxData: true));
        }
      },
    );
  }
}
