using JobWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace JobWay.Infrastructure.Persistence.Configurations;

public class VacancyPromotionConfiguration : IEntityTypeConfiguration<VacancyPromotion>
{
    public void Configure(EntityTypeBuilder<VacancyPromotion> builder)
    {
        builder.HasOne(p => p.Vacancy)
            .WithMany()
            .HasForeignKey(p => p.VacancyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(p => p.CreatedAt);
    }
}