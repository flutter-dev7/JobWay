using System.Text.Json;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Skill.Request;
using JobWay.Application.DTOs.Skill.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class SkillService : ISkillService
{
    private const string AllSkillsCacheKey = "skills:all";

    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cacheService;

    public SkillService(IUnitOfWork unitOfWork, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
    }

    public async Task<Result<List<SkillResponse>>> GetAllAsync(CancellationToken cancellationToken)
    {
        var cached = await _cacheService.GetAsync(AllSkillsCacheKey, cancellationToken);

        if (cached is not null)
            return Result<List<SkillResponse>>.Ok(JsonSerializer.Deserialize<List<SkillResponse>>(cached));

        var skills = await _unitOfWork.Skills.GetAllAsync(cancellationToken);
        var response = skills.Select(MapToResponse).ToList();

        await _cacheService.SetAsync(AllSkillsCacheKey, JsonSerializer.Serialize(response), TimeSpan.FromMinutes(30), cancellationToken);

        return Result<List<SkillResponse>>.Ok(response);
    }

    public async Task<Result<SkillResponse>> CreateAsync(CreateSkillRequest request, CancellationToken cancellationToken)
    {
        if (await _unitOfWork.Skills.ExistsByNameAsync(request.NameRu, cancellationToken))
            return Result<SkillResponse>.Fail("Skill with this name already exists", ErrorType.Conflict);

        var skill = new Skill
        {
            NameRu = request.NameRu,
            NameTj = request.NameTj,
            Category = request.Category
        };

        _unitOfWork.Skills.Add(skill);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(AllSkillsCacheKey, cancellationToken);

        return Result<SkillResponse>.Ok(MapToResponse(skill));
    }

    private static SkillResponse MapToResponse(Skill skill) => new()
    {
        Id = skill.Id,
        NameRu = skill.NameRu,
        NameTj = skill.NameTj,
        Category = skill.Category
    };
}