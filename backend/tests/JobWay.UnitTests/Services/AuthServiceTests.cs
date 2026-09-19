using FluentAssertions;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Auth.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Application.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using Moq;
using Xunit;

namespace JobWay.UnitTests.Services;

public class AuthServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();
    private readonly Mock<IUserRepository> _userRepositoryMock = new();
    private readonly Mock<IPasswordHasher> _passwordHasherMock = new();
    private readonly Mock<IJwtService> _jwtServiceMock = new();
    private readonly Mock<IEmailService> _emailServiceMock = new();
    private readonly Mock<ICacheService> _cacheServiceMock = new();

    private readonly AuthService _sut;

    public AuthServiceTests()
    {
        _unitOfWorkMock.Setup(u => u.Users).Returns(_userRepositoryMock.Object);

        _sut = new AuthService(
            _unitOfWorkMock.Object,
            _passwordHasherMock.Object,
            _jwtServiceMock.Object,
            _emailServiceMock.Object,
            _cacheServiceMock.Object);
    }

    [Fact]
    public async Task RegisterAsync_PasswordsDoNotMatch_ReturnsValidationError()
    {
        var request = new RegisterRequest
        {
            Email = "test@test.com",
            Password = "12345678",
            ConfirmPassword = "different",
            Role = UserRole.Candidate,
            Name = "Test User"
        };

        var result = await _sut.RegisterAsync(request, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task RegisterAsync_EmailAlreadyExists_ReturnsConflict()
    {
        var request = new RegisterRequest
        {
            Email = "test@test.com",
            Password = "12345678",
            ConfirmPassword = "12345678",
            Role = UserRole.Candidate,
            Name = "Test User"
        };

        _userRepositoryMock
            .Setup(r => r.ExistsAsync(request.Email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var result = await _sut.RegisterAsync(request, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Conflict);
    }

    [Fact]
    public async Task RegisterAsync_ValidCandidateRequest_CreatesUserAndReturnsTokens()
    {
        var request = new RegisterRequest
        {
            Email = "candidate@test.com",
            Password = "12345678",
            ConfirmPassword = "12345678",
            Role = UserRole.Candidate,
            Name = "Ismoil Zaynalov"
        };

        _userRepositoryMock
            .Setup(r => r.ExistsAsync(request.Email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(false);

        _passwordHasherMock
            .Setup(h => h.Hash(request.Password))
            .Returns("hashed-password");

        _jwtServiceMock.Setup(j => j.GenerateAccessToken(It.IsAny<User>())).Returns("access-token");
        _jwtServiceMock.Setup(j => j.GenerateRefreshToken()).Returns("refresh-token");

        var result = await _sut.RegisterAsync(request, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.AccessToken.Should().Be("access-token");
        result.Data.RefreshToken.Should().Be("refresh-token");
        result.Data.Role.Should().Be(UserRole.Candidate);

        _userRepositoryMock.Verify(r => r.AddAsync(It.Is<User>(u => u.Email == request.Email), It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task LoginAsync_WrongPassword_ReturnsUnauthorized()
    {
        var user = new User { Email = "test@test.com", PasswordHash = "hashed", IsActive = true };

        _userRepositoryMock
            .Setup(r => r.GetByEmailAsync(user.Email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _passwordHasherMock
            .Setup(h => h.Verify("wrong-password", user.PasswordHash))
            .Returns(false);

        var result = await _sut.LoginAsync(new LoginRequest { Email = user.Email, Password = "wrong-password" }, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Unauthorized);
    }

    [Fact]
    public async Task LoginAsync_InactiveUser_ReturnsForbidden()
    {
        var user = new User { Email = "test@test.com", PasswordHash = "hashed", IsActive = false };

        _userRepositoryMock
            .Setup(r => r.GetByEmailAsync(user.Email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        _passwordHasherMock
            .Setup(h => h.Verify(It.IsAny<string>(), user.PasswordHash))
            .Returns(true);

        var result = await _sut.LoginAsync(new LoginRequest { Email = user.Email, Password = "correct" }, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
    }
}