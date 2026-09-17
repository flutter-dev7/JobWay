using JobWay.Application.Common;
using JobWay.Application.DTOs.Skill.Request;
using JobWay.Application.DTOs.Skill.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ISkillService
{
    Task<Result<List<SkillResponse>>> GetAllAsync(CancellationToken cancellationToken);
    Task<Result<SkillResponse>> CreateAsync(CreateSkillRequest request, CancellationToken cancellationToken);
}