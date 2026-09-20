// core/network/dio_client.dart — заменить целиком
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import '../widgets/app_snackbar.dart';
import 'api_exception.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class DioClient {
  final Dio dio;
  final TokenStorage _tokenStorage;

  DioClient(this._tokenStorage)
      : dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('DIO ERROR: type=${error.type} message=${error.message} url=${error.requestOptions.uri}');
        }

        if (error.response?.statusCode == 401) {
          await _tokenStorage.clear();
          AppSnackbar.showError('Сессия истекла, войдите снова');

          final navigator = rootNavigatorKey.currentState;
          if (navigator != null) {
            navigator.pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }

        final message = error.response?.data is Map
            ? (error.response?.data['error'] ?? 'Unexpected error')
            : _fallbackMessage(error);

        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: ApiException(message.toString(), statusCode: error.response?.statusCode),
        ));
      },
    ));
  }

  String _fallbackMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Сервер не отвечает, попробуйте позже';
      case DioExceptionType.connectionError:
        return 'Нет соединения с сервером';
      default:
        return 'Что-то пошло не так';
    }
  }
}