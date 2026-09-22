// Infrastructure/DependencyInjection.cs
using JobWay.Application.Common;
using JobWay.Application.Interfaces;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Application.Services;
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
        services.Configure<JwtSettings>(configuration.GetSection("JwtSettings"));
        services.Configure<EmailSettings>(configuration.GetSection("EmailSettings"));

        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

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

        return services;
    }
}