import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/get_stock_rankings.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/load_more_stock_rankings.dart';
import 'stock_rankings_event.dart';
import 'stock_rankings_state.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  final GetStockRankingsUsecase getStockRankings;
  final LoadMoreStockRankingsUsecase loadMoreStockRankings;
  final int _defaultLoadLimit = ApiConstants.defaultLoadLimit;
  final int _defaultLoadPage = ApiConstants.defaultLoadPage;
  final String _defaultMarket = ApiConstants.defaultMarket;

  // String _currentMarket = ApiConstants.defaultMarket;
  // List<String> _currentSectors = [];
  List<RankedStock> _loadedRankedStocks = [];

  StockRankingsBloc(this.getStockRankings, this.loadMoreStockRankings) : super(StockRankingsInitial()) {
    on<GetStockRankingsEvent>(_onGetStockRankings);
    on<PullToRefreshStockRankingsEvent>(_onPullToRefreshStockRankings);
    on<SearchStockRankingsEvent>(_onSearchStockRankings);
    on<FilterStockRankingsEvent>(_onFilterStockRankings);
    on<LoadMoreStockRankingsEvent>(_onLoadMoreStockRankings);
  }

  void _onGetStockRankings(GetStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    print('StockRankingsBloc: GETTING - market: ${event.market} sectors: ${event.sectors} state: ${state.runtimeType}');
    try {
      if (state is StockRankingsInitial) {
        emit(StockRankingsLoading());
      }
      final rankedStocks = await getStockRankings.call(
          _defaultLoadLimit, event.market, _defaultLoadPage, event.sectors);
      _loadedRankedStocks = rankedStocks;

      final hasReachedMaxData = (rankedStocks.length < _defaultLoadLimit) && rankedStocks.isNotEmpty;
      emit(StockRankingsLoaded(rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
    } catch (e) {
      emit(StockRankingsError(e.toString()));
    }
  }

  void _onPullToRefreshStockRankings(PullToRefreshStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    print('StockRankingsBloc: PULLING TO REFRESH - market: ${event.market} sectors: ${event.sectors}');
    try {
      final rankedStocks = await getStockRankings.call(
          _defaultLoadLimit, event.market, _defaultLoadPage, event.sectors);
      _loadedRankedStocks = rankedStocks;

      final hasReachedMaxData = (rankedStocks.length < _defaultLoadLimit) && rankedStocks.isNotEmpty;
      emit(StockRankingsLoaded(rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
    } catch (e) {
      emit(StockRankingsError(e.toString()));
    }
  }

  void _onSearchStockRankings(SearchStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    print('StockRankingsBloc: SEARCHING - searchFieldValue: ${event.searchFieldValue}');
    try {
      if (state is StockRankingsLoaded) {
        final loadedState = state as StockRankingsLoaded;
        if (event.searchFieldValue.isEmpty) {
          print('if state is StockRankingsLoaded');
          emit(StockRankingsLoaded(
            rankedStocks: _loadedRankedStocks,
            hasReachedMaxData: loadedState.hasReachedMaxData,
          ));
        } else {
          print('else state is StockRankingsLoaded');
          final filteredStocks = _loadedRankedStocks
              .where((stock) =>
                  stock.symbol
                      .toLowerCase()
                      .contains(event.searchFieldValue.toLowerCase()) ||
                  stock.title
                      .toLowerCase()
                      .contains(event.searchFieldValue.toLowerCase()))
              .toList();

          final uniqueStocks = filteredStocks
              .fold<Map<String, RankedStock>>({}, (map, stock) {
                if (!map.containsKey(stock.symbol)) {
                  map[stock.symbol] = stock;
                }
                return map;
              })
              .values
              .toList();

          emit(StockRankingsLoaded(
            rankedStocks: uniqueStocks,
            hasReachedMaxData: true, // Disable pagination during search
          ));
        }
      }
    } catch (e) {
      emit(StockRankingsError(e.toString()));
    }
  }

  void _onFilterStockRankings(FilterStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    print('StockRankingsBloc: FILTERING - market: ${event.market} sectors: ${event.sectors}');
    try {
      emit(StockRankingsLoading());

      final rankedStocks =
          await getStockRankings.call(_defaultLoadLimit, event.market, _defaultLoadPage, event.sectors);
      _loadedRankedStocks = rankedStocks;

      final hasReachedMaxData = (rankedStocks.length < _defaultLoadLimit) && rankedStocks.isNotEmpty;
      emit(StockRankingsLoaded(
          rankedStocks: rankedStocks, hasReachedMaxData: hasReachedMaxData));
    } catch (e) {
      emit(StockRankingsError(e.toString()));
    }
  }

  void _onLoadMoreStockRankings(LoadMoreStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    final rankedStocks = await loadMoreStockRankings.call(_defaultLoadLimit, event.market, event.page, event.sectors);
    print('StockRankingsBloc: LOADING MORE - page: ${event.page} market: ${event.market} sectors: ${event.sectors} rankedStocks: ${rankedStocks.length}');
    
    if (rankedStocks.length < _defaultLoadLimit && rankedStocks.isNotEmpty) {
      print('StockRankingsBloc: LOADING MORE - rankedStocks is less than defaultLoadLimit');
      _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
      emit(StockRankingsLoaded(
          rankedStocks: _loadedRankedStocks, hasReachedMaxData: true));
      return;
    }

    if (rankedStocks.isNotEmpty) {
      _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
      emit(StockRankingsLoaded(
          rankedStocks: _loadedRankedStocks, hasReachedMaxData: false));
    } else {
      emit(StockRankingsLoaded(
          rankedStocks: _loadedRankedStocks, hasReachedMaxData: true));
    }
  }
}
