class Subscription {
  final String tier;
  final DateTime? tierExpiresAt;
  final int activeVacanciesCount;
  final int activeVacanciesLimit;
  final int promotionsUsed;
  final int promotionsLimit;
  final int promotionDays;
  final int invitationsUsed;
  final int invitationsLimit;

  const Subscription({
    required this.tier,
    this.tierExpiresAt,
    required this.activeVacanciesCount,
    required this.activeVacanciesLimit,
    this.promotionsUsed = 0,
    this.promotionsLimit = 0,
    this.promotionDays = 7,
    this.invitationsUsed = 0,
    this.invitationsLimit = 0,
  });

  bool get isPro => tier == 'Pro';
  bool get isLimitReached => activeVacanciesCount >= activeVacanciesLimit;
  int get promotionsLeft =>
      (promotionsLimit - promotionsUsed).clamp(0, promotionsLimit);

  bool get isInvitationLimitReached =>
      invitationsLimit > 0 && invitationsUsed >= invitationsLimit;
  int get invitationsLeft =>
      (invitationsLimit - invitationsUsed).clamp(0, invitationsLimit);
}