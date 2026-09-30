using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.Chat.Request;

public class SendMessageRequest
{
    [Required]
    [MaxLength(2000)]
    public string Text { get; set; } = string.Empty;
}