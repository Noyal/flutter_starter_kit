import 'package:flutter/material.dart';
import 'package:starter_kit/services/connectivity/connectivity_service.dart';
import 'package:starter_kit/services/connectivity/connectivity_state.dart';

class ConnectivityScaffold extends StatefulWidget {
  final AppBar appBar;
  final Widget child;
  final BottomNavigationBar bottomNavigationBar;

  ConnectivityScaffold({this.appBar, this.child, this.bottomNavigationBar});

  @override
  _ConnectivityScaffoldState createState() => _ConnectivityScaffoldState();
}

class _ConnectivityScaffoldState extends State<ConnectivityScaffold> {
  ConnectivityService _connectivity;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _connectivity = ConnectivityService();
    _connectivity.checkConnectivity().then((onData) {
      if (onData == ConnectivityState.offline) _popSnackBar(onData);
    });
    _connectivity.onConnectivityChanged.listen((onData) {
      _popSnackBar(onData);
    });
  }

  void _popSnackBar(ConnectivityState onData) {
    Color backgroundColor;
    Duration duration;
    String connectionStatus;
    if (mounted) {
      var isOffline = onData == ConnectivityState.offline;
      if (isOffline) {
        connectionStatus = 'offline';
        duration = Duration(days: 2);
        backgroundColor = Colors.redAccent;
      } else {
        connectionStatus = 'online';
        duration = Duration(seconds: 2);
        backgroundColor = Colors.green;
      }
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          'Network is $connectionStatus',
          style: TextStyle(color: Colors.white),
        ),
        duration: duration,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.appBar,
      body: widget.child,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
