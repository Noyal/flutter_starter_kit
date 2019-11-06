import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:starter_kit/extensions/serializer_extension.dart';
import 'package:starter_kit/models/api/http_client_model.dart';
import 'package:starter_kit/models/enums/http_client_status_code.dart';
import 'package:starter_kit/models/maps/http_map.dart';

class HttpClient {
  Dio dio = Dio(BaseOptions(
    contentType: ContentType.json,
    connectTimeout: 10000,
    receiveTimeout: 10000,
  ));
  List<HttpClientStatusCode> get _success => [
        HttpClientStatusCode.OK,
        HttpClientStatusCode.CREATED,
        HttpClientStatusCode.NO_CONTENT
      ];

  Future<HttpClientModel<T>> get<T>(String url) => _baseGet(url);

  Future<HttpClientModel<T>> getAll<T>(String url) =>
      _baseGet(url, isArray: true);

  Future<HttpClientModel<T>> _baseGet<T>(String url,
      {bool isArray = false}) async {
    HttpClientModel<T> responseModel;
    try {
      Response response = await dio.get(url);
      responseModel =
          await _buildClientModel<T>(response, responseModel, isArray);
    } on DioError catch (e) {
      responseModel = onGetError(e);
    }
    return responseModel;
  }

  Future<HttpClientModel> _buildClientModel<T>(
      Response response, HttpClientModel responseModel, bool isArray) async {
    if (_success.contains(httpErrorVal[response.statusCode])) {
      responseModel = HttpClientModel<T>(
          error: HttpClientStatusCode.NONE,
          model: await compute<String, T>(
              (responseData) => _parseJson<T>(responseData, isArray: isArray),
              response.data));
    } else {
      responseModel = HttpClientModel(
        error: httpErrorVal[response?.statusCode] ?? HttpClientStatusCode.ERROR,
      );
    }
    return responseModel;
  }

  T _parseJson<T>(String data, {bool isArray}) {
    return isArray ? fromJsonArrayString<T>(data) : fromJsonString<T>(data);
  }

  Future<HttpClientStatusCode> post<T>(T data, String url) async {
    try {
      Response response = await dio.post(url, data: data);
      if (_success.contains(httpErrorVal[response.statusCode]))
        return httpErrorVal[response.statusCode];
      else
        throw DioError();
    } on DioError catch (e) {
      return onError(e);
    }
  }

  Future<HttpClientStatusCode> put<T>(T data, String url) async {
    try {
      Response response = await dio.put(url, data: data);
      if (_success.contains(httpErrorVal[response.statusCode]))
        return httpErrorVal[response.statusCode];
      else
        throw DioError();
    } on DioError catch (e) {
      return onError(e);
    }
  }

  Future<HttpClientStatusCode> delete<T>(T data, String url) async {
    try {
      Response response = await dio.delete(url, data: data);
      if (_success.contains(httpErrorVal[response.statusCode]))
        return httpErrorVal[response.statusCode];
      else
        throw DioError();
    } on DioError catch (e) {
      return onError(e);
    }
  }

  HttpClientModel onGetError(DioError e) => HttpClientModel(error: onError(e));

  FutureOr<HttpClientStatusCode> onError(DioError e) async {
    if (e.error.runtimeType == HttpException) return await _checkConnectivity();
    if (e.error.runtimeType == SocketException)
      return HttpClientStatusCode.NO_INTERNET;
    if (e.type == DioErrorType.RECEIVE_TIMEOUT)
      return HttpClientStatusCode.SLOW_SERVER;
    if (e.type == DioErrorType.CONNECT_TIMEOUT)
      return HttpClientStatusCode.SLOW_INTERNET;
    return httpErrorVal[e.response?.statusCode] ?? HttpClientStatusCode.ERROR;
  }

  Future<HttpClientStatusCode> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.none
        ? HttpClientStatusCode.NO_INTERNET
        : HttpClientStatusCode.ERROR;
  }
}
