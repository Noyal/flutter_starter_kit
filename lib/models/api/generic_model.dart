import 'package:starter_kit/models/enums/http_enum.dart';

class GenericModel<T> {
  T model;
  HttpError error;

  GenericModel({this.model, this.error});
}
