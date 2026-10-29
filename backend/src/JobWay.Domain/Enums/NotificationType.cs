namespace JobWay.Domain.Enums;

public enum NotificationType
{
    NewApplication,
    ApplicationStatusChanged,
    NewMatchingVacancy,
    System,
    NewReview,
    ReviewReminder,
    NewEmployerRegistered,
    NewMessage,
    CompanyVerified,
    CompanyRejected,
    SubscriptionChanged,
    VacancyPromoted,
    AccountBlocked,
    AccountUnblocked,
    VacancyExpiring,
    VacancyExpired,
    InvitationReceived,
    InvitationDeclined
}