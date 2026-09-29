using JobWay.Application.Common;
using JobWay.Application.DTOs.Auth.Request;
using JobWay.Application.DTOs.Auth.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IAuthService
{
    Task<Result<string>> SendRegistrationCodeAsync(SendRegistrationCodeRequest request, CancellationToken cancellationToken);
    Task<Result<string>> VerifyRegistrationCodeAsync(VerifyRegistrationCodeRequest request, CancellationToken cancellationToken);
    Task<Result<AuthResponse>> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken);
    Task<Result<AuthResponse>> LoginAsync(LoginRequest request, CancellationToken cancellationToken);
    Task<Result<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request, CancellationToken cancellationToken);
    Task<Result<string>> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken);
    Task<Result<string>> VerifyResetCodeAsync(VerifyResetCodeRequest request, CancellationToken cancellationToken);
    Task<Result<string>> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken);
    Task<Result<string>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken);
    Task<Result<string>> DeleteAccountAsync(Guid userId, DeleteAccountRequest request, CancellationToken cancellationToken);
}