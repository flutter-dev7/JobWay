using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class ChatMessageConfiguration : IEntityTypeConfiguration<ChatMessage>
{
    public void Configure(EntityTypeBuilder<ChatMessage> builder)
    {
        builder.Property(m => m.Text).IsRequired().HasMaxLength(2000);

        builder.HasOne(m => m.JobApplication)
            .WithMany()
            .HasForeignKey(m => m.JobApplicationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(m => new { m.JobApplicationId, m.CreatedAt });
    }
}