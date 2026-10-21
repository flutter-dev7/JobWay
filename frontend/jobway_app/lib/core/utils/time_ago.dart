class TimeAgo {
  static String format(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    if (diff.inDays < 7) return '${diff.inDays} д назад';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} нед назад';
    return '${(diff.inDays / 30).floor()} мес назад';
  }

  // Обычная дата ДД.ММ.ГГГГ (для сроков тарифа и продвижения, то есть для будущих дат)
  static String formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day.$month.${local.year}';
  }
}