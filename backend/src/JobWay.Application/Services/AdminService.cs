using JobWay.Application.Common;
using JobWay.Application.DTOs.Admin.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class AdminService : IAdminService
{
    private readonly IUnitOfWork _unitOfWork;

    public AdminService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<List<CompanyModerationResponse>>> GetCompaniesAsync(CancellationToken cancellationToken)
    {
        var companies = await _unitOfWork.CompanyProfiles.GetAllAsync(cancellationToken);
        return Result<List<CompanyModerationResponse>>.Ok(companies.Select(MapCompany).ToList());
    }

    public async Task<Result<string>> VerifyCompanyAsync(Guid companyId, CancellationToken cancellationToken)
        => await ChangeVerificationStatusAsync(companyId, VerificationStatus.Verified, cancellationToken);

    public async Task<Result<string>> RejectCompanyAsync(Guid companyId, CancellationToken cancellationToken)
        => await ChangeVerificationStatusAsync(companyId, VerificationStatus.Rejected, cancellationToken);

    public async Task<Result<List<UserModerationResponse>>> GetUsersAsync(CancellationToken cancellationToken)
    {
        var users = await _unitOfWork.Users.GetAllAsync(cancellationToken);
        return Result<List<UserModerationResponse>>.Ok(users.Select(MapUser).ToList());
    }

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

        return Result<string>.Ok("Vacancy archived");
    }

    private async Task<Result<string>> ChangeVerificationStatusAsync(Guid companyId, VerificationStatus status, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByIdAsync(companyId, cancellationToken);

        if (company is null)
            return Result<string>.Fail("Company not found", ErrorType.NotFound);

        company.VerificationStatus = status;

        _unitOfWork.CompanyProfiles.Update(company);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

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

        return Result<string>.Ok(isActive ? "User unblocked" : "User blocked");
    }

    private static CompanyModerationResponse MapCompany(CompanyProfile company) => new()
    {
        Id = company.Id,
        CompanyName = company.CompanyName,
        Industry = company.Industry,
        Location = company.Location,
        VerificationStatus = company.VerificationStatus
    };

    private static UserModerationResponse MapUser(User user) => new()
    {
        Id = user.Id,
        Email = user.Email,
        Role = user.Role,
        IsActive = user.IsActive
    };
}