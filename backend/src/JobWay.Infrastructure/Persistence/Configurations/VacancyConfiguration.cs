using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class VacancyConfiguration : IEntityTypeConfiguration<Vacancy>
{
    public void Configure(EntityTypeBuilder<Vacancy> builder)
    {
        builder.Property(v => v.Title).IsRequired().HasMaxLength(200);
        builder.Property(v => v.Description).IsRequired();
        builder.Property(v => v.Location).HasMaxLength(200);
        builder.Property(v => v.SalaryFrom).HasPrecision(12, 2);
        builder.Property(v => v.SalaryTo).HasPrecision(12, 2);

        builder.HasMany(v => v.RequiredSkills)
            .WithMany(s => s.Vacancies)
            .UsingEntity(j => j.ToTable("VacancySkills"));

        builder.HasMany(v => v.Applications)
            .WithOne(a => a.Vacancy)
            .HasForeignKey(a => a.VacancyId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}