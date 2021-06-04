import 'package:dio/dio.dart';
import 'package:pt_object_mapper/pt_object_mapper.dart';
import 'package:rxdart/rxdart.dart';

import 'base_api_input.dart';
import 'base_api_output.dart';

class BaseAPIService {
  /// Create variables
  final Dio _dio = new Dio();
  bool debug = false;

  BaseAPIService();

  BaseAPIInput preprocess(BaseAPIInput input) {
    return input;
  }

  Stream<bool> precheck(BaseAPIInput input) {
    return Stream.value(true);
  }

  void handleResponseError(DioError error) {}

  void log(Object object) {
    print(object.toString());
  }

  Stream<T> request<T extends BaseAPIOutput>(BaseAPIInput input) {
    return precheck(input)
        .where((isPass) => isPass)
        .switchMap((_) => Stream.fromFuture(_request(input)));
  }

  Future<T> _request<T extends BaseAPIOutput>(BaseAPIInput input) async {
    Response dioResponse;
    var _input = preprocess(input);
    log("🌍 [${_input.httpMethod}] ${_input.urlString}");
    if (debug) {
      if (_input.params?.isNotEmpty ?? false) {
        log("🌍 ${_input.urlString} PARAMS:");
        log(_input.params);
      }
      if (_input.bodyParams?.isNotEmpty ?? false) {
        log("🌍 ${_input.urlString} BODY PARAMS:");
        log(_input.bodyParams);
      }
    }
    try {
      switch (_input.httpMethod) {
        case HttpMethod.get:
          dioResponse = await _dio.get(
            _input.urlString,
            queryParameters: _input.params,
            options: Options(
              headers: _input.headers,
            ),
          );
          break;
        case HttpMethod.post:
          dioResponse = await _dio.post(
            _input.urlString,
            queryParameters: _input.params,
            data: _input.bodyParams,
            options: Options(
              headers: _input.headers,
            ),
          );
          break;
        case HttpMethod.put:
          dioResponse = await _dio.put(
            _input.urlString,
            queryParameters: _input.params,
            data: _input.bodyParams,
            options: Options(
              headers: _input.headers,
            ),
          );
          break;
        case HttpMethod.delete:
          dioResponse = await _dio.delete(
            _input.urlString,
            queryParameters: _input.params,
            data: _input.bodyParams,
            options: Options(
              headers: _input.headers,
            ),
          );
          break;
      }
      log("👍 [${dioResponse.statusCode}] ${_input.urlString}");
      if (debug) {
        log(dioResponse.data);
      }
      return Mapper.fromJson(dioResponse.data).toObject<T>();
    } on DioError catch (error) {
      log("❌ [${error.message}] ${_input.urlString}");
      if (debug) {
        log(error.response);
      }
      handleResponseError(error);
      return Future.error(error);
    } on Exception catch (error) {
      log("❌ [$error] ${_input.urlString}");
      if (debug) {
        log(error);
      }
      handleResponseError(DioError(error: -1));
      return Future.error(error);
    }
  }
}
