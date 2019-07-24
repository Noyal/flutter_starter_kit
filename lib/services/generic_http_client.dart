import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:starter_kit/models/maps/http_map.dart';

class HttpClient {
  Dio dio = Dio(BaseOptions(
    contentType: ContentType.json,
    connectTimeout: 10000,
    receiveTimeout: 20000,
  ));

  Future<GenericModel<T>> getData<T>(
      String url, Function convertCallback) async {
    try {
      Response response = await dio.get(url);
      if (httpErrorVal[response.statusCode] == HttpError.NONE)
        return GenericModel<T>(
          error: HttpError.NONE,
          model: convertCallback(response.data),
        );
      return GenericModel(
          error: httpErrorVal[response.statusCode] ?? HttpError.ERROR);
    } on DioError catch (e) {
      if (e.error.runtimeType == SocketException) {
        return GenericModel(error: HttpError.NO_INTERNET);
      } else if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        return GenericModel(error: HttpError.SLOW_INTERNET);
      } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
        return GenericModel(error: HttpError.SLOW_SERVER);
      } else if (e.error.runtimeType == HttpException) {
        return getData(url, convertCallback);
      } else if (e.response != null) {
        return GenericModel(error: httpErrorVal[e.response.statusCode]);
      } else {
        return GenericModel(error: HttpError.ERROR);
      }
    }
  }

  Future<HttpError> postData(Map data, String url) async {
    int statusCode;
    try {
      Response response = await dio.post(url, data: data);
      statusCode = response.statusCode;
      if (httpErrorVal[statusCode] == HttpError.NONE)
        return httpErrorVal[response.statusCode];
      else
        throw Exception();
    } on DioError catch (e) {
      if (e.error.runtimeType == SocketException) return HttpError.NO_INTERNET;
      if (e.error.runtimeType == HttpException) return postData(data, url);
      if (e.type == DioErrorType.RECEIVE_TIMEOUT) return HttpError.SLOW_SERVER;
      if (e.type == DioErrorType.CONNECT_TIMEOUT)
        return HttpError.SLOW_INTERNET;
      return e.response != null
          ? httpErrorVal[e.response.statusCode]
          : HttpError.ERROR;
    }
  }

  Future<HttpError> putData(Map data, String url) async {
    int statusCode;
    try {
      Response response = await dio.put(url, data: data);
      statusCode = response.statusCode;
      if (httpErrorVal[statusCode] == HttpError.NONE)
        return httpErrorVal[response.statusCode];
      else
        throw Exception();
    } on DioError catch (e) {
      if (e.error.runtimeType == SocketException) return HttpError.NO_INTERNET;
      if (e.error.runtimeType == HttpException) return putData(data, url);
      if (e.type == DioErrorType.RECEIVE_TIMEOUT) return HttpError.SLOW_SERVER;
      if (e.type == DioErrorType.CONNECT_TIMEOUT)
        return HttpError.SLOW_INTERNET;
      return e.response != null
          ? httpErrorVal[e.response.statusCode]
          : HttpError.ERROR;
    }
  }

  Future<HttpError> deleteData(Map data, String url) async {
    int statusCode;
    try {
      Response response = await dio.delete(url, data: data);
      statusCode = response.statusCode;
      if (httpErrorVal[statusCode] == HttpError.NONE)
        return httpErrorVal[response.statusCode];
      else
        throw Exception();
    } on DioError catch (e) {
      if (e.error.runtimeType == SocketException) return HttpError.NO_INTERNET;
      if (e.error.runtimeType == HttpException) return deleteData(data, url);
      if (e.type == DioErrorType.RECEIVE_TIMEOUT) return HttpError.SLOW_SERVER;
      if (e.type == DioErrorType.CONNECT_TIMEOUT)
        return HttpError.SLOW_INTERNET;
      return e.response != null
          ? httpErrorVal[e.response.statusCode]
          : HttpError.ERROR;
    }
  }
}
