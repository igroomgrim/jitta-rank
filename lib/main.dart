import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_cubit.dart';
import 'features/stock_ranking/stock_ranking.dart';
import 'features/stock_detail/stock_detail.dart';
import 'core/networking/graphql_service.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RankedStockModelAdapter());
  Hive.registerAdapter(SectorModelAdapter());
  Hive.registerAdapter(StockModelAdapter());
  Hive.registerAdapter(StockPriceModelAdapter());
  Hive.registerAdapter(StockJittaModelAdapter());
  Hive.registerAdapter(StockJittaFactorModelAdapter());
  Hive.registerAdapter(StockJittaFactorGrowthModelAdapter());
  Hive.registerAdapter(StockJittaFactorFinancialModelAdapter());
  Hive.registerAdapter(StockJittaFactorManagementModelAdapter());
  Hive.registerAdapter(StockGraphPriceItemModelAdapter());
  Hive.registerAdapter(StockGraphPriceModelAdapter());
  await Hive.openBox<RankedStockModel>('ranked_stocks');
  await Hive.openBox<SectorModel>('sectors');
  await Hive.openBox<StockModel>('stock_detail');
  await Hive.openBox<StockPriceModel>('stock_price');
  await Hive.openBox<StockJittaModel>('stock_jitta');
  await Hive.openBox<StockJittaFactorModel>('stock_jitta_factor');
  await Hive.openBox<StockJittaFactorGrowthModel>('stock_jitta_factor_growth');
  await Hive.openBox<StockJittaFactorFinancialModel>('stock_jitta_factor_financial');
  await Hive.openBox<StockJittaFactorManagementModel>('stock_jitta_factor_management');
  await Hive.openBox<StockGraphPriceItemModel>('stock_graph_price_item');
  await Hive.openBox<StockGraphPriceModel>('stock_graph_price');
  // TODO: move to the right place - maybe dependency injection?

  final networkInfoService = NetworkInfoServiceImpl();
  final graphqlService = GraphqlService();
  final stockRankingGraphqlDatasource = StockRankingGraphqlDatasource(graphqlService);
  final stockRankingLocalDatasource = StockRankingLocalDatasourceImpl();

  runApp(MyApp(
    networkInfoService: networkInfoService,
    graphqlService: graphqlService,
    stockRankingGraphqlDatasource: stockRankingGraphqlDatasource,
    stockRankingLocalDatasource: stockRankingLocalDatasource,
  ));
}

class MyApp extends StatelessWidget {
  final NetworkInfoService networkInfoService;
  final GraphqlService graphqlService;
  final StockRankingGraphqlDatasource stockRankingGraphqlDatasource;
  final StockRankingLocalDatasource stockRankingLocalDatasource;

  final StockRankingRepository stockRankingRepository;

  MyApp({
    super.key,
    required this.networkInfoService,
    required this.graphqlService,
    required this.stockRankingGraphqlDatasource,
    required this.stockRankingLocalDatasource,
  }) : stockRankingRepository = StockRankingRepositoryImpl(
          stockRankingGraphqlDatasource,
          stockRankingLocalDatasource,
          networkInfoService,
        );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(
            create: (context) => StockRankingsBloc(
                  GetStockRankingsUsecase(
                    StockRankingRepositoryImpl(
                      stockRankingGraphqlDatasource,
                      stockRankingLocalDatasource,
                      networkInfoService,
                    ),
                  ),
                  LoadMoreStockRankingsUsecase(
                    StockRankingRepositoryImpl(
                      stockRankingGraphqlDatasource,
                      stockRankingLocalDatasource,
                      networkInfoService,
                    ),
                  ),
                )),
        BlocProvider(create: (context) => NetworkInfoBloc(networkInfoService)),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.stockRankingListScreen,
      ),
    );
  }
}
