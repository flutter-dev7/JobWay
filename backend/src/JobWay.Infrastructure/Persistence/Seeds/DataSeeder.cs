using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Persistence.Seeds;

public static class DataSeeder
{
    public static async Task SeedAsync(AppDbContext context)
    {
        await SeedAdminAsync(context);
    }

    private static async Task SeedAdminAsync(AppDbContext context)
    {
        if (await context.Users.AnyAsync(u => u.Role == UserRole.Admin)) return;

        var admin = new User
        {
            Id = Guid.NewGuid(),
            Email = "admin@jobway.tj",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
            Role = UserRole.Admin,
            IsActive = true
        };

        await context.Users.AddAsync(admin);
        await context.SaveChangesAsync();
    }
}