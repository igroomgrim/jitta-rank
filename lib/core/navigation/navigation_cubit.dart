import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NavigationState {}

class NavigationToStockRankingListScreen extends NavigationState {}

class NavigateToStockDetailScreen extends NavigationState {
  NavigateToStockDetailScreen(this.stockId);
  final int stockId;
}

class NavigationCubit extends Cubit<NavigationState?> {
  NavigationCubit() : super(null);

  void navigateToStockRankingListScreen() {
    emit(NavigationToStockRankingListScreen());
  }

  void navigateToStockDetailScreen(int stockId) {
    emit(NavigateToStockDetailScreen(stockId));
  }

  void resetNavigation() {
    emit(null);
  }
}
