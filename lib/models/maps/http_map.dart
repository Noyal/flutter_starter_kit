import 'package:starter_kit/models/enums/http_enum.dart';

Map<int, HttpError> httpErrorVal = {
  0: HttpError.NO_INTERNET,
  1: HttpError.ERROR,
  200: HttpError.NONE,
  201: HttpError.NONE,
  204: HttpError.NONE,
  400: HttpError.BAD_REQUEST,
  401: HttpError.FORBIDDEN,
  403: HttpError.FORBIDDEN,
  404: HttpError.PAGE_NOT_FOUND,
  500: HttpError.SERVER_ERROR
};