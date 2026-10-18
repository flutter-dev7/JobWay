import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/chat_message_model.dart';
import '../models/paged_chat_messages_model.dart';
import '../models/paged_chat_threads_model.dart';

class ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSource(this._dio);

  Future<PagedChatThreadsModel> getMyThreads({
    required bool unreadOnly,
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _dio.get(
      ApiConstants.chatThreads,
      queryParameters: {
        if (unreadOnly) 'unreadOnly': true,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    return PagedChatThreadsModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<PagedChatMessagesModel> getMessages(
    String jobApplicationId, {
    DateTime? since,
    DateTime? before,
  }) async {
    final response = await _dio.get(
      ApiConstants.chatMessages(jobApplicationId),
      queryParameters: {
        if (since != null) 'since': since.toUtc().toIso8601String(),
        if (before != null) 'before': before.toUtc().toIso8601String(),
      },
    );
    return PagedChatMessagesModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<ChatMessageModel> sendMessage(String jobApplicationId, String text) async {
    final response = await _dio.post(
      ApiConstants.chatMessages(jobApplicationId),
      data: {'text': text},
    );
    return ChatMessageModel.fromJson(response.data);
  }
}