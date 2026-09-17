using JobWay.Application.Common;
using JobWay.Application.DTOs.Auth.Request;
using JobWay.Application.DTOs.Auth.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class AuthService : IAuthService
{
    private const string ResetCodeKeyPrefix = "password-reset-code:";
    private const string ResetVerifiedKeyPrefix = "password-reset-verified:";
    private static readonly TimeSpan ResetCodeExpiry = TimeSpan.FromMinutes(15);

    private readonly IUnitOfWork _unitOfWork;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;
    private readonly IEmailService _emailService;
    private readonly ICacheService _cacheService;

    public AuthService(
        IUnitOfWork unitOfWork,
        IPasswordHasher passwordHasher,
        IJwtService jwtService,
        IEmailService emailService,
        ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _emailService = emailService;
        _cacheService = cacheService;
    }

    public async Task<Result<AuthResponse>> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken)
    {
        if (request.Password != request.ConfirmPassword)
            return Result<AuthResponse>.Fail("Passwords do not match", ErrorType.Validation);

        if (request.Role is not (UserRole.Candidate or UserRole.Employer))
            return Result<AuthResponse>.Fail("Registration with this role is not allowed", ErrorType.Validation);

        if (request.Role == UserRole.Candidate &&
            (string.IsNullOrWhiteSpace(request.FirstName) || string.IsNullOrWhiteSpace(request.LastName)))
            return Result<AuthResponse>.Fail("First name and last name are required", ErrorType.Validation);

        if (request.Role == UserRole.Employer && string.IsNullOrWhiteSpace(request.CompanyName))
            return Result<AuthResponse>.Fail("Company name is required", ErrorType.Validation);

        var exists = await _unitOfWork.Repository<User>()
            .ExistsAsync(u => u.Email == request.Email, cancellationToken);

        if (exists)
            return Result<AuthResponse>.Fail("A user with this email already exists", ErrorType.Conflict);

        var user = new User
        {
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = request.Role
        };

        if (request.Role == UserRole.Candidate)
            user.CandidateProfile = new CandidateProfile { FullName = $"{request.FirstName} {request.LastName}".Trim() };
        else
            user.CompanyProfile = new CompanyProfile { CompanyName = request.CompanyName! };

        await _unitOfWork.AddAsync(user, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<AuthResponse>.Ok(BuildAuthResponse(user));
    }

    public async Task<Result<AuthResponse>> LoginAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Repository<User>()
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            return Result<AuthResponse>.Fail("Invalid email or password", ErrorType.Unauthorized);

        if (!user.IsActive)
            return Result<AuthResponse>.Fail("Account is blocked", ErrorType.Forbidden);

        return Result<AuthResponse>.Ok(BuildAuthResponse(user));
    }

    public async Task<Result<string>> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Repository<User>()
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        var code = Random.Shared.Next(0, 1_000_000).ToString("D6");

        await _cacheService.SetAsync(ResetCodeKeyPrefix + request.Email, code, ResetCodeExpiry, cancellationToken);
        await _cacheService.RemoveAsync(ResetVerifiedKeyPrefix + request.Email, cancellationToken);

        await _emailService.SendAsync(user.Email, "Password reset code", $"Your password reset code: {code}", cancellationToken);

        return Result<string>.Ok("Reset code sent to email");
    }

    public async Task<Result<string>> VerifyResetCodeAsync(VerifyResetCodeRequest request, CancellationToken cancellationToken)
    {
        var cachedCode = await _cacheService.GetAsync(ResetCodeKeyPrefix + request.Email, cancellationToken);

        if (cachedCode is null || cachedCode != request.Code)
            return Result<string>.Fail("Invalid or expired code", ErrorType.Validation);

        await _cacheService.SetAsync(ResetVerifiedKeyPrefix + request.Email, "true", ResetCodeExpiry, cancellationToken);

        return Result<string>.Ok("Code verified");
    }

    public async Task<Result<string>> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var verified = await _cacheService.ExistsAsync(ResetVerifiedKeyPrefix + request.Email, cancellationToken);

        if (!verified)
            return Result<string>.Fail("Reset code was not verified", ErrorType.Validation);

        var user = await _unitOfWork.Repository<User>()
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        _unitOfWork.Repository<User>().Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(ResetCodeKeyPrefix + request.Email, cancellationToken);
        await _cacheService.RemoveAsync(ResetVerifiedKeyPrefix + request.Email, cancellationToken);

        return Result<string>.Ok("Password reset successful");
    }

    public async Task<Result<string>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _unitOfWork.Repository<User>().GetByIdAsync(userId, cancellationToken);

        if (user is null)
            return Result<string>.Fail("User not found", ErrorType.NotFound);

        if (!_passwordHasher.Verify(request.OldPassword, user.PasswordHash))
            return Result<string>.Fail("Old password is incorrect", ErrorType.Validation);

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        _unitOfWork.Repository<User>().Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<string>.Ok("Password changed successfully");
    }

    private AuthResponse BuildAuthResponse(User user) => new()
    {
        UserId = user.Id,
        Role = user.Role,
        AccessToken = _jwtService.GenerateAccessToken(user),
        RefreshToken = _jwtService.GenerateRefreshToken()
    };
}