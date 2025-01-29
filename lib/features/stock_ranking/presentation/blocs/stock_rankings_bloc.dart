import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/domain/usecases/get_stock_rankings.dart';
import 'stock_rankings_event.dart';
import 'stock_rankings_state.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/domain/entities/ranked_stock.dart';

class StockRankingsBloc extends Bloc<StockRankingsEvent, StockRankingsState> {
  final GetStockRankingsUsecase getStockRankings;
  final int _limit = ApiConstants.defaultLoadLimit;
  String _currentMarket = ApiConstants.defaultMarket;
  List<String> _currentSectors = [];
  List<RankedStock> _loadedRankedStocks = [];

  StockRankingsBloc(this.getStockRankings) : super(StockRankingsInitial()) {
    on<GetStockRankingsEvent>(_onGetStockRankings);
    on<RefreshStockRankingsEvent>(_onRefreshStockRankings);
    on<SearchStockRankingsEvent>(_onSearchStockRankings);
    on<ClearLoadedStockRankingsEvent>(_onClearLoadedStockRankings);
  }

  void _onGetStockRankings(GetStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    try {
      // If the sectors have changed, clear the loaded stocks
      if (event.sectors != _currentSectors) {
        _currentSectors = event.sectors;
        _loadedRankedStocks.clear();
      }

      if (state is StockRankingsInitial) {
        emit(StockRankingsLoading());

        final rankedStocks = await getStockRankings.call(
            _limit, _currentMarket, 1, _currentSectors);
        _loadedRankedStocks = rankedStocks;
        emit(StockRankingsLoaded(
            rankedStocks: rankedStocks, hasReachedMaxData: false));
        return;
      }

      if (state is StockRankingsLoaded) {
        final page = event.page;
        final rankedStocks = await getStockRankings.call(
            _limit, _currentMarket, page, _currentSectors);

        if (rankedStocks.isNotEmpty) {
          _loadedRankedStocks = [..._loadedRankedStocks, ...rankedStocks];
          emit(StockRankingsLoaded(
              rankedStocks: _loadedRankedStocks, hasReachedMaxData: false));
        } else {
          emit(StockRankingsLoaded(
              rankedStocks: _loadedRankedStocks, hasReachedMaxData: true));
        }
      }
    } catch (e) {
      emit(StockRankingsError(e.toString()));
    }
  }

  void _onRefreshStockRankings(RefreshStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    _loadedRankedStocks.clear();
    emit(StockRankingsInitial());
  }

  void _onSearchStockRankings(SearchStockRankingsEvent event, Emitter<StockRankingsState> emit) async {
    if (state is StockRankingsLoaded) {
      final loadedState = state as StockRankingsLoaded;
      if (event.query.isEmpty) {
        emit(StockRankingsLoaded(
          rankedStocks: _loadedRankedStocks,
          hasReachedMaxData: loadedState.hasReachedMaxData,
        ));
      } else {
        final filteredStocks = _loadedRankedStocks
            .where((stock) =>
                stock.symbol.toLowerCase().contains(event.query.toLowerCase()) ||
                stock.title.toLowerCase().contains(event.query.toLowerCase())
            )
            .toList();

        final uniqueStocks = filteredStocks.fold<Map<String, RankedStock>>({}, 
          (map, stock) {
            if (!map.containsKey(stock.symbol)) {
              map[stock.symbol] = stock;
            }
            return map;
          }).values.toList();

        emit(StockRankingsLoaded(
          rankedStocks: uniqueStocks,
          hasReachedMaxData: true, // Disable pagination during search
        ));
      }
    }
  }

  void _onClearLoadedStockRankings(ClearLoadedStockRankingsEvent event, Emitter<StockRankingsState> emit) {
    _loadedRankedStocks.clear();
    emit(StockRankingsInitial());
  }
}
