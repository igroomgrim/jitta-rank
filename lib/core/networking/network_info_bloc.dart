import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info_service.dart';

// Events
abstract class NetworkInfoEvent {}

class CheckConnectionEvent extends NetworkInfoEvent {}

// States
class NetworkInfoState extends Equatable {
  const NetworkInfoState({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

// Bloc
class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  NetworkInfoBloc(this.networkInfoService)
      : super(const NetworkInfoState(isConnected: false)) {
    on<CheckConnectionEvent>(_onCheckConnectionEvent);
  }
  final NetworkInfoService networkInfoService;

  Future<void> _onCheckConnectionEvent(
    CheckConnectionEvent event,
    Emitter<NetworkInfoState> emit,
  ) async {
    final isConnected = await networkInfoService.isConnected;
    emit(NetworkInfoState(isConnected: isConnected));
  }
}
