namespace JobWay.Application.DTOs.Admin.Request;

public class FeatureVacancyRequest
{
    // 0 снимает продвижение
    public int Days { get; set; } = 7;
}