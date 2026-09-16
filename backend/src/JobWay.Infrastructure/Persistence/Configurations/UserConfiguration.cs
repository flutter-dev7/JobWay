using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(256);
        builder.HasIndex(u => u.Email).IsUnique();

        builder.Property(u => u.PhoneNumber).HasMaxLength(32);
        builder.Property(u => u.PasswordHash).IsRequired();
        builder.Property(u => u.PreferredLanguage).IsRequired().HasMaxLength(2);

        builder.HasOne(u => u.CandidateProfile)
            .WithOne(c => c.User)
            .HasForeignKey<CandidateProfile>(c => c.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(u => u.CompanyProfile)
            .WithOne(c => c.User)
            .HasForeignKey<CompanyProfile>(c => c.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}