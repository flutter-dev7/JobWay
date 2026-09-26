using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.HasKey(r => r.Id);

        builder.Property(r => r.Rating).IsRequired();
        builder.Property(r => r.Comment).HasMaxLength(2000);
        
        builder.Property(r => r.ReviewerName).IsRequired().HasMaxLength(200);
        builder.Property(r => r.ReviewerPhotoUrl).HasMaxLength(500);

        builder.HasOne(r => r.JobApplication)
            .WithMany()
            .HasForeignKey(r => r.JobApplicationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(r => new { r.JobApplicationId, r.Type }).IsUnique();
        builder.HasIndex(r => r.RevieweeUserId);
    }
}