import 'package:starter_kit/models/enums/http_enum.dart';

class HttpClientModel<T> {
  T model;
  HttpError error;

  HttpClientModel({this.model, this.error});
}
