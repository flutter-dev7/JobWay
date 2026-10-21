using JobWay.Application.Common;
using JobWay.Application.DTOs.Admin.Request;
using JobWay.Application.DTOs.Admin.Response;
using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class AdminService : IAdminService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly INotificationService _notificationService;
    private readonly ICacheService _cacheService;

    public AdminService(IUnitOfWork unitOfWork, INotificationService notificationService, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _notificationService = notificationService;
        _cacheService = cacheService;
    }

    public async Task<Result<PagedResult<CompanyModerationResponse>>> GetCompaniesAsync(AdminCompaniesFilterRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var (companies, totalCount) = await _unitOfWork.CompanyProfiles.GetPagedForAdminAsync(filter, cancellationToken);

        return Result<PagedResult<CompanyModerationResponse>>.Ok(new PagedResult<CompanyModerationResponse>
        {
            Items = companies.Select(MapCompany).ToList(),
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }

    public async Task<Result<PagedResult<UserModerationResponse>>> GetUsersAsync(AdminUsersFilterRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var (users, totalCount) = await _unitOfWork.Users.GetPagedForAdminAsync(filter, cancellationToken);

        return Result<PagedResult<UserModerationResponse>>.Ok(new PagedResult<UserModerationResponse>
        {
            Items = users.Select(u => new UserModerationResponse
            {
                Id = u.Id,
                Email = u.Email,
                Role = u.Role,
                IsActive = u.IsActive,
                PhotoUrl = u.PhotoUrl,
                ProfileId = u.ProfileId
            }).ToList(),
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }

    public async Task<Result<string>> VerifyCompanyAsync(Guid companyId, CancellationToken cancellationToken)
        => await ChangeVerificationStatusAsync(companyId, VerificationStatus.Verified, cancellationToken);

    public async Task<Result<string>> RejectCompanyAsync(Guid companyId, CancellationToken cancellationToken)
        => await ChangeVerificationStatusAsync(companyId, VerificationStatus.Rejected, cancellationToken);

    public async Task<Result<string>> BlockUserAsync(Guid userId, CancellationToken cancellationToken)
        => await ChangeUserActiveStatusAsync(userId, false, cancellationToken);

    public async Task<Result<string>> UnblockUserAsync(Guid userId, CancellationToken cancellationToken)
        => await ChangeUserActiveStatusAsync(userId, true, cancellationToken);

    public async Task<Result<string>> ArchiveVacancyAsync(Guid vacancyId, CancellationToken cancellationToken)
    {
        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);

        if (vacancy is null)
            return Result<string>.Fail("Vacancy not found", ErrorType.NotFound);

        vacancy.Status = VacancyStatus.Archived;

        _unitOfWork.Vacancies.Update(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        await _cacheService.RemoveAsync(VacancyCacheKey(vacancyId), cancellationToken);

        return Result<string>.Ok("Vacancy archived");
    }
    
    public async Task<Result<CompanyModerationResponse>> SetCompanyTierAsync(Guid companyId, SetCompanyTierRequest request, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByIdAsync(companyId, cancellationToken);
        if (company is null)
            return Result<CompanyModerationResponse>.Fail("Company not found", ErrorType.NotFound);

        string title;
        string message;

        if (request.Tier == CompanyTier.Free)
        {
            company.Tier = CompanyTier.Free;
            company.TierExpiresAt = null;

            title = "Тариф изменён";
            message = "Ваш тариф изменён на Free.";
        }
        else
        {
            if (request.Days is < 1 or > 365)
                return Result<CompanyModerationResponse>.Fail("Days must be between 1 and 365", ErrorType.Validation);

            // Если Pro ещё действует, продлеваем от даты окончания, а не от сегодняшнего дня
            var start = company.Tier == CompanyTier.Pro && company.TierExpiresAt is { } current && current > DateTime.UtcNow
                ? current
                : DateTime.UtcNow;

            company.Tier = CompanyTier.Pro;
            company.TierExpiresAt = start.AddDays(request.Days);

            title = "Тариф Pro активирован";
            message = $"Тариф Pro действует до {company.TierExpiresAt:dd.MM.yyyy}. Спасибо, что вы с нами!";
        }

        _unitOfWork.CompanyProfiles.Update(company);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _notificationService.CreateAsync(
            company.UserId,
            NotificationType.SubscriptionChanged,
            title,
            message,
            company.Id,
            cancellationToken);

        return Result<CompanyModerationResponse>.Ok(MapCompany(company));
    }

        public async Task<Result<AdminVacancyResponse>> FeatureVacancyAsync(Guid vacancyId, FeatureVacancyRequest request, CancellationToken cancellationToken)
    {
        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null)
            return Result<AdminVacancyResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        if (request.Days is < 0 or > 90)
            return Result<AdminVacancyResponse>.Fail("Days must be between 0 and 90", ErrorType.Validation);

        string message;

        if (request.Days == 0)
        {
            vacancy.FeaturedUntil = null;
            message = $"Продвижение вакансии «{vacancy.Title}» завершено.";
        }
        else
        {
            if (vacancy.Status != VacancyStatus.Active)
                return Result<AdminVacancyResponse>.Fail("Only active vacancies can be promoted", ErrorType.Validation);

            // Если продвижение ещё идёт, продлеваем от даты окончания
            var start = vacancy.FeaturedUntil is { } current && current > DateTime.UtcNow
                ? current
                : DateTime.UtcNow;

            vacancy.FeaturedUntil = start.AddDays(request.Days);
            message = $"Вакансия «{vacancy.Title}» продвигается до {vacancy.FeaturedUntil:dd.MM.yyyy}.";
        }

        _unitOfWork.Vacancies.Update(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        await _cacheService.RemoveAsync(VacancyCacheKey(vacancyId), cancellationToken);

        await _notificationService.CreateAsync(
            vacancy.CompanyProfile.UserId,
            NotificationType.VacancyPromoted,
            "Продвижение вакансии",
            message,
            vacancy.Id,
            cancellationToken);

        return Result<AdminVacancyResponse>.Ok(MapVacancy(vacancy));
    }

    public async Task<Result<List<AdminVacancyResponse>>> GetCompanyActiveVacanciesAsync(Guid companyId, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByIdAsync(companyId, cancellationToken);
        if (company is null)
            return Result<List<AdminVacancyResponse>>.Fail("Company not found", ErrorType.NotFound);

        // Активных вакансий не больше лимита тарифа, поэтому отдельная пагинация не нужна
        var filter = new MyVacanciesFilterRequest { Status = VacancyStatus.Active, PageNumber = 1, PageSize = 50 };
        var (vacancies, _) = await _unitOfWork.Vacancies.GetPagedByCompanyProfileIdAsync(company.Id, filter, cancellationToken);

        return Result<List<AdminVacancyResponse>>.Ok(vacancies.Select(MapVacancy).ToList());
    }

    private static string VacancyCacheKey(Guid id) => $"vacancy:{id}";

    private static AdminVacancyResponse MapVacancy(Vacancy vacancy) => new()
    {
        Id = vacancy.Id,
        Title = vacancy.Title,
        Status = vacancy.Status,
        CreatedAt = vacancy.CreatedAt,
        FeaturedUntil = vacancy.FeaturedUntil
    };

    private async Task<Result<string>> ChangeVerificationStatusAsync(Guid companyId, VerificationStatus status, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByIdAsync(companyId, cancellationToken);

        if (company is null)
            return Result<string>.Fail("Company not found", ErrorType.NotFound);

        company.VerificationStatus = status;

        _unitOfWork.CompanyProfiles.Update(company);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        var (type, title, message) = status == VerificationStatus.Verified
            ? (NotificationType.CompanyVerified, "Компания верифицирована", $"Поздравляем! «{company.CompanyName}» прошла верификацию и теперь может публиковать вакансии.")
            : (NotificationType.CompanyRejected, "Заявка на верификацию отклонена", $"Заявка на верификацию «{company.CompanyName}» была отклонена администратором.");

        await _notificationService.CreateAsync(
            company.UserId,
            type,
            title,
            message,
            company.Id,
            cancellationToken);

        return Result<string>.Ok($"Company {status.ToString().ToLower()}");
    }

    private async Task<Result<string>> ChangeUserActiveStatusAsync(Guid userId, bool isActive, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Users.GetByIdAsync(userId, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        if (user.Role == UserRole.Admin)
            return Result<string>.Fail("Cannot change status of an Admin account", ErrorType.Forbidden);

        user.IsActive = isActive;

        _unitOfWork.Users.Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        var (type, title, message) = isActive
            ? (NotificationType.AccountUnblocked, "Аккаунт разблокирован", "Ваш аккаунт снова активен, вы можете пользоваться приложением.")
            : (NotificationType.AccountBlocked, "Аккаунт заблокирован", "Ваш аккаунт заблокирован администратором. Обратитесь в поддержку для уточнения причины.");

        await _notificationService.CreateAsync(
            user.Id,
            type,
            title,
            message,
            user.Id,
            cancellationToken);

        return Result<string>.Ok(isActive ? "User unblocked" : "User blocked");
    }
    
    public async Task<Result<CompanyModerationResponse>> GetCompanyAsync(Guid companyId, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByIdAsync(companyId, cancellationToken);

        return company is null
            ? Result<CompanyModerationResponse>.Fail("Company not found", ErrorType.NotFound)
            : Result<CompanyModerationResponse>.Ok(MapCompany(company));
    }

    private static CompanyModerationResponse MapCompany(CompanyProfile company) => new()
    {
        Id = company.Id,
        UserId = company.UserId,
        CompanyName = company.CompanyName,
        Description = company.Description,
        Industry = company.Industry,
        Website = company.Website,
        Location = company.Location,
        LogoUrl = company.LogoUrl,
        VerificationStatus = company.VerificationStatus,
        Tier = TierRules.GetEffectiveTier(company),
        TierExpiresAt = TierRules.GetEffectiveTier(company) == CompanyTier.Pro ? company.TierExpiresAt : null
    };

    private static UserModerationResponse MapUser(
        User user,
        Dictionary<Guid, string?> candidatePhotoByUserId,
        Dictionary<Guid, string?> companyLogoByUserId)
    {
        var photoUrl = candidatePhotoByUserId.TryGetValue(user.Id, out var candidatePhoto)
            ? candidatePhoto
            : companyLogoByUserId.GetValueOrDefault(user.Id);

        return new UserModerationResponse
        {
            Id = user.Id,
            Email = user.Email,
            Role = user.Role,
            IsActive = user.IsActive,
            PhotoUrl = photoUrl
        };
    }
}