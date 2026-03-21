import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

const _uuid = Uuid();

/// Chat/Support handler
class ChatHandler {
  static final ChatMessageRepository _repo = ChatMessageRepository();

  /// Get chat history for current employee
  static Future<Response> history(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final messages = await _repo.getByEmployeeId(userId);
      return ok(messages.map((m) => m.toJson()).toList());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Send a message
  static Future<Response> send(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      if (body == null || body['text'] == null) {
        return badRequest('Message text is required');
      }

      final text = body['text'] as String;

      // Save user message
      final userMessage = ChatMessage(
        id: 'msg-${_uuid.v4()}',
        employeeId: userId,
        text: text,
        isFromUser: true,
      );
      await _repo.create(userMessage);

      // Generate bot response
      final botResponse = _getBotResponse(text);
      final botMessage = ChatMessage(
        id: 'msg-${_uuid.v4()}',
        employeeId: userId,
        text: botResponse,
        isFromUser: false,
        status: 'delivered',
      );
      await _repo.create(botMessage);

      return ok({
        'userMessage': userMessage.toJson(),
        'botResponse': botMessage.toJson(),
      });
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Get bot response based on user message
  static String _getBotResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('оформить') || lowerMessage.contains('сделк')) {
      return 'Для оформления сделки:\n\n1. Заполните заявку в разделе "Продукты"\n2. Приложите документы клиента\n3. Ожидайте решение банка (5-10 минут)\n\nНужна помощь с конкретным шагом?';
    }

    if (lowerMessage.contains('бонус') || lowerMessage.contains('балл')) {
      return 'Баллы начисляются в течение 24 часов после профинансированной сделки. Проверить баланс можно в разделе "Рейтинг".\n\nЕсли баллы не начислены более 48 часов — напишите номер заявки.';
    }

    if (lowerMessage.contains('проблем') || lowerMessage.contains('ошибк')) {
      return 'Опишите подробнее, какая проблема возникла?\n\n• Не получается оформить заявку?\n• Не отображаются баллы?\n• Ошибка при загрузке документов?\n• Другое';
    }

    if (lowerMessage.contains('менеджер') || lowerMessage.contains('связаться')) {
      return 'Соединяю с персональным менеджером...\n\nОжидайте, специалист ответит в течение 2-3 минут.\n\nВаш менеджер: Алексей Петров\nГрафик: Пн-Пт 9:00-18:00';
    }

    if (lowerMessage.contains('спасибо')) {
      return 'Всегда рады помочь! 😊\n\nОбращайтесь, если возникнут вопросы. Хорошего дня!';
    }

    return 'Спасибо за обращение! Ваш вопрос важен для нас.\n\nСпециалист поддержки ответит вам в течение 5 минут.\n\nНомер обращения: #${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
