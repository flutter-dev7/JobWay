import 'package:flutter/cupertino.dart';


Future<String?> showDeleteAccountDialog(BuildContext context) async {
  final passwordController = TextEditingController();

  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => CupertinoAlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              const Text(
                'Это действие нельзя отменить. Ваш профиль станет недоступен, активные вакансии будут закрыты.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: passwordController,
                obscureText: true,
                placeholder: 'Пароль',
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return null;
  return passwordController.text;
}