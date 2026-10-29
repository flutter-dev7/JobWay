using FluentAssertions;
using JobWay.Application.Common;
using Xunit;

namespace JobWay.UnitTests.Services;

public class ContactRulesTests
{
    [Theory]
    [InlineData("+992 98 765-43-21", "+992987654321")]
    [InlineData("+992(98)7654321", "+992987654321")]
    [InlineData("  +79991234567 ", "+79991234567")]
    public void Normalize_ValidPhone_ReturnsDigitsWithPlus(string input, string expected)
    {
        var error = ContactRules.Normalize(input, null, out var phone, out _);

        error.Should().BeNull();
        phone.Should().Be(expected);
    }

    [Theory]
    [InlineData("987654321")]
    [InlineData("+99")]
    [InlineData("+9929876543210000")]
    [InlineData("+992abc987654")]
    public void Normalize_InvalidPhone_ReturnsError(string input)
    {
        var error = ContactRules.Normalize(input, null, out var phone, out _);

        error.Should().NotBeNull();
        phone.Should().BeNull();
    }

    [Theory]
    [InlineData("@ismoilflutter", "ismoilflutter")]
    [InlineData("https://t.me/ismoilflutter", "ismoilflutter")]
    [InlineData("t.me/Ismoil_Dev", "Ismoil_Dev")]
    [InlineData("ismoilflutter", "ismoilflutter")]
    public void Normalize_ValidTelegram_ReturnsBareUsername(string input, string expected)
    {
        var error = ContactRules.Normalize(null, input, out _, out var telegram);

        error.Should().BeNull();
        telegram.Should().Be(expected);
    }

    [Theory]
    [InlineData("abc")]
    [InlineData("1abcde")]
    [InlineData("user name")]
    [InlineData("a-b-c-d-e")]
    [InlineData("abcdefghijklmnopqrstuvwxyz1234567")]
    public void Normalize_InvalidTelegram_ReturnsError(string input)
    {
        var error = ContactRules.Normalize(null, input, out _, out var telegram);

        error.Should().NotBeNull();
        telegram.Should().BeNull();
    }

    [Theory]
    [InlineData(null, null)]
    [InlineData("", "  ")]
    public void Normalize_EmptyValues_AreTreatedAsNoContacts(string? phone, string? telegram)
    {
        var error = ContactRules.Normalize(phone, telegram, out var normalizedPhone, out var normalizedTelegram);

        error.Should().BeNull();
        normalizedPhone.Should().BeNull();
        normalizedTelegram.Should().BeNull();
    }
}