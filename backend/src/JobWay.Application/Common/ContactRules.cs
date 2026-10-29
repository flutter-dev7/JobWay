using System.Text.RegularExpressions;

namespace JobWay.Application.Common;

public static class ContactRules
{
    public const int MinPhoneDigits = 8;
    public const int MaxPhoneDigits = 15;

    private static readonly Regex TelegramPattern = new("^[A-Za-z][A-Za-z0-9_]{4,31}$", RegexOptions.Compiled);

    // Возвращает текст ошибки или null. Пустое значение означает «контакт не указан»
    public static string? Normalize(
        string? phone,
        string? telegram,
        out string? normalizedPhone,
        out string? normalizedTelegram)
    {
        normalizedPhone = null;
        normalizedTelegram = null;

        if (!string.IsNullOrWhiteSpace(phone))
        {
            var trimmed = phone.Trim();
            var digits = new string(trimmed.Where(char.IsDigit).ToArray());
            var onlyAllowedChars = trimmed.Skip(1).All(c => char.IsDigit(c) || c is ' ' or '-' or '(' or ')');

            if (!trimmed.StartsWith('+') || !onlyAllowedChars
                                         || digits.Length < MinPhoneDigits || digits.Length > MaxPhoneDigits)
                return "Укажите телефон в международном формате, например +992987654321";

            normalizedPhone = "+" + digits;
        }

        if (!string.IsNullOrWhiteSpace(telegram))
        {
            var username = telegram.Trim();

            foreach (var prefix in new[] { "https://t.me/", "http://t.me/", "t.me/" })
            {
                if (!username.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) continue;
                username = username[prefix.Length..];
                break;
            }

            username = username.TrimStart('@');

            if (!TelegramPattern.IsMatch(username))
                return "Telegram: от 5 до 32 символов, латинские буквы, цифры и «_», начинается с буквы";

            normalizedTelegram = username;
        }

        return null;
    }
}