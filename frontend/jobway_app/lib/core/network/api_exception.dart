import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  static String extractMessage(Object error) {
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'Что-то пошло не так, попробуйте снова';
  }

  @override
  String toString() => message;
}