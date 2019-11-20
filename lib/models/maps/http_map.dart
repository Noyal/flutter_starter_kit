import 'package:starter_kit/models/enums/http_client_status_code.dart';

Map<int, HttpClientStatusCode> httpErrorVal = {
  0: HttpClientStatusCode.NO_INTERNET,
  1: HttpClientStatusCode.ERROR,
  200: HttpClientStatusCode.OK,
  201: HttpClientStatusCode.CREATED,
  204: HttpClientStatusCode.NO_CONTENT,
  400: HttpClientStatusCode.BAD_REQUEST,
  401: HttpClientStatusCode.FORBIDDEN,
  403: HttpClientStatusCode.FORBIDDEN,
  404: HttpClientStatusCode.PAGE_NOT_FOUND,
  500: HttpClientStatusCode.SERVER_ERROR
};
