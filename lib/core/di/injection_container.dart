import 'package:get_it/get_it.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/storage/storage_service.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Networking Services
  getIt.registerLazySingleton<GraphqlService>(() => GraphqlService());
  getIt.registerLazySingleton<NetworkInfoService>(
      () => NetworkInfoServiceImpl());

  // Datasources
  getIt.registerLazySingleton<StockRankingGraphqlDatasource>(
      () => StockRankingGraphqlDatasource(getIt()));
  getIt.registerLazySingleton<StockRankingLocalDatasource>(
      () => StockRankingLocalDatasourceImpl());

  // Repositories
  getIt.registerLazySingleton<StockRankingRepository>(() =>
      StockRankingRepositoryImpl(
          graphqlDatasource: getIt(),
          localDatasource: getIt(),
          networkInfoService: getIt()));

  // Usecases
  getIt.registerLazySingleton<GetStockRankingsUsecase>(
      () => GetStockRankingsUsecase(getIt()));
  getIt.registerLazySingleton<LoadMoreStockRankingsUsecase>(
      () => LoadMoreStockRankingsUsecase(getIt()));
  getIt.registerLazySingleton<PullToRefreshStockRankingsUsecase>(
      () => PullToRefreshStockRankingsUsecase(getIt()));
  getIt.registerLazySingleton<FilterStockRankingsUsecase>(
      () => FilterStockRankingsUsecase(getIt()));

  // Stock Rankings Bloc
  getIt.registerLazySingleton<StockRankingsBloc>(
      () => StockRankingsBloc(getIt(), getIt(), getIt(), getIt()));

  // Navigation Bloc
  getIt.registerLazySingleton<NavigationCubit>(() => NavigationCubit());

  // Network Info Bloc
  getIt.registerLazySingleton<NetworkInfoBloc>(() => NetworkInfoBloc(getIt()));

  // Storage Service
  getIt.registerLazySingleton<StorageService>(() => StorageServiceImpl());
  final storageService = getIt<StorageService>();
  await storageService.init(); // call for initialize storage service
}
