import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import '../widgets/app_snackbar.dart';
import 'api_exception.dart';
import 'api_response.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class DioClient {
  final Dio dio;
  final TokenStorage _tokenStorage;

  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshWaiters = [];

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

        final isUnauthorized = error.response?.statusCode == 401;
        final isRefreshCall = error.requestOptions.path == ApiConstants.refreshToken;

        if (isUnauthorized && !isRefreshCall) {
          final refreshed = await _refreshAccessToken();

          if (refreshed) {
            try {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              // повтор тоже упал — падаем ниже в разлогин
            }
          }

          await _tokenStorage.clear();
          AppSnackbar.showError('Сессия истекла, войдите снова');
          rootNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
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

  Future<bool> _refreshAccessToken() async {
    // если обновление уже идёт (несколько запросов упали с 401 одновременно) — просто ждём его результата
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshWaiters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    var success = false;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      // отдельный Dio без interceptor-ов, чтобы не зациклиться на 401
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await refreshDio.post(ApiConstants.refreshToken, data: {'refreshToken': refreshToken});
      final data = ApiResponse.unwrap(response.data);

      await _tokenStorage.saveTokens(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
      success = true;
    } catch (_) {
      success = false;
    } finally {
      _isRefreshing = false;
      for (final waiter in _refreshWaiters) {
        waiter.complete(success);
      }
      _refreshWaiters.clear();
    }

    return success;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _tokenStorage.getAccessToken();
    requestOptions.headers['Authorization'] = 'Bearer $token';
    return dio.fetch(requestOptions);
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