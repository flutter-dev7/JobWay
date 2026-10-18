namespace JobWay.Application.DTOs.Chat.Request;

public class ChatMessagesFilterRequest
{
    // Polling: только сообщения новее этого времени
    public DateTime? Since { get; set; }

    // История: сообщения старше этого времени (подгрузка вверх)
    public DateTime? Before { get; set; }

    public int PageSize { get; set; } = 30;
}