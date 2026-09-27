using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JobWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentTypeToVacancy : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PaymentType",
                table: "Vacancies",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PaymentType",
                table: "Vacancies");
        }
    }
}
