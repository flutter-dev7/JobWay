import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_back_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String jobApplicationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String vacancyTitle;
  final bool otherUserActive;

  const ChatPage({
    super.key,
    required this.jobApplicationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.vacancyTitle,
    this.otherUserActive = true,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  static const _pollInterval = Duration(seconds: 6);

  final _messages = <ChatMessage>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isMine(ChatMessage message) =>
      message.senderUserId != widget.otherUserId;

  Future<void> _loadInitial() async {
    try {
      final messages = await ref
          .read(getChatMessagesUseCaseProvider)
          .call(widget.jobApplicationId);
      if (!mounted) return;
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
      _scrollToBottom();
      ref.invalidate(chatThreadsProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = ApiException.extractMessage(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _poll() async {
    if (_messages.isEmpty) return;
    try {
      final since = _messages.last.createdAt;
      final newMessages = await ref
          .read(getChatMessagesUseCaseProvider)
          .call(widget.jobApplicationId, since: since);
      if (!mounted || newMessages.isEmpty) return;

      final existingIds = _messages.map((m) => m.id).toSet();
      final toAdd = newMessages
          .where((m) => !existingIds.contains(m.id))
          .toList();
      if (toAdd.isEmpty) return;

      setState(() => _messages.addAll(toAdd));
      _scrollToBottom();
    } catch (_) {
      // тихий фейл — просто следующий тик попробует снова
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final message = await ref
          .read(sendMessageUseCaseProvider)
          .call(widget.jobApplicationId, text);
      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _textController.clear();
      });
      _scrollToBottom();
      ref.invalidate(chatThreadsProvider);
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPhoto =
        widget.otherUserPhotoUrl != null &&
        widget.otherUserPhotoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60,
        leading: const AppBackButton(),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                shape: BoxShape.circle,
                image: hasPhoto
                    ? DecorationImage(
                        image: NetworkImage(
                          ApiConstants.resolveFileUrl(
                            widget.otherUserPhotoUrl!,
                          ),
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasPhoto
                  ? Center(
                      child: Text(
                        widget.otherUserName.trim().isNotEmpty
                            ? widget.otherUserName.trim()[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.accentColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.otherUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.vacancyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    )
                  : _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Начните переписку',
                        style: TextStyle(fontSize: 14, color: colors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _MessageBubble(
                          message: message,
                          isMine: _isMine(message),
                        );
                      },
                    ),
            ),
            if (!widget.otherUserActive)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Text(
                  'Собеседник удалил аккаунт — переписка недоступна',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              )
            else
              Container(
                padding: EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  MediaQuery.of(context).padding.bottom + 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Сообщение',
                          filled: true,
                          fillColor: colors.surfaceMuted,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isSending ? null : _send,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: _isSending
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? context.accentColor : colors.surface,
          border: isMine ? null : Border.all(color: colors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            color: isMine ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
