class Subscription {
  final String tier;
  final DateTime? tierExpiresAt;
  final int activeVacanciesCount;
  final int activeVacanciesLimit;

  const Subscription({
    required this.tier,
    this.tierExpiresAt,
    required this.activeVacanciesCount,
    required this.activeVacanciesLimit,
  });

  bool get isPro => tier == 'Pro';
  bool get isLimitReached => activeVacanciesCount >= activeVacanciesLimit;
}