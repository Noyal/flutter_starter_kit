import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart' as connectivity;
import 'package:starter_kit/services/connectivity/base_connectivity_service.dart';
import 'package:starter_kit/services/connectivity/connectivity_state.dart';

const int DEFAULT_PORT = 53;

/// Default timeout is 10 seconds.
///
/// Timeout is the number of seconds before a request is dropped
/// and an address is considered unreachable
const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);

/// Default interval is 2 seconds
///
/// Interval is the time between automatic checks
const Duration DEFAULT_INTERVAL = Duration(seconds: 2);

class ConnectivityService implements BaseConnectivityService {
  static final List<AddressCheckOptions> defaultAddresses = List.unmodifiable([
    AddressCheckOptions(
      InternetAddress('1.1.1.1'),
      port: DEFAULT_PORT,
      timeout: DEFAULT_TIMEOUT,
    ),
    AddressCheckOptions(
      InternetAddress('8.8.4.4'),
      port: DEFAULT_PORT,
      timeout: DEFAULT_TIMEOUT,
    ),
    AddressCheckOptions(
      InternetAddress('208.67.222.222'),
      port: DEFAULT_PORT,
      timeout: DEFAULT_TIMEOUT,
    ),
  ]);

  List<AddressCheckOptions> addresses = defaultAddresses;
  Stream<ConnectivityState> _onConnectivityChanged;
  connectivity.Connectivity _connectivity;

  ConnectivityService() {
    _connectivity = connectivity.Connectivity();
  }

  @override
  Future<ConnectivityState> checkConnectivityState() =>
      _getConnectivityStateAsync();

  @override
  Stream<ConnectivityState> get onConnectivityChanged {
    if (_onConnectivityChanged == null) {
      _onConnectivityChanged =
          _connectivity.onConnectivityChanged.asyncMap((dynamic event) async {
        return _getConnectivityStateAsync();
      });
    }
    return _onConnectivityChanged;
  }

  Future<ConnectivityState> _getConnectivityStateAsync() async {
    var connectionStatus = await hasConnection;
    return connectionStatus
        ? ConnectivityState.online
        : ConnectivityState.offline;
  }

  Future<AddressCheckResult> _isHostReachable(
    AddressCheckOptions options,
  ) async {
    Socket sock;
    try {
      sock = await Socket.connect(
        options.address,
        options.port,
        timeout: options.timeout,
      );
      sock?.destroy();
      return AddressCheckResult(options, true);
    } catch (e) {
      sock?.destroy();
      return AddressCheckResult(options, false);
    }
  }

  @override
  Future<bool> get hasConnection async {
    List<Future<AddressCheckResult>> requests = [];

    for (var addressOptions in addresses) {
      requests.add(_isHostReachable(addressOptions));
    }
    var _lastTryResults = List.unmodifiable(await Future.wait(requests));

    return _lastTryResults.map((result) => result.isSuccess).contains(true);
  }
}

class AddressCheckOptions {
  final InternetAddress address;
  final int port;
  final Duration timeout;

  AddressCheckOptions(
    this.address, {
    this.port = DEFAULT_PORT,
    this.timeout = DEFAULT_TIMEOUT,
  });

  @override
  String toString() => "AddressCheckOptions($address, $port, $timeout)";
}

class AddressCheckResult {
  final AddressCheckOptions options;
  final bool isSuccess;

  AddressCheckResult(
    this.options,
    this.isSuccess,
  );

  @override
  String toString() => "AddressCheckResult($options, $isSuccess)";
}
