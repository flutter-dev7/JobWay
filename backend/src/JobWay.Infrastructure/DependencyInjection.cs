using JobWay.Application.Common;
using JobWay.Application.Interfaces;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Application.Services;
using JobWay.Infrastructure.BackgroundJobs;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using JobWay.Infrastructure.Repositories;
using JobWay.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace JobWay.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        InitializeFirebase(configuration);
        services.Configure<JwtSettings>(configuration.GetSection("JwtSettings"));
        services.Configure<EmailSettings>(configuration.GetSection("EmailSettings"));
        services.AddHttpClient<IEmailService, EmailService>();

        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));
        
        services.AddHostedService<ReviewReminderBackgroundService>();

        services.AddScoped<IUnitOfWork, UnitOfWork>();
        services.AddScoped<IPasswordHasher, BCryptPasswordHasher>();
        services.AddScoped<IJwtService, JwtService>();
        services.AddScoped<IEmailService, EmailService>();
        
        services.AddScoped<IAuthService, AuthService>();
        
        services.AddMemoryCache();
        services.AddScoped<ICacheService, MemoryCacheService>();
        
        services.AddScoped<ISkillService, SkillService>();
        services.AddScoped<ICandidateProfileService, CandidateProfileService>();
        services.AddScoped<ICompanyProfileService, CompanyProfileService>();
        
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ICandidateProfileRepository, CandidateProfileRepository>();
        services.AddScoped<ICompanyProfileRepository, CompanyProfileRepository>();
        services.AddScoped<ISkillRepository, SkillRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();
        
        services.AddScoped<IVacancyRepository, VacancyRepository>();
        services.AddScoped<IVacancyService, VacancyService>();
        
        services.AddScoped<ISavedVacancyRepository, SavedVacancyRepository>();
        services.AddScoped<ISavedVacancyService, SavedVacancyService>();
        
        services.AddScoped<IJobApplicationRepository, JobApplicationRepository>();
        services.AddScoped<IMatchingService, MatchingService>();
        services.AddScoped<IJobApplicationService, JobApplicationService>();
        
        services.AddScoped<INotificationRepository, NotificationRepository>();
        services.AddScoped<INotificationService, NotificationService>();
        
        services.AddScoped<IAdminService, AdminService>();
        
        services.AddScoped<IFileStorageService, LocalFileStorageService>();
        
        services.AddScoped<IPushNotificationService, FcmPushNotificationService>();
        services.AddScoped<IDeviceTokenRepository, DeviceTokenRepository>();
        
        services.AddScoped<IReviewRepository, ReviewRepository>();
        services.AddScoped<IReviewService, ReviewService>();

        return services;
    }
    
    private static void InitializeFirebase(IConfiguration configuration)
    {
        if (FirebaseAdmin.FirebaseApp.DefaultInstance is not null) return;

        var credentialsPath = configuration["Firebase:CredentialsPath"];
        if (string.IsNullOrWhiteSpace(credentialsPath) || !File.Exists(credentialsPath)) return;

        FirebaseAdmin.FirebaseApp.Create(new FirebaseAdmin.AppOptions
        {
            Credential = Google.Apis.Auth.OAuth2.GoogleCredential.FromFile(credentialsPath)
        });
    }
}