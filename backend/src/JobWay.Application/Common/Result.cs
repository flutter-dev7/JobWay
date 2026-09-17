using JobWay.Domain.Enums;

namespace JobWay.Application.Common;

public class Result<T>
{
    private Result(T? data)
    {
        IsSuccess = true;
        Data = data;
    }

    private Result(string error, ErrorType errorType)
    {
        IsSuccess = false;
        Error = error;
        ErrorType = errorType;
    }

    public bool IsSuccess { get; }
    public T? Data { get; set; }
    public string? Error { get; }
    public ErrorType? ErrorType { get; }

    public static Result<T> Ok(T? data) => new(data);
    public static Result<T> Fail(string error, ErrorType errorType) => new(error, errorType);
}