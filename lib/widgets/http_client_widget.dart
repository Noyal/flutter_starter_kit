import 'dart:async';

import 'package:flutter/material.dart';

typedef Future<T> GetData<T>();

class HttpClientWidget<T> extends StatelessWidget {
  final GetData<T> onlineData;
  final GetData<T> offlineData;
  final Widget child;
  final Widget offlineWidget;
  final String title;
  final String subTitle;

  HttpClientWidget(
      {this.offlineData,
      this.onlineData,
      this.child,
      this.title,
      this.subTitle,
      this.offlineWidget});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
