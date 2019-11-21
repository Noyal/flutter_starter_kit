import 'dart:async';

import 'package:starter_kit/models/api/http_client_model.dart';

abstract class BaseHttpClient {
  Future<HttpClientModel<T>> get<T>(String url);

  Future<HttpClientModel<T>> getAll<T>(String url);

  Future<HttpClientModel<T>> post<T>(T data, String url,
      {bool isArray = false});

  Future<HttpClientModel<T>> put<T>(T data, String url, {bool isArray = false});

  Future<HttpClientModel<T>> delete<T>(T data, String url,
      {bool isArray = false});
}
