import 'package:equatable/equatable.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';

import '../../domain/entities/ranked_stock.dart';

class StockRankingsFilter extends Equatable {
  const StockRankingsFilter({
    this.market = ApiConstants.defaultMarket,
    this.sectors = const [],
    this.searchFieldValue = '',
  });

  final String market;
  final List<String> sectors;
  final String searchFieldValue;

  @override
  List<Object?> get props => [market, sectors, searchFieldValue];
}

enum StockRankingsStatus {
  initial,
  loading,

  /// Appending a page. The already-loaded list stays on screen.
  loadingMore,
  success,
  failure,
}

/// One state rather than four subclasses, so a failure can carry the list it
/// failed on.
///
/// With separate Loaded/Error classes, a load-more that failed 200 rows into a
/// scroll emitted an Error with no stocks and the whole screen was replaced by
/// a full-page error. Here [status] goes to failure while [rankedStocks] keeps
/// what was already fetched, and the UI shows an inline retry instead. A
/// first-load failure still has an empty list, which is what the full-page
/// error should key off.
class StockRankingsState extends Equatable {
  const StockRankingsState({
    this.status = StockRankingsStatus.initial,
    this.rankedStocks = const [],
    this.filter = const StockRankingsFilter(),
    this.hasReachedMaxData = false,
    this.errorMessage,
  });

  final StockRankingsStatus status;
  final List<RankedStock> rankedStocks;
  final StockRankingsFilter filter;
  final bool hasReachedMaxData;
  final String? errorMessage;

  bool get isInitial => status == StockRankingsStatus.initial;
  bool get isLoadingMore => status == StockRankingsStatus.loadingMore;
  bool get hasFailed => status == StockRankingsStatus.failure;

  /// A failure with nothing already on screen: the only case that warrants
  /// replacing the whole screen with an error.
  bool get hasFailedWithNoData => hasFailed && rankedStocks.isEmpty;

  StockRankingsState copyWith({
    StockRankingsStatus? status,
    List<RankedStock>? rankedStocks,
    StockRankingsFilter? filter,
    bool? hasReachedMaxData,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StockRankingsState(
      status: status ?? this.status,
      rankedStocks: rankedStocks ?? this.rankedStocks,
      filter: filter ?? this.filter,
      hasReachedMaxData: hasReachedMaxData ?? this.hasReachedMaxData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        rankedStocks,
        filter,
        hasReachedMaxData,
        errorMessage,
      ];
}
