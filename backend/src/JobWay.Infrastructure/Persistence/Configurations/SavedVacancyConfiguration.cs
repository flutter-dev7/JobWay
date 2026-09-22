using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class SavedVacancyConfiguration : IEntityTypeConfiguration<SavedVacancy>
{
    public void Configure(EntityTypeBuilder<SavedVacancy> builder)
    {
        builder.HasIndex(s => new { s.UserId, s.VacancyId }).IsUnique();

        builder.HasOne(s => s.User)
            .WithMany()
            .HasForeignKey(s => s.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(s => s.Vacancy)
            .WithMany()
            .HasForeignKey(s => s.VacancyId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}