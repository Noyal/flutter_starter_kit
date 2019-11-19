import 'dart:async';

import 'package:starter_kit/services/connectivity/connectivity_state.dart';

abstract class BaseConnectivityService {
  Stream<ConnectivityState> get onConnectivityChanged;
  Future<ConnectivityState> checkConnectivity();
}
