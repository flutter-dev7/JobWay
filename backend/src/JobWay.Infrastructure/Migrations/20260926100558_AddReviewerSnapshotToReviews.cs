using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JobWay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddReviewerSnapshotToReviews : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ReviewerName",
                table: "Reviews",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ReviewerPhotoUrl",
                table: "Reviews",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ReviewerName",
                table: "Reviews");

            migrationBuilder.DropColumn(
                name: "ReviewerPhotoUrl",
                table: "Reviews");
        }
    }
}
