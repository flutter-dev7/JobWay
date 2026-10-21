import '../../domain/entities/subscription.dart';

class SubscriptionModel {
  final String tier;
  final DateTime? tierExpiresAt;
  final int activeVacanciesCount;
  final int activeVacanciesLimit;
  final int promotionsUsed;
  final int promotionsLimit;
  final int promotionDays;

  SubscriptionModel({
    required this.tier,
    this.tierExpiresAt,
    required this.activeVacanciesCount,
    required this.activeVacanciesLimit,
    this.promotionsUsed = 0,
    this.promotionsLimit = 0,
    this.promotionDays = 7,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      tier: json['tier'],
      tierExpiresAt: json['tierExpiresAt'] != null
          ? DateTime.parse(json['tierExpiresAt'])
          : null,
      activeVacanciesCount: json['activeVacanciesCount'],
      activeVacanciesLimit: json['activeVacanciesLimit'],
      promotionsUsed: json['promotionsUsed'] ?? 0,
      promotionsLimit: json['promotionsLimit'] ?? 0,
      promotionDays: json['promotionDays'] ?? 7,
    );
  }

  Subscription toEntity() => Subscription(
    tier: tier,
    tierExpiresAt: tierExpiresAt,
    activeVacanciesCount: activeVacanciesCount,
    activeVacanciesLimit: activeVacanciesLimit,
    promotionsUsed: promotionsUsed,
    promotionsLimit: promotionsLimit,
    promotionDays: promotionDays,
  );
}