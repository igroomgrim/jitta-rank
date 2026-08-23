import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info_service.dart';

// Events
abstract class NetworkInfoEvent {}

class CheckConnectionEvent extends NetworkInfoEvent {}

// States
class NetworkInfoState {
  NetworkInfoState({required this.isConnected});
  final bool isConnected;
}

// Bloc
class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  NetworkInfoBloc(this.networkInfoService)
      : super(NetworkInfoState(isConnected: false)) {
    on<CheckConnectionEvent>(_onCheckConnectionEvent);
  }
  final NetworkInfoService networkInfoService;

  void _onCheckConnectionEvent(event, emit) async {
    final isConnected = await networkInfoService.isConnected;
    emit(NetworkInfoState(isConnected: isConnected));
  }
}
