using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JobWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCandidateVisibility2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsVisibleToEmployers",
                table: "CompanyProfiles");

            migrationBuilder.AddColumn<bool>(
                name: "IsVisibleToEmployers",
                table: "CandidateProfiles",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsVisibleToEmployers",
                table: "CandidateProfiles");

            migrationBuilder.AddColumn<bool>(
                name: "IsVisibleToEmployers",
                table: "CompanyProfiles",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }
    }
}
