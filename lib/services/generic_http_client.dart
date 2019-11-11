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
  Dio dio;
  List<HttpClientStatusCode> get _success => [
        HttpClientStatusCode.OK,
        HttpClientStatusCode.CREATED,
        HttpClientStatusCode.NO_CONTENT
      ];

  HttpClient() {
    dio = Dio(BaseOptions(
      contentType: ContentType.json,
      connectTimeout: 10000,
      receiveTimeout: 10000,
    ));
    dio.interceptors.add(InterceptorsWrapper(onResponse: (Response response) {
      return response;
    }, onError: (DioError e) async {
      return _onGetError(e);
    }));
  }

  Future<HttpClientStatusCode> _checkConnectivity() async {
    HttpClientStatusCode clientStatusCode;
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      clientStatusCode = connectivityResult == ConnectivityResult.none
          ? HttpClientStatusCode.NO_INTERNET
          : HttpClientStatusCode.ERROR;
    } catch (e) {
      clientStatusCode = HttpClientStatusCode.ERROR;
    }
    return clientStatusCode;
  }

  FutureOr<HttpClientModel> _onGetError(DioError e) async {
    HttpClientStatusCode errorCode;
    if (e.error.runtimeType == HttpException)
      errorCode = await _checkConnectivity();
    if (e.error.runtimeType == SocketException)
      errorCode = HttpClientStatusCode.NO_INTERNET;
    if (e.type == DioErrorType.RECEIVE_TIMEOUT)
      errorCode = HttpClientStatusCode.SLOW_SERVER;
    if (e.type == DioErrorType.CONNECT_TIMEOUT)
      errorCode = HttpClientStatusCode.SLOW_INTERNET;
    errorCode =
        httpErrorVal[e.response?.statusCode] ?? HttpClientStatusCode.ERROR;
    return HttpClientModel(error: errorCode);
  }

  T _parseJson<T>(String data, {bool isArray}) {
    return isArray ? fromJsonArrayString<T>(data) : fromJsonString<T>(data);
  }

  Future<HttpClientModel> _buildClientModel<T>(
      Response response, HttpClientModel responseModel, bool isArray) async {
    try {
      if (_success.contains(httpErrorVal[response.statusCode])) {
        responseModel = HttpClientModel<T>(
            error: HttpClientStatusCode.NONE,
            model: await compute<String, T>(
                (responseData) => _parseJson<T>(responseData, isArray: isArray),
                response.data));
      } else {
        responseModel = HttpClientModel(
          error:
              httpErrorVal[response?.statusCode] ?? HttpClientStatusCode.ERROR,
        );
      }
    } catch (e) {
      responseModel = HttpClientModel(error: HttpClientStatusCode.ERROR);
    }
    return responseModel;
  }

  Future<HttpClientModel<T>> _baseGet<T>(String url,
      {bool isArray = false}) async {
    HttpClientModel<T> _responseModel;
    Response response = await dio.get(url);
    _responseModel =
        await _buildClientModel<T>(response, _responseModel, isArray);
    return _responseModel;
  }

  Future<HttpClientModel<T>> get<T>(String url) => _baseGet(url);

  Future<HttpClientModel<T>> getAll<T>(String url) =>
      _baseGet(url, isArray: true);

  Future<HttpClientModel<T>> post<T>(T data, String url,
      {bool isArray = false}) async {
    HttpClientModel<T> _responseModel;
    Response response = await dio.post(url, data: data);
    _responseModel =
        await _buildClientModel<T>(response, _responseModel, isArray);
    return _responseModel;
  }

  Future<HttpClientModel<T>> put<T>(T data, String url,
      {bool isArray = false}) async {
    HttpClientModel<T> _responseModel;
    Response response = await dio.put(url, data: data);
    _responseModel =
        await _buildClientModel<T>(response, _responseModel, isArray);
    return _responseModel;
  }

  Future<HttpClientModel<T>> delete<T>(T data, String url,
      {bool isArray = false}) async {
    HttpClientModel<T> _responseModel;
    Response response = await dio.delete(url, data: data);
    _responseModel =
        await _buildClientModel<T>(response, _responseModel, isArray);
    return _responseModel;
  }
}
