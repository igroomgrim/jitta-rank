import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_cubit.dart';
import 'features/stock_ranking/stock_ranking.dart';
import 'core/networking/graphql_service.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RankedStockModelAdapter());
  Hive.registerAdapter(SectorModelAdapter());
  await Hive.openBox<RankedStockModel>('ranked_stocks');
  await Hive.openBox<SectorModel>('sectors');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => StockRankingsBloc(GetStockRankingsUsecase(StockRankingRepositoryImpl(StockRankingGraphqlDatasource(GraphqlService()), StockRankingLocalDatasourceImpl())))), // TODO: Find a better way to do this
        BlocProvider(create: (context) => NetworkInfoBloc(NetworkInfoServiceImpl())),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.stockRankingListScreen,
      ),
    );
  }
}
