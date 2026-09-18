using JobWay.Application.DTOs.JobApplication.Response;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Services;

public interface IMatchingService
{
    MatchResult Calculate(List<Skill> candidateSkills, List<Skill> requiredSkills);
}