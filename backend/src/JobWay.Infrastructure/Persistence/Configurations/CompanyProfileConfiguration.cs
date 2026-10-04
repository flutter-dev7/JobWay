using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class CompanyProfileConfiguration : IEntityTypeConfiguration<CompanyProfile>
{
    public void Configure(EntityTypeBuilder<CompanyProfile> builder)
    {
        builder.Property(c => c.CompanyName).IsRequired().HasMaxLength(200);
        builder.Property(c => c.Website).HasMaxLength(300);
        builder.Property(c => c.Location).HasMaxLength(200);
        builder.Property(c => c.LogoUrl).HasMaxLength(2000);

        builder.HasMany(c => c.Vacancies)
            .WithOne(v => v.CompanyProfile)
            .HasForeignKey(v => v.CompanyProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}