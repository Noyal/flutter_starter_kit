import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:starter_kit/models/api/http_client_model.dart';
import 'package:starter_kit/models/enums/http_enum.dart';
import 'package:starter_kit/models/maps/http_map.dart';

class HttpClient {
  Dio dio = Dio(BaseOptions(
    contentType: ContentType.json,
    connectTimeout: 10000,
    receiveTimeout: 20000,
  ));

  Future<HttpClientModel<T>> get<T>(
      String url, Function convertCallback) async {
    try {
      Response response = await dio.get(url);
      if (httpErrorVal[response.statusCode] == HttpError.NONE)
        return HttpClientModel<T>(
          error: HttpError.NONE,
          model: convertCallback(response.data),
        );
      return HttpClientModel(
        error: httpErrorVal[response.statusCode] ?? HttpError.ERROR,
      );
    } on DioError catch (e) {
      if (e.error.runtimeType == HttpException)
        return get(url, convertCallback);
      return onGetError(e);
    }
  }

  Future<HttpClientModel<T>> getAll<T>(
      String url, Function convertCallback) async {
    try {
      Response response = await dio.get(url);
      if (httpErrorVal[response.statusCode] == HttpError.NONE)
        return HttpClientModel<T>(
          error: HttpError.NONE,
          model: convertCallback(response.data),
        );
      return HttpClientModel(
        error: httpErrorVal[response.statusCode] ?? HttpError.ERROR,
      );
    } on DioError catch (e) {
      if (e.error.runtimeType == HttpException)
        return get(url, convertCallback);
      return onGetError(e);
    }
  }

  Future<HttpError> post<T>(T data, String url) async {
    int statusCode;
    try {
      Response response = await dio.post(url, data: data);
      statusCode = response.statusCode;
      if (httpErrorVal[statusCode] == HttpError.NONE)
        return httpErrorVal[response.statusCode];
      else
        throw Exception();
    } on DioError catch (e) {
      if (e.error.runtimeType == HttpException) return post<T>(data, url);
      return onError(e);
    }
  }

  Future<HttpError> put<T>(T data, String url) async {
    int statusCode;
    try {
      Response response = await dio.put(url, data: data);
      statusCode = response.statusCode;
      if (httpErrorVal[statusCode] == HttpError.NONE)
        return httpErrorVal[response.statusCode];
      else
        throw Exception();
    } on DioError catch (e) {
      if (e.error.runtimeType == HttpException) return put<T>(data, url);
      return onError(e);
    }
  }

  Future<HttpError> delete<T>(T data, String url) async {
    int statusCode;
    try {
      Response response = await dio.delete(url, data: data);
      statusCode = response.statusCode;
      if (httpErrorVal[statusCode] == HttpError.NONE)
        return httpErrorVal[response.statusCode];
      else
        throw Exception();
    } on DioError catch (e) {
      if (e.error.runtimeType == HttpException) return delete<T>(data, url);
      return onError(e);
    }
  }

  HttpClientModel onGetError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT)
      return HttpClientModel(error: HttpError.SLOW_INTERNET);
    if (e.type == DioErrorType.RECEIVE_TIMEOUT)
      return HttpClientModel(error: HttpError.SLOW_SERVER);
    if (e.error.runtimeType == SocketException)
      return HttpClientModel(error: HttpError.NO_INTERNET);
    if (e.response != null)
      return HttpClientModel(error: httpErrorVal[e.response.statusCode]);
    else
      return HttpClientModel(error: HttpError.ERROR);
  }

  HttpError onError(DioError e) {
    if (e.error.runtimeType == SocketException) return HttpError.NO_INTERNET;
    if (e.type == DioErrorType.RECEIVE_TIMEOUT) return HttpError.SLOW_SERVER;
    if (e.type == DioErrorType.CONNECT_TIMEOUT) return HttpError.SLOW_INTERNET;
    return e.response != null
        ? httpErrorVal[e.response.statusCode]
        : HttpError.ERROR;
  }
}
