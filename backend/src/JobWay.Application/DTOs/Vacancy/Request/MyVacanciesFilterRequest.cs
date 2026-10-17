using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Vacancy.Request;

public class MyVacanciesFilterRequest
{
    public VacancyStatus? Status { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}