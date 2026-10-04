using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class CandidateProfileConfiguration : IEntityTypeConfiguration<CandidateProfile>
{
    public void Configure(EntityTypeBuilder<CandidateProfile> builder)
    {
        builder.Property(c => c.FullName).IsRequired().HasMaxLength(200);
        builder.Property(c => c.Location).HasMaxLength(200);
        builder.Property(c => c.ResumeFileUrl).HasMaxLength(2000);
        builder.Property(c => c.PhotoUrl).HasMaxLength(2000);
        
        builder.HasMany(c => c.Skills)
            .WithMany(s => s.CandidateProfiles)
            .UsingEntity(j => j.ToTable("CandidateSkills"));

        builder.HasMany(c => c.Applications)
            .WithOne(a => a.CandidateProfile)
            .HasForeignKey(a => a.CandidateProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}