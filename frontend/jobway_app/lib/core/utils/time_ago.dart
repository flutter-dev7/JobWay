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
}