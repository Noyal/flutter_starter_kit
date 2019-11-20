import 'package:flutter/material.dart';
import 'package:starter_kit/widgets/connectivity_scaffold.dart';

class SchoolDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityScaffold(
      appBar: AppBar(
        title: Text('School Details'),
      ),
      child: Center(
        child: Text('School Details'),
      ),
    );
  }
}
