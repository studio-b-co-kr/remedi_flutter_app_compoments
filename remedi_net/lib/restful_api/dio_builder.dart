part of 'remedi_restful_api.dart';

/// This class build a Dio using build() method
/// This class build some env. to requesting [headers], [contentType], [connectTimeout], [baseUrl] and [enableLogging]
class DioBuilder {
  final String baseUrl;
  final String contentType;
  int connectTimeout;
  Map<String, dynamic>? headers;
  bool enableLogging;
  List<Interceptor>? interceptors;
  HttpClientAdapter? testClientAdapter;
  late final Dio dio;

  DioBuilder._({
    required this.baseUrl,
    required this.contentType,
    this.connectTimeout = 15000,
    this.headers,
    this.enableLogging = false,
    this.interceptors,
    this.testClientAdapter,
  }) {
    dio = _build();
  }

  Dio _build() {
    // dio.options.baseUrl = baseUrl;
    // dio.options.connectTimeout = connectTimeout;
    // dio.options.contentType = contentType;
    // if (headers?.isNotEmpty ?? false) {
    //   dio.options.headers.addAll(headers!);
    // }

    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      contentType: contentType,
      headers: headers,
    ));

    if (testClientAdapter != null) {
      dio.httpClientAdapter = testClientAdapter!;
    }

    dio.interceptors.add(LogInterceptor(
      request: enableLogging,
      requestBody: enableLogging,
      requestHeader: enableLogging,
      responseBody: enableLogging,
      responseHeader: enableLogging,
      error: enableLogging,
    ));

    if (interceptors?.isNotEmpty ?? false) {
      dio.interceptors.addAll(interceptors!);
    }

    dio.transformer = FlutterTransformer();

    return dio;
  }

  factory DioBuilder.json({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? headers,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
    HttpClientAdapter? testClientAdapter,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      headers: headers,
      contentType: Headers.jsonContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
      testClientAdapter: testClientAdapter,
    );
  }

  factory DioBuilder.fromUrl({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? headers,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
    HttpClientAdapter? testClientAdapter,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      headers: headers,
      contentType: Headers.formUrlEncodedContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
      testClientAdapter: testClientAdapter,
    );
  }

  factory DioBuilder.textPain({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? headers,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
    HttpClientAdapter? testClientAdapter,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      headers: headers,
      contentType: Headers.textPlainContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
      testClientAdapter: testClientAdapter,
    );
  }
}

class FlutterTransformer extends DefaultTransformer {
  FlutterTransformer() : super(jsonDecodeCallback: _parseJson);
}

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

_parseJson(String text) {
  return compute(_parseAndDecode, text);
}
