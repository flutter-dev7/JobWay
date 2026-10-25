using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JobWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddVacancyExpiry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ExpiresAt",
                table: "Vacancies",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "ExpiryNoticeSent",
                table: "Vacancies",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ExpiresAt",
                table: "Vacancies");

            migrationBuilder.DropColumn(
                name: "ExpiryNoticeSent",
                table: "Vacancies");
        }
    }
}
