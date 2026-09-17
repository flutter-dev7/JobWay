// API/Middleware/ExceptionHandlingMiddleware.cs
using System.Net;
using System.Text.Json;
using JobWay.Application.Common;
using JobWay.Domain.Enums;

namespace JobWay.API.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

            var result = Result<object>.Fail("An unexpected error occurred", ErrorType.Failure);

            await context.Response.WriteAsync(JsonSerializer.Serialize(result));
        }
    }
}