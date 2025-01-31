import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  final GetStockRankingsUsecase getStockRankings;
  final LoadMoreStockRankingsUsecase loadMoreStockRankings;
  final PullToRefreshStockRankingsUsecase pullToRefreshStockRankings;
  final SearchStockRankingsUsecase searchStockRankings;

  final int _defaultLoadLimit = ApiConstants.defaultLoadLimit;
  final int _defaultLoadPage = ApiConstants.defaultLoadPage;
  final String _defaultMarket = ApiConstants.defaultMarket;

  // String _currentMarket = ApiConstants.defaultMarket;
  // List<String> _currentSectors = [];
  List<RankedStock> _loadedRankedStocks = [];

  StockRankingsBloc(
    this.getStockRankings,
    this.loadMoreStockRankings,
    this.pullToRefreshStockRankings,
    this.searchStockRankings,
  ) : super(StockRankingsInitial()) {
    on<GetStockRankingsEvent>(_onGetStockRankings);
    on<PullToRefreshStockRankingsEvent>(_onPullToRefreshStockRankings);
    on<SearchStockRankingsEvent>(_onSearchStockRankings);
    on<FilterStockRankingsEvent>(_onFilterStockRankings);
    on<LoadMoreStockRankingsEvent>(_onLoadMoreStockRankings);
  }

  void _onGetStockRankings(GetStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    if (state is StockRankingsInitial) {
      emit(StockRankingsLoading());
    }

    final result = await getStockRankings.call(_defaultLoadLimit, event.market, _defaultLoadPage, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(failure.message)),
      (rankedStocks) {
        _loadedRankedStocks = rankedStocks;
        final hasReachedMaxData = (rankedStocks.length < _defaultLoadLimit) && rankedStocks.isNotEmpty;
        emit(StockRankingsLoaded(rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
      },
    );
  }

  void _onPullToRefreshStockRankings(PullToRefreshStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    final result = await pullToRefreshStockRankings.call(_defaultLoadLimit, event.market, _defaultLoadPage, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(failure.message)),
      (rankedStocks) {
        _loadedRankedStocks = rankedStocks;
        final hasReachedMaxData = (rankedStocks.length < _defaultLoadLimit) && rankedStocks.isNotEmpty;
        emit(StockRankingsLoaded(rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
      },
    );
  }

  void _onSearchStockRankings(SearchStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    if (state is StockRankingsLoaded) {
      final loadedState = state as StockRankingsLoaded;
      if (event.searchFieldValue.isEmpty) {
        emit(StockRankingsLoaded(rankedStocks: _loadedRankedStocks, hasReachedMaxData: loadedState.hasReachedMaxData));
      } else {
        final result = await searchStockRankings.call(event.searchFieldValue, event.market, event.sectors);
        result.fold(
          (failure) => emit(StockRankingsError(failure.message)),
          (rankedStocks) {
            emit(StockRankingsLoaded(rankedStocks: rankedStocks, hasReachedMaxData: true)); // Disable pagination during search
          },
        );
      }
    }
  }

  void _onFilterStockRankings(FilterStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    emit(StockRankingsLoading());

    final result = await getStockRankings.call(_defaultLoadLimit, event.market, _defaultLoadPage, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(failure.message)),
      (rankedStocks) {
        _loadedRankedStocks = rankedStocks;
        final hasReachedMaxData = (rankedStocks.length < _defaultLoadLimit) && rankedStocks.isNotEmpty;
        emit(StockRankingsLoaded(rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
      },
    );
  }

  void _onLoadMoreStockRankings(LoadMoreStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    final result = await loadMoreStockRankings.call(
        _defaultLoadLimit, event.market, event.page, event.sectors);
    result.fold(
      (failure) => emit(StockRankingsError(failure.message)),
      (rankedStocks) {
        if (rankedStocks.length < _defaultLoadLimit && rankedStocks.isNotEmpty) {
          _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
          emit(StockRankingsLoaded(rankedStocks: _loadedRankedStocks, hasReachedMaxData: true));
          return;
        }

        if (rankedStocks.isNotEmpty) {
          _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
          emit(StockRankingsLoaded(rankedStocks: _loadedRankedStocks, hasReachedMaxData: false));
        } else {
          emit(StockRankingsLoaded(rankedStocks: _loadedRankedStocks, hasReachedMaxData: true));
        }
      },
    );
  }
}
