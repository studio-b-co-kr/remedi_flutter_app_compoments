part of 'remedi_restful_api.dart';

class HttpError {
  final int statusCode;
  final String message;
  final dynamic data;
  final StackTrace? stackTrace;

  HttpError._({
    required this.statusCode,
    required this.message,
    this.data,
    this.stackTrace,
  });

  factory HttpError.fromDioError(DioException error) {
    if (error.response != null) {
      return HttpError._(
          statusCode: error.response?.statusCode ?? 0,
          message: error.response?.statusMessage ?? "",
          data: error.response?.data);
    }

    return HttpError._(
      statusCode: 0,
      message: '${error.message}',
      data: error.error,
      stackTrace: error.stackTrace,
    );
  }

  factory HttpError.create({
    required int statusCode,
    String message = '',
    dynamic data,
    StackTrace? stackTrace,
  }) {
    return HttpError._(
      statusCode: statusCode,
      message: message,
      data: data,
      stackTrace: stackTrace,
    );
  }
}
