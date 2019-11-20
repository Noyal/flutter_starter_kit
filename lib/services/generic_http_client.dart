import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:starter_kit/extensions/serializer_extension.dart';
import 'package:starter_kit/models/api/http_client_model.dart';
import 'package:starter_kit/models/enums/http_client_status_code.dart';
import 'package:starter_kit/models/maps/http_map.dart';
import 'package:starter_kit/services/connectivity/base_connectivity_service.dart';
import 'package:starter_kit/services/connectivity/connectivity_service.dart';

class HttpClient {
  Dio dio;
  List<HttpClientStatusCode> get _success => [
        HttpClientStatusCode.OK,
        HttpClientStatusCode.CREATED,
        HttpClientStatusCode.NO_CONTENT
      ];
  BaseConnectivityService connectivityService;
  HttpClient({BaseConnectivityService connectivityService})
      : this.connectivityService =
            connectivityService ?? ConnectivityService() {
    dio = Dio(BaseOptions(
      contentType: ContentType.json,
      connectTimeout: 10000,
      receiveTimeout: 10000,
    ));
  }

  Future<HttpClientStatusCode> _checkConnectivity() async {
    HttpClientStatusCode clientStatusCode;
    try {
      var hasConnection = await connectivityService.hasConnection;
      clientStatusCode = hasConnection
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
      {@required Future<Response> dioHttpAction(),
      bool isArray = false}) async {
    HttpClientModel<T> _responseModel;
    try {
      var response = await dioHttpAction();
      if (_success.contains(httpErrorVal[response.statusCode])) {
        _responseModel = HttpClientModel<T>(
            error: HttpClientStatusCode.NONE,
            model: await compute<String, T>(
                (responseData) => _parseJson<T>(responseData, isArray: isArray),
                response.data));
      } else {
        _responseModel = HttpClientModel(
          error:
              httpErrorVal[response?.statusCode] ?? HttpClientStatusCode.ERROR,
        );
      }
    } on DioError catch (e) {
      _responseModel = _onGetError(e);
    } catch (e) {
      _responseModel = HttpClientModel(error: HttpClientStatusCode.ERROR);
    }
    return _responseModel;
  }

  Future<HttpClientModel<T>> _baseGet<T>(String url,
      {bool isArray = false}) async {
    return _buildClientModel<T>(
        dioHttpAction: () {
          return dio.get(url);
        },
        isArray: isArray);
  }

  Future<HttpClientModel<T>> get<T>(String url) => _baseGet(url);

  Future<HttpClientModel<T>> getAll<T>(String url) =>
      _baseGet(url, isArray: true);

  Future<HttpClientModel<T>> post<T>(T data, String url,
      {bool isArray = false}) {
    return _buildClientModel<T>(
        dioHttpAction: () {
          return dio.post(url, data: data);
        },
        isArray: isArray);
  }

  Future<HttpClientModel<T>> put<T>(T data, String url,
      {bool isArray = false}) {
    return _buildClientModel<T>(
        dioHttpAction: () {
          return dio.put(url, data: data);
        },
        isArray: isArray);
  }

  Future<HttpClientModel<T>> delete<T>(T data, String url,
      {bool isArray = false}) {
    return _buildClientModel<T>(
        dioHttpAction: () {
          return dio.delete(url, data: data);
        },
        isArray: isArray);
  }
}
