// Infrastructure/Persistence/Configurations/JobApplicationConfiguration.cs
using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class JobApplicationConfiguration : IEntityTypeConfiguration<JobApplication>
{
    public void Configure(EntityTypeBuilder<JobApplication> builder)
    {
        builder.Property(a => a.CoverMessage).HasMaxLength(2000);

        builder.HasIndex(a => new { a.CandidateProfileId, a.VacancyId }).IsUnique();
    }
}