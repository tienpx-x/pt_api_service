import 'package:pt_api_service/pt_api_service.dart';
import 'package:pt_object_mapper/pt_object_mapper.dart';

void main() async {
  Mappable.factories = {BaseAPIOutput: () => BaseAPIOutput()};
  var input = BaseAPIInput(
      httpMethod: HttpMethod.post,
      urlString: "http://api.plos.org/search?q=title:DNA");
  var apiService = BaseAPIService();
  apiService.debug = true;
  var stream = apiService.request(input);
  stream.listen((event) {
    print("Success ${event}");
  }, onError: (error) {
    print("Error");
  });
}
