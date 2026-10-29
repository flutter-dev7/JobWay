using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JobWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCompanyContacts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Phone",
                table: "CompanyProfiles",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TelegramUsername",
                table: "CompanyProfiles",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Phone",
                table: "CompanyProfiles");

            migrationBuilder.DropColumn(
                name: "TelegramUsername",
                table: "CompanyProfiles");
        }
    }
}
