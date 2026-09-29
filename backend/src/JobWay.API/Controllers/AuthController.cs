// API/Controllers/AuthController.cs — заменить целиком
using JobWay.Application.DTOs.Auth.Request;
using JobWay.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/auth")]
public class AuthController : BaseApiController
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.RegisterAsync(request, cancellationToken));

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.LoginAsync(request, cancellationToken));
    
    [AllowAnonymous]
    [HttpPost("refresh-token")]
    public async Task<IActionResult> RefreshToken(RefreshTokenRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.RefreshTokenAsync(request, cancellationToken));

    [AllowAnonymous]
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.ForgotPasswordAsync(request, cancellationToken));

    [AllowAnonymous]
    [HttpPost("verify-reset-code")]
    public async Task<IActionResult> VerifyResetCode(VerifyResetCodeRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.VerifyResetCodeAsync(request, cancellationToken));

    [AllowAnonymous]
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(ResetPasswordRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.ResetPasswordAsync(request, cancellationToken));

    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.ChangePasswordAsync(CurrentUserId, request, cancellationToken));
    
    [HttpPost("delete-account")]
    public async Task<IActionResult> DeleteAccount(DeleteAccountRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.DeleteAccountAsync(CurrentUserId, request, cancellationToken));
    
    [AllowAnonymous]
    [HttpPost("send-registration-code")]
    public async Task<IActionResult> SendRegistrationCode(SendRegistrationCodeRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.SendRegistrationCodeAsync(request, cancellationToken));

    [AllowAnonymous]
    [HttpPost("verify-registration-code")]
    public async Task<IActionResult> VerifyRegistrationCode(VerifyRegistrationCodeRequest request, CancellationToken cancellationToken)
        => HandleError(await _authService.VerifyRegistrationCodeAsync(request, cancellationToken));
}