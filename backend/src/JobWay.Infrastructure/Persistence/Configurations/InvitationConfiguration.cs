using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class InvitationConfiguration : IEntityTypeConfiguration<Invitation>
{
    public void Configure(EntityTypeBuilder<Invitation> builder)
    {
        builder.Property(i => i.Message).HasMaxLength(500);

        builder.HasOne(i => i.CompanyProfile)
            .WithMany()
            .HasForeignKey(i => i.CompanyProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(i => i.CandidateProfile)
            .WithMany()
            .HasForeignKey(i => i.CandidateProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(i => i.Vacancy)
            .WithMany()
            .HasForeignKey(i => i.VacancyId)
            .OnDelete(DeleteBehavior.Cascade);

        // Одно приглашение на пару «кандидат + вакансия»: повторно донимать отказавшегося нельзя
        builder.HasIndex(i => new { i.CandidateProfileId, i.VacancyId }).IsUnique();

        // Для подсчёта дневного лимита
        builder.HasIndex(i => new { i.CompanyProfileId, i.CreatedAt });
    }
}