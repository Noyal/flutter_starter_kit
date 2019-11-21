import 'package:starter_kit/services/base_http_client.dart';
import 'package:starter_kit/services/generic_http_client.dart';

class SampleService {
  BaseHttpClient httpClient;
  SampleService({BaseHttpClient httpClient})
      : this.httpClient = httpClient ?? HttpClient();
  getData() {}
}
