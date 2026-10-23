using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Persistence.Seeds;

public static class SkillCatalogSeeder
{
    // Старые категории приводим к единым сферам, чтобы в приложении не было разнобоя
    private static readonly Dictionary<string, string> CategoryRenames = new()
    {
        ["Языки программирования"] = "IT и разработка",
        ["Фреймворки"] = "IT и разработка",
        ["Базы данных"] = "IT и разработка",
        ["DevOps"] = "IT и разработка",
        ["Инструменты"] = "IT и разработка",
        ["Дизайн"] = "Дизайн и креатив",
        ["Маркетинг"] = "Маркетинг и реклама",
        ["Финансы"] = "Бухгалтерия и финансы",
        ["Офисные программы"] = "Офис и администрация",
        ["Языки"] = "Общие навыки",
        ["Софт-скиллы"] = "Общие навыки"
    };

    public static async Task SeedMissingAsync(AppDbContext context, CancellationToken cancellationToken = default)
    {
        await NormalizeCategoriesAsync(context, cancellationToken);
        await AddMissingSkillsAsync(context, cancellationToken);
    }

    private static async Task NormalizeCategoriesAsync(AppDbContext context, CancellationToken cancellationToken)
    {
        foreach (var rename in CategoryRenames)
        {
            var oldName = rename.Key;
            var newName = rename.Value;

            await context.Skills
                .Where(s => s.Category == oldName)
                .ExecuteUpdateAsync(setters => setters.SetProperty(s => s.Category, newName), cancellationToken);
        }
    }

    private static async Task AddMissingSkillsAsync(AppDbContext context, CancellationToken cancellationToken)
    {
        var existingNames = await context.Skills.Select(s => s.NameRu).ToListAsync(cancellationToken);
        var known = new HashSet<string>(existingNames.Select(n => n.Trim()), StringComparer.OrdinalIgnoreCase);

        // Add возвращает false, если такое название уже есть (в базе или раньше в каталоге)
        var toAdd = SkillCatalog.Items
            .Where(item => known.Add(item.NameRu.Trim()))
            .Select(item => new Skill
            {
                NameRu = item.NameRu,
                NameTj = item.NameTj,
                Category = item.Category
            })
            .ToList();

        if (toAdd.Count == 0) return;

        context.Skills.AddRange(toAdd);
        await context.SaveChangesAsync(cancellationToken);
    }
}