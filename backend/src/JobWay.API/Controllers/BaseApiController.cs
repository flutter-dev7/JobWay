using System.IdentityModel.Tokens.Jwt;
using JobWay.Application.Common;
using JobWay.Domain.Enums;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[ApiController]
public abstract class BaseApiController : ControllerBase
{
    protected Guid CurrentUserId =>
        Guid.Parse(User.Claims.First(c => c.Type == JwtRegisteredClaimNames.Sub).Value);

    protected IActionResult HandleError<T>(Result<T> result)
    {
        if (result.IsSuccess)
            return Ok(result);

        return result.ErrorType switch
        {
            ErrorType.NotFound => NotFound(result),
            ErrorType.Validation => BadRequest(result),
            ErrorType.Conflict => Conflict(result),
            ErrorType.Unauthorized => Unauthorized(result),
            ErrorType.Forbidden => StatusCode(403, result),
            _ => StatusCode(500, result)
        };
    }
}