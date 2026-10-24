namespace JobWay.Application.Common;

public static class CacheKeys
{
    public static string Subscription(Guid userId) => $"subscription:{userId}";
    public static string CompanyProfile(Guid userId) => $"company-profile:{userId}";
    public static string CandidateProfile(Guid userId) => $"candidate-profile:{userId}";
    public static string EmployerAnalytics(Guid companyProfileId) => $"employer-analytics:{companyProfileId}";

    public static string SavedIds(Guid userId) => $"saved-ids:{userId}";
    public static string SavedVersion(Guid userId) => $"saved-version:{userId}";
    public static string Saved(Guid userId, string version, int page, int size)
        => $"saved:{userId}:{version}:{page}:{size}";

    public static string CompanySearch(string search, bool onlyWithVacancies, int page, int size)
        => $"search-companies:{search}:{onlyWithVacancies}:{page}:{size}";
}