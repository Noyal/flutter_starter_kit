import 'package:flutter/material.dart';
import 'package:starter_kit/http/http_typedefs.dart';

class HttpPageWidget<T> extends StatefulWidget {
  final ApiAction<T> apiAction;
  final HttpResponseBuilder<T> builder;
  final Widget child;
  HttpPageWidget({this.apiAction, this.builder, this.child});
  @override
  _HttpPageWidgetState createState() => _HttpPageWidgetState();
}

class _HttpPageWidgetState extends State<HttpPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
