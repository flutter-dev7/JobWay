using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JobWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCompanyTierAndVacancyFeatured : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "FeaturedUntil",
                table: "Vacancies",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Tier",
                table: "CompanyProfiles",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "TierExpiresAt",
                table: "CompanyProfiles",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FeaturedUntil",
                table: "Vacancies");

            migrationBuilder.DropColumn(
                name: "Tier",
                table: "CompanyProfiles");

            migrationBuilder.DropColumn(
                name: "TierExpiresAt",
                table: "CompanyProfiles");
        }
    }
}
