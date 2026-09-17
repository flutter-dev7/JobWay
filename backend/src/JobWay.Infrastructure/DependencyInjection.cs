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

        return services;
    }
}