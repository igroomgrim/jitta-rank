import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/core/storage/storage_service.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

final getIt = GetIt.instance;

/// [storagePath] is for tests, which must point Hive at a temp directory.
Future<void> initializeDependencies({String? storagePath}) async {
  // Storage first: the local datasources call Hive.box() in their
  // constructors, so the boxes have to be open before anything resolves them.
  getIt.registerLazySingleton<StorageService>(StorageServiceImpl.new);
  await getIt<StorageService>().init(path: storagePath);

  // Networking Services
  getIt.registerLazySingleton<GraphqlService>(() => GraphqlService());
  getIt.registerLazySingleton<NetworkInfoService>(
    () => NetworkInfoServiceImpl(),
  );

  // Datasources
  getIt.registerLazySingleton<StockRankingGraphqlDatasource>(
    () => StockRankingGraphqlDatasource(graphqlService: getIt()),
  );
  getIt.registerLazySingleton<StockRankingLocalDatasource>(
    () => StockRankingLocalDatasourceImpl(
      box: Hive.box<RankedStockModel>(HiveBoxes.rankedStocks),
    ),
  );
  getIt.registerLazySingleton<StockDetailGraphqlDatasource>(
    () => StockDetailGraphqlDatasource(getIt()),
  );
  getIt.registerLazySingleton<StockDetailLocalDatasource>(
    () => StockDetailLocalDatasourceImpl(
      box: Hive.box<StockModel>(HiveBoxes.stockDetail),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<StockRankingRepository>(
    () => StockRankingRepositoryImpl(
      graphqlDatasource: getIt(),
      localDatasource: getIt(),
      networkInfoService: getIt(),
    ),
  );

  getIt.registerLazySingleton<StockDetailRepository>(
    () => StockDetailRepositoryImpl(
      graphqlDatasource: getIt(),
      localDatasource: getIt(),
      networkInfoService: getIt(),
    ),
  );

  // Usecases
  getIt.registerLazySingleton<GetStockRankingsUsecase>(
    () => GetStockRankingsUsecase(getIt()),
  );
  getIt.registerLazySingleton<LoadMoreStockRankingsUsecase>(
    () => LoadMoreStockRankingsUsecase(getIt()),
  );
  getIt.registerLazySingleton<PullToRefreshStockRankingsUsecase>(
    () => PullToRefreshStockRankingsUsecase(getIt()),
  );
  getIt.registerLazySingleton<FilterStockRankingsUsecase>(
    () => FilterStockRankingsUsecase(getIt()),
  );

  getIt.registerLazySingleton<GetStockDetailUsecase>(
    () => GetStockDetailUsecase(getIt()),
  );

  // Stock Rankings Bloc
  getIt.registerFactory<StockRankingsBloc>(
    () => StockRankingsBloc(
      getStockRankings: getIt(),
      loadMoreStockRankings: getIt(),
      pullToRefreshStockRankings: getIt(),
      filterStockRankings: getIt(),
    ),
  );

  // Stock Detail Bloc
  getIt.registerFactory<StockDetailBloc>(
    () => StockDetailBloc(getIt()),
  );

  // Navigation Bloc
  getIt.registerFactory<NavigationCubit>(() => NavigationCubit());

  // Network Info Bloc
  getIt.registerFactory<NetworkInfoBloc>(() => NetworkInfoBloc(getIt()));
}
