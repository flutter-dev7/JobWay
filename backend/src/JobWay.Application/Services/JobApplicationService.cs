// Application/Services/JobApplicationService.cs — заменить целиком
using JobWay.Application.Common;
using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.DTOs.JobApplication.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class JobApplicationService : IJobApplicationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMatchingService _matchingService;
    private readonly INotificationService _notificationService;

    public JobApplicationService(IUnitOfWork unitOfWork, IMatchingService matchingService, INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _matchingService = matchingService;
        _notificationService = notificationService;
    }

    public async Task<Result<JobApplicationResponse>> ApplyAsync(Guid candidateUserId, Guid vacancyId, CreateJobApplicationRequest request, CancellationToken cancellationToken)
    {
        var candidateProfile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(candidateUserId, cancellationToken);
        if (candidateProfile is null)
            return Result<JobApplicationResponse>.Fail("Candidate profile not found", ErrorType.NotFound);

        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null)
            return Result<JobApplicationResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        if (vacancy.Status != VacancyStatus.Active)
            return Result<JobApplicationResponse>.Fail("Vacancy is not open for applications", ErrorType.Validation);

        if (await _unitOfWork.JobApplications.ExistsAsync(candidateProfile.Id, vacancyId, cancellationToken))
            return Result<JobApplicationResponse>.Fail("You have already applied to this vacancy", ErrorType.Conflict);

        var match = _matchingService.Calculate(candidateProfile.Skills, vacancy.RequiredSkills);

        var application = new JobApplication
        {
            CandidateProfileId = candidateProfile.Id,
            CandidateProfile = candidateProfile,
            VacancyId = vacancyId,
            Vacancy = vacancy,
            MatchScore = match.ScorePercent,
            CoverMessage = request.CoverMessage
        };

        _unitOfWork.JobApplications.Add(application);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _notificationService.CreateAsync(
            vacancy.CompanyProfile.UserId,
            NotificationType.NewApplication,
            "Новый отклик",
            $"{candidateProfile.FullName} откликнулся(-ась) на вакансию «{vacancy.Title}»",
            application.Id,
            cancellationToken);

        return Result<JobApplicationResponse>.Ok(MapToResponse(application));
    }

    public async Task<Result<JobApplicationResponse>> UpdateStatusAsync(Guid employerUserId, Guid applicationId, UpdateJobApplicationStatusRequest request, CancellationToken cancellationToken)
    {
        var application = await _unitOfWork.JobApplications.GetByIdAsync(applicationId, cancellationToken);
        if (application is null)
            return Result<JobApplicationResponse>.Fail("Application not found", ErrorType.NotFound);

        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null || application.Vacancy.CompanyProfileId != companyProfile.Id)
            return Result<JobApplicationResponse>.Fail("You do not own this vacancy", ErrorType.Forbidden);

        application.Status = request.Status;

        _unitOfWork.JobApplications.Update(application);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _notificationService.CreateAsync(
            application.CandidateProfile.UserId,
            NotificationType.ApplicationStatusChanged,
            "Статус отклика изменён",
            $"Ваш отклик на вакансию «{application.Vacancy.Title}»: {_statusLabel(application.Status)}",
            application.Id,
            cancellationToken);

        return Result<JobApplicationResponse>.Ok(MapToResponse(application));
    }

    public async Task<Result<List<JobApplicationResponse>>> GetByVacancyAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<List<JobApplicationResponse>>.Fail("Company profile not found", ErrorType.NotFound);

        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null)
            return Result<List<JobApplicationResponse>>.Fail("Vacancy not found", ErrorType.NotFound);

        if (vacancy.CompanyProfileId != companyProfile.Id)
            return Result<List<JobApplicationResponse>>.Fail("You do not own this vacancy", ErrorType.Forbidden);

        var applications = await _unitOfWork.JobApplications.GetByVacancyIdAsync(vacancyId, cancellationToken);
        return Result<List<JobApplicationResponse>>.Ok(applications.Select(MapToResponse).ToList());
    }

    public async Task<Result<List<JobApplicationResponse>>> GetMyApplicationsAsync(Guid candidateUserId, CancellationToken cancellationToken)
    {
        var candidateProfile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(candidateUserId, cancellationToken);
        if (candidateProfile is null)
            return Result<List<JobApplicationResponse>>.Fail("Candidate profile not found", ErrorType.NotFound);

        var applications = await _unitOfWork.JobApplications.GetByCandidateProfileIdAsync(candidateProfile.Id, cancellationToken);
        return Result<List<JobApplicationResponse>>.Ok(applications.Select(MapToResponse).ToList());
    }

    private JobApplicationResponse MapToResponse(JobApplication application)
    {
        var match = _matchingService.Calculate(application.CandidateProfile.Skills, application.Vacancy.RequiredSkills);

        return new JobApplicationResponse
        {
            Id = application.Id,
            VacancyId = application.VacancyId,
            VacancyTitle = application.Vacancy.Title,
            CompanyName = application.Vacancy.CompanyProfile.CompanyName,
            CandidateProfileId = application.CandidateProfileId,
            CandidateFullName = application.CandidateProfile.FullName,
            Status = application.Status,
            MatchScore = application.MatchScore,
            MatchedSkills = match.MatchedSkills,
            MissingSkills = match.MissingSkills,
            CoverMessage = application.CoverMessage,
            CompanyLogoUrl = application.Vacancy.CompanyProfile.LogoUrl,
            CreatedAt = application.CreatedAt
        };
    }
    
    private static string _statusLabel(ApplicationStatus status) => status switch
    {
        ApplicationStatus.Pending => "на рассмотрении",
        ApplicationStatus.Viewed => "просмотрен работодателем",
        ApplicationStatus.Interview => "приглашение на собеседование",
        ApplicationStatus.Accepted => "принят",
        ApplicationStatus.Rejected => "отклонён",
        _ => status.ToString()
    };
}