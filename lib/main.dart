import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_cubit.dart';
import 'features/stock_ranking/stock_ranking.dart';
import 'core/networking/graphql_service.dart';
void main() {
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
        BlocProvider(create: (context) => StockRankingsBloc(GetStockRankingsUsecase(StockRankingRepositoryImpl(StockRankingGraphqlDatasource(GraphqlService()))))), // TODO: Find a better way to do this
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.stockRankingListScreen,
      ),
    );
  }
}
