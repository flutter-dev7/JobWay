using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class SkillConfiguration : IEntityTypeConfiguration<Skill>
{
    public void Configure(EntityTypeBuilder<Skill> builder)
    {
        builder.Property(s => s.NameRu).IsRequired().HasMaxLength(150);
        builder.Property(s => s.NameTj).IsRequired().HasMaxLength(150);
        builder.Property(s => s.Category).HasMaxLength(100);
    }
}