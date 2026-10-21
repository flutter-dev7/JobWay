import '../../domain/entities/subscription.dart';

class SubscriptionModel {
  final String tier;
  final DateTime? tierExpiresAt;
  final int activeVacanciesCount;
  final int activeVacanciesLimit;

  SubscriptionModel({
    required this.tier,
    this.tierExpiresAt,
    required this.activeVacanciesCount,
    required this.activeVacanciesLimit,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      tier: json['tier'],
      tierExpiresAt: json['tierExpiresAt'] != null
          ? DateTime.parse(json['tierExpiresAt'])
          : null,
      activeVacanciesCount: json['activeVacanciesCount'],
      activeVacanciesLimit: json['activeVacanciesLimit'],
    );
  }

  Subscription toEntity() => Subscription(
    tier: tier,
    tierExpiresAt: tierExpiresAt,
    activeVacanciesCount: activeVacanciesCount,
    activeVacanciesLimit: activeVacanciesLimit,
  );
}