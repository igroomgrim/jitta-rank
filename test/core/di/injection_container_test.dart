import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/core.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

/// Resolving every registered type is the only way to catch a wiring mistake:
/// getIt failures are runtime failures, so `flutter analyze` and a green unit
/// suite say nothing about whether the container is actually complete.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('jitta_rank_di_test');
    await getIt.reset();
    await initializeDependencies(storagePath: tempDir.path);
  });

  tearDown(() async {
    await getIt<StorageService>().close();
    await getIt.reset();
    await tempDir.delete(recursive: true);
  });

  test('every dependency the app needs resolves', () {
    // Core
    expect(getIt<StorageService>(), isA<StorageServiceImpl>());
    expect(getIt<GraphqlService>(), isNotNull);
    expect(getIt<NetworkInfoService>(), isA<NetworkInfoServiceImpl>());

    // stock_ranking
    expect(getIt<StockRankingGraphqlDatasource>(), isNotNull);
    expect(getIt<StockRankingLocalDatasource>(), isNotNull);
    expect(getIt<StockRankingRepository>(), isNotNull);
    expect(getIt<GetStockRankingsUsecase>(), isNotNull);
    expect(getIt<LoadMoreStockRankingsUsecase>(), isNotNull);
    expect(getIt<PullToRefreshStockRankingsUsecase>(), isNotNull);
    expect(getIt<FilterStockRankingsUsecase>(), isNotNull);

    // stock_detail — registered nowhere before this refactor; the screen built
    // its own graph inside build().
    expect(getIt<StockDetailGraphqlDatasource>(), isNotNull);
    expect(getIt<StockDetailLocalDatasource>(), isNotNull);
    expect(getIt<StockDetailRepository>(), isNotNull);
    expect(getIt<GetStockDetailUsecase>(), isNotNull);
  });

  test('blocs are factories, so BlocProvider can own and close them', () {
    // BlocProvider(create:) calls close() on dispose. A singleton bloc would be
    // handed back already closed the second time a screen is opened.
    final rankings = getIt<StockRankingsBloc>();
    final rankings2 = getIt<StockRankingsBloc>();
    expect(identical(rankings, rankings2), isFalse);

    final detail = getIt<StockDetailBloc>();
    expect(identical(detail, getIt<StockDetailBloc>()), isFalse);

    expect(
      identical(getIt<NavigationCubit>(), getIt<NavigationCubit>()),
      isFalse,
    );
    expect(
      identical(getIt<NetworkInfoBloc>(), getIt<NetworkInfoBloc>()),
      isFalse,
    );

    // Closing one must not affect another.
    rankings.close();
    expect(rankings2.isClosed, isFalse);
    rankings2.close();
    detail.close();
  });

  test('non-bloc dependencies are shared singletons', () {
    expect(identical(getIt<GraphqlService>(), getIt<GraphqlService>()), isTrue);
    expect(
      identical(
        getIt<StockRankingRepository>(),
        getIt<StockRankingRepository>(),
      ),
      isTrue,
    );
  });
}
