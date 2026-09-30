import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';

class ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSource(this._dio);

  Future<List<ChatThreadModel>> getMyThreads() async {
    final response = await _dio.get(ApiConstants.chatThreads);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((t) => ChatThreadModel.fromJson(t)).toList();
  }

  Future<List<ChatMessageModel>> getMessages(String jobApplicationId, {DateTime? since}) async {
    final response = await _dio.get(
      ApiConstants.chatMessages(jobApplicationId),
      queryParameters: since != null ? {'since': since.toUtc().toIso8601String()} : null,
    );
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((m) => ChatMessageModel.fromJson(m)).toList();
  }

  Future<ChatMessageModel> sendMessage(String jobApplicationId, String text) async {
    final response = await _dio.post(
      ApiConstants.chatMessages(jobApplicationId),
      data: {'text': text},
    );
    return ChatMessageModel.fromJson(response.data);
  }
}