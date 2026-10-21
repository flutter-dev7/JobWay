class Subscription {
  final String tier;
  final DateTime? tierExpiresAt;
  final int activeVacanciesCount;
  final int activeVacanciesLimit;
  final int promotionsUsed;
  final int promotionsLimit;
  final int promotionDays;

  const Subscription({
    required this.tier,
    this.tierExpiresAt,
    required this.activeVacanciesCount,
    required this.activeVacanciesLimit,
    this.promotionsUsed = 0,
    this.promotionsLimit = 0,
    this.promotionDays = 7,
  });

  bool get isPro => tier == 'Pro';
  bool get isLimitReached => activeVacanciesCount >= activeVacanciesLimit;
  int get promotionsLeft =>
      (promotionsLimit - promotionsUsed).clamp(0, promotionsLimit);
}