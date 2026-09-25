using JobWay.Application.Common;
using JobWay.Application.DTOs.Auth.Request;
using JobWay.Application.DTOs.Auth.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using Microsoft.Extensions.Options;

namespace JobWay.Application.Services;

public class AuthService : IAuthService
{
    private const string ResetCodeKeyPrefix = "password-reset-code:";
    private const string ResetVerifiedKeyPrefix = "password-reset-verified:";
    private const string RegistrationCodeKeyPrefix = "registration-code:";
    private const string RegistrationVerifiedKeyPrefix = "registration-verified:";
    private static readonly TimeSpan CodeExpiry = TimeSpan.FromMinutes(15);
    private static readonly TimeSpan RegistrationVerifiedExpiry = TimeSpan.FromMinutes(30); // хватит пройти шаги пароля/фото

    private readonly IUnitOfWork _unitOfWork;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;
    private readonly IEmailService _emailService;
    private readonly ICacheService _cacheService;
    private readonly JwtSettings _jwtSettings;

    public AuthService(
        IUnitOfWork unitOfWork,
        IPasswordHasher passwordHasher,
        IJwtService jwtService,
        IEmailService emailService,
        ICacheService cacheService,
        IOptions<JwtSettings> jwtSettings)
    {
        _unitOfWork = unitOfWork;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _emailService = emailService;
        _cacheService = cacheService;
        _jwtSettings = jwtSettings.Value;
    }

    public async Task<Result<string>> SendRegistrationCodeAsync(SendRegistrationCodeRequest request, CancellationToken cancellationToken)
    {
        if (await _unitOfWork.Users.ExistsAsync(request.Email, cancellationToken))
            return Result<string>.Fail("A user with this email already exists", ErrorType.Conflict);

        var code = Random.Shared.Next(0, 1_000_000).ToString("D6");

        await _cacheService.SetAsync(RegistrationCodeKeyPrefix + request.Email, code, CodeExpiry, cancellationToken);
        await _cacheService.RemoveAsync(RegistrationVerifiedKeyPrefix + request.Email, cancellationToken);

        await _emailService.SendAsync(request.Email, "Код подтверждения email", $"Ваш код подтверждения: {code}", cancellationToken);

        return Result<string>.Ok("Verification code sent to email");
    }

    public async Task<Result<string>> VerifyRegistrationCodeAsync(VerifyRegistrationCodeRequest request, CancellationToken cancellationToken)
    {
        var cachedCode = await _cacheService.GetAsync(RegistrationCodeKeyPrefix + request.Email, cancellationToken);

        if (cachedCode is null || cachedCode != request.Code)
            return Result<string>.Fail("Invalid or expired code", ErrorType.Validation);

        await _cacheService.SetAsync(RegistrationVerifiedKeyPrefix + request.Email, "true", RegistrationVerifiedExpiry, cancellationToken);

        return Result<string>.Ok("Email verified");
    }

    public async Task<Result<AuthResponse>> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken)
    {
        var emailVerified = await _cacheService.ExistsAsync(RegistrationVerifiedKeyPrefix + request.Email, cancellationToken);
        if (!emailVerified)
            return Result<AuthResponse>.Fail("Email is not verified", ErrorType.Validation);

        if (request.Password != request.ConfirmPassword)
            return Result<AuthResponse>.Fail("Passwords do not match", ErrorType.Validation);

        if (request.Role is not (UserRole.Candidate or UserRole.Employer))
            return Result<AuthResponse>.Fail("Registration with this role is not allowed", ErrorType.Validation);

        if (string.IsNullOrWhiteSpace(request.Name))
            return Result<AuthResponse>.Fail("Name is required", ErrorType.Validation);

        if (await _unitOfWork.Users.ExistsAsync(request.Email, cancellationToken))
            return Result<AuthResponse>.Fail("A user with this email already exists", ErrorType.Conflict);

        var user = new User
        {
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = request.Role
        };

        if (request.Role == UserRole.Candidate)
            user.CandidateProfile = new CandidateProfile { FullName = request.Name };
        else
            user.CompanyProfile = new CompanyProfile { CompanyName = request.Name };

        await _unitOfWork.Users.AddAsync(user, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(RegistrationVerifiedKeyPrefix + request.Email, cancellationToken);
        await _cacheService.RemoveAsync(RegistrationCodeKeyPrefix + request.Email, cancellationToken);

        return Result<AuthResponse>.Ok(await BuildAuthResponseAsync(user, cancellationToken));
    }

    public async Task<Result<AuthResponse>> LoginAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Users.GetByEmailAsync(request.Email, cancellationToken);

        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            return Result<AuthResponse>.Fail("Invalid email or password", ErrorType.Unauthorized);

        if (!user.IsActive)
            return Result<AuthResponse>.Fail("Account is blocked", ErrorType.Forbidden);

        return Result<AuthResponse>.Ok(await BuildAuthResponseAsync(user, cancellationToken));
    }

    public async Task<Result<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Users.GetByRefreshTokenAsync(request.RefreshToken, cancellationToken);

        if (user is null || user.RefreshTokenExpiresAt is null || user.RefreshTokenExpiresAt < DateTime.UtcNow)
            return Result<AuthResponse>.Fail("Invalid or expired refresh token", ErrorType.Unauthorized);

        if (!user.IsActive)
            return Result<AuthResponse>.Fail("Account is blocked", ErrorType.Forbidden);

        return Result<AuthResponse>.Ok(await BuildAuthResponseAsync(user, cancellationToken));
    }

    public async Task<Result<string>> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Users.GetByEmailAsync(request.Email, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        var code = Random.Shared.Next(0, 1_000_000).ToString("D6");

        await _cacheService.SetAsync(ResetCodeKeyPrefix + request.Email, code, CodeExpiry, cancellationToken);
        await _cacheService.RemoveAsync(ResetVerifiedKeyPrefix + request.Email, cancellationToken);

        await _emailService.SendAsync(user.Email, "Password reset code", $"Your password reset code: {code}", cancellationToken);

        return Result<string>.Ok("Reset code sent to email");
    }

    public async Task<Result<string>> VerifyResetCodeAsync(VerifyResetCodeRequest request, CancellationToken cancellationToken)
    {
        var cachedCode = await _cacheService.GetAsync(ResetCodeKeyPrefix + request.Email, cancellationToken);

        if (cachedCode is null || cachedCode != request.Code)
            return Result<string>.Fail("Invalid or expired code", ErrorType.Validation);

        await _cacheService.SetAsync(ResetVerifiedKeyPrefix + request.Email, "true", CodeExpiry, cancellationToken);

        return Result<string>.Ok("Code verified");
    }

    public async Task<Result<string>> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var verified = await _cacheService.ExistsAsync(ResetVerifiedKeyPrefix + request.Email, cancellationToken);

        if (!verified)
            return Result<string>.Fail("Reset code was not verified", ErrorType.Validation);

        var user = await _unitOfWork.Users.GetByEmailAsync(request.Email, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        user.RefreshToken = null;
        user.RefreshTokenExpiresAt = null;
        _unitOfWork.Users.Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(ResetCodeKeyPrefix + request.Email, cancellationToken);
        await _cacheService.RemoveAsync(ResetVerifiedKeyPrefix + request.Email, cancellationToken);

        return Result<string>.Ok("Password reset successful");
    }

    public async Task<Result<string>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Users.GetByIdAsync(userId, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        if (!_passwordHasher.Verify(request.OldPassword, user.PasswordHash))
            return Result<string>.Fail("Old password is incorrect", ErrorType.Validation);

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        _unitOfWork.Users.Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<string>.Ok("Password changed successfully");
    }

    private async Task<AuthResponse> BuildAuthResponseAsync(User user, CancellationToken cancellationToken)
    {
        var accessToken = _jwtService.GenerateAccessToken(user);
        var refreshToken = _jwtService.GenerateRefreshToken();

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiresAt = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays);

        _unitOfWork.Users.Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return new AuthResponse
        {
            UserId = user.Id,
            Role = user.Role,
            AccessToken = accessToken,
            RefreshToken = refreshToken
        };
    }
}