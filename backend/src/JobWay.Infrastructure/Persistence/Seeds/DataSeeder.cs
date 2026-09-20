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
        await SeedSkillsAsync(context);
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
    
    private static async Task SeedSkillsAsync(AppDbContext context)
    {
        if (await context.Skills.AnyAsync()) return;

        var skills = new List<Skill>
        {
            // Языки программирования
            new() { NameRu = "C#", NameTj = "C#", Category = "Языки программирования" },
            new() { NameRu = "JavaScript", NameTj = "JavaScript", Category = "Языки программирования" },
            new() { NameRu = "TypeScript", NameTj = "TypeScript", Category = "Языки программирования" },
            new() { NameRu = "Python", NameTj = "Python", Category = "Языки программирования" },
            new() { NameRu = "Java", NameTj = "Java", Category = "Языки программирования" },
            new() { NameRu = "PHP", NameTj = "PHP", Category = "Языки программирования" },
            new() { NameRu = "Dart", NameTj = "Dart", Category = "Языки программирования" },
            new() { NameRu = "Kotlin", NameTj = "Kotlin", Category = "Языки программирования" },
            new() { NameRu = "Swift", NameTj = "Swift", Category = "Языки программирования" },

            // Фреймворки и технологии
            new() { NameRu = ".NET", NameTj = ".NET", Category = "Фреймворки" },
            new() { NameRu = "ASP.NET Core", NameTj = "ASP.NET Core", Category = "Фреймворки" },
            new() { NameRu = "React", NameTj = "React", Category = "Фреймворки" },
            new() { NameRu = "Vue.js", NameTj = "Vue.js", Category = "Фреймворки" },
            new() { NameRu = "Angular", NameTj = "Angular", Category = "Фреймворки" },
            new() { NameRu = "Flutter", NameTj = "Flutter", Category = "Фреймворки" },
            new() { NameRu = "Node.js", NameTj = "Node.js", Category = "Фреймворки" },
            new() { NameRu = "Django", NameTj = "Django", Category = "Фреймворки" },
            new() { NameRu = "Laravel", NameTj = "Laravel", Category = "Фреймворки" },

            // Базы данных
            new() { NameRu = "PostgreSQL", NameTj = "PostgreSQL", Category = "Базы данных" },
            new() { NameRu = "MySQL", NameTj = "MySQL", Category = "Базы данных" },
            new() { NameRu = "MongoDB", NameTj = "MongoDB", Category = "Базы данных" },
            new() { NameRu = "Redis", NameTj = "Redis", Category = "Базы данных" },
            new() { NameRu = "MS SQL Server", NameTj = "MS SQL Server", Category = "Базы данных" },

            // Инструменты и DevOps
            new() { NameRu = "Docker", NameTj = "Docker", Category = "DevOps" },
            new() { NameRu = "Git", NameTj = "Git", Category = "Инструменты" },
            new() { NameRu = "CI/CD", NameTj = "CI/CD", Category = "DevOps" },
            new() { NameRu = "Kubernetes", NameTj = "Kubernetes", Category = "DevOps" },
            new() { NameRu = "Linux", NameTj = "Linux", Category = "Инструменты" },

            // Дизайн
            new() { NameRu = "Figma", NameTj = "Figma", Category = "Дизайн" },
            new() { NameRu = "UI/UX дизайн", NameTj = "Тарроҳии UI/UX", Category = "Дизайн" },
            new() { NameRu = "Adobe Photoshop", NameTj = "Adobe Photoshop", Category = "Дизайн" },

            // Софт-скиллы
            new() { NameRu = "Коммуникация", NameTj = "Муошират", Category = "Софт-скиллы" },
            new() { NameRu = "Работа в команде", NameTj = "Кор дар гурӯҳ", Category = "Софт-скиллы" },
            new() { NameRu = "Тайм-менеджмент", NameTj = "Идоракунии вақт", Category = "Софт-скиллы" },
            new() { NameRu = "Лидерство", NameTj = "Роҳбарӣ", Category = "Софт-скиллы" },
            new() { NameRu = "Английский язык", NameTj = "Забони англисӣ", Category = "Языки" },

            // Другое
            new() { NameRu = "Excel", NameTj = "Excel", Category = "Офисные программы" },
            new() { NameRu = "SEO", NameTj = "SEO", Category = "Маркетинг" },
            new() { NameRu = "Digital-маркетинг", NameTj = "Маркетинги рақамӣ", Category = "Маркетинг" },
            new() { NameRu = "Бухгалтерский учёт", NameTj = "Муҳосибӣ", Category = "Финансы" },
        };

        await context.Skills.AddRangeAsync(skills);
        await context.SaveChangesAsync();
    }
}