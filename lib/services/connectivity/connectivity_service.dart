import 'dart:async';
import 'package:connectivity/connectivity.dart' as connectivity;
import 'package:starter_kit/services/connectivity/base_connectivity_service.dart';
import 'package:starter_kit/services/connectivity/connectivity_state.dart';

class ConnectivityService implements BaseConnectivityService {
  Stream<ConnectivityState> _onConnectivityChanged;
  connectivity.Connectivity _connectivity;

  ConnectivityService() {
    _connectivity = connectivity.Connectivity();
  }

  @override
  Future<ConnectivityState> checkConnectivity() async {
    var result = await _connectivity.checkConnectivity();
    return _parseConnectivityResultEnum(result);
  }

  @override
  Stream<ConnectivityState> get onConnectivityChanged {
    if (_onConnectivityChanged == null) {
      _onConnectivityChanged = _connectivity.onConnectivityChanged.asBroadcastStream()
          .map((dynamic event) => _parseConnectivityResultEnum(event));
    }
    return _onConnectivityChanged;
  }

  ConnectivityState _parseConnectivityResultEnum(
      connectivity.ConnectivityResult state) {
    switch (state) {
      case connectivity.ConnectivityResult.wifi:
        return ConnectivityState.online;
      case connectivity.ConnectivityResult.mobile:
        return ConnectivityState.online;
      case connectivity.ConnectivityResult.none:
      default:
        return ConnectivityState.offline;
    }
  }
}
