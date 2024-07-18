part of 'remedi_restful_api.dart';

class DioBuilder {
  static const multipartContentType = 'multipart/form-data; charset=utf-8';
  final String baseUrl;
  final String contentType;
  int connectTimeout;
  Map<String, dynamic>? extraHeaders;
  bool enableLogging;
  List<Interceptor>? interceptors;
  late final Dio dio;

  DioBuilder._({
    required this.baseUrl,
    required this.contentType,
    this.connectTimeout = 15000,
    this.extraHeaders,
    this.enableLogging = false,
    this.interceptors,
  }) {
    dio = _build();
  }

  Dio _build() {
    Dio dio = Dio();

    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    dio.options.contentType = contentType;

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

    dio.options.headers.addAll({'Accept': contentType});
    if (extraHeaders?.isNotEmpty ?? false) {
      dio.options.headers.addAll(extraHeaders!);
    }

    dio.transformer = FlutterTransformer();

    return dio;
  }

  factory DioBuilder.json({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? extraHeaders,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      extraHeaders: extraHeaders,
      contentType: Headers.jsonContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
    );
  }

  factory DioBuilder.fromUrl({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? extraHeaders,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      extraHeaders: extraHeaders,
      contentType: Headers.formUrlEncodedContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
    );
  }

  factory DioBuilder.textPain({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? extraHeaders,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      extraHeaders: extraHeaders,
      contentType: Headers.textPlainContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
    );
  }

  factory DioBuilder.multiPart({
    required String baseUrl,
    int connectTimeout = 15000,
    Map<String, dynamic>? extraHeaders,
    bool enableLogging = false,
    List<Interceptor>? interceptors,
  }) {
    return DioBuilder._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      extraHeaders: extraHeaders,
      contentType: multipartContentType,
      enableLogging: enableLogging,
      interceptors: interceptors,
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
