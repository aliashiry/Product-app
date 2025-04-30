import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';

class DioClient {
  final Dio _dio;

  DioClient._internal(this._dio);

  static final DioClient _instance = DioClient._internal(_createDio());

  static DioClient get instance => _instance;

  Dio get dio => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggerInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    return handler.next(options);
  }
}

class _LoggerInterceptor extends Interceptor {
  final PrettyDioLogger _logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.onError(err, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = DeadlineExceededException(err.requestOptions);
        break;
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            err = BadRequestException(err.requestOptions, err.response);
            break;
          case 401:
            err = UnauthorizedException(err.requestOptions, err.response);
            break;
          case 403:
            err = ForbiddenException(err.requestOptions, err.response);
            break;
          case 404:
            err = NotFoundException(err.requestOptions, err.response);
            break;
          case 409:
            err = ConflictException(err.requestOptions, err.response);
            break;
          case 500:
            err = InternalServerErrorException(err.requestOptions, err.response);
            break;
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        err = NoInternetConnectionException(err.requestOptions, err.response);
        break;
      case DioExceptionType.badCertificate:
        err = BadCertificateException(err.requestOptions, err.response);
        break;
      case DioExceptionType.connectionError:
        err = ConnectionErrorException(err.requestOptions, err.response);
        break;
    }
    return handler.next(err);
  }
}

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Server error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'The requested resource was not found';
  }
}

class ForbiddenException extends DioException {
  ForbiddenException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Access to this resource is forbidden';
  }
}

class DeadlineExceededException extends DioException {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class BadCertificateException extends DioException {
  BadCertificateException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Bad certificate';
  }
}

class ConnectionErrorException extends DioException {
  ConnectionErrorException(RequestOptions r, Response? response)
      : super(requestOptions: r, response: response);

  @override
  String toString() {
    return 'Connection error';
  }
}