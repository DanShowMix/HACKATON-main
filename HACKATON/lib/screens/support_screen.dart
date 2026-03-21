import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages = _getMockMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: Text(
                '👤',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Поддержка',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Онлайн',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: _makeCall,
            tooltip: 'Позвонить',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptions,
            tooltip: 'Опции',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick replies
          _buildQuickReplies(),
          
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          
          // Input field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildQuickReplyChip('Как оформить сделку?'),
          _buildQuickReplyChip('Где мой бонус?'),
          _buildQuickReplyChip('Техническая проблема'),
          _buildQuickReplyChip('Связаться с менеджером'),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.green.shade700,
          ),
        ),
        backgroundColor: Colors.green.shade50,
        onPressed: () {
          _sendMessage(text);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Начните чат с поддержкой',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Мы ответим в течение 5 минут',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: const Text('👤', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isFromUser
                        ? Colors.green.shade700
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isFromUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (message.isFromUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _getStatusIcon(message.status),
                        size: 14,
                        color: message.status == MessageStatus.read
                            ? Colors.blue
                            : Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.shade100,
            child: const Text('👤', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 150),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -value * 4),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _attachFile,
              color: Colors.grey.shade600,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Сообщение...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: messageText,
        isFromUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ));
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate bot response
    _simulateResponse(messageText);
  }

  void _simulateResponse(String userMessage) {
    setState(() => _isTyping = true);

    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (!mounted) return;

      final response = _getBotResponse(userMessage);
      
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          isFromUser: false,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();
    });
  }

  String _getBotResponse(String message) {
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

  void _attachFile() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Фото из галереи'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Открытие галереи...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Открытие камеры...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Документ'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Выбор документа...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makeCall() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Звонок в поддержку'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Выберите тип звонка:'),
            SizedBox(height: 16),
            Text(
              '📞 8 800 555-35-35\n(бесплатно по России)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Набор номера...')),
              );
            },
            icon: const Icon(Icons.call),
            label: const Text('Позвонить'),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('История обращений'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Открытие истории...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Оценить поддержку'),
              onTap: () {
                Navigator.pop(context);
                _showRatingDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Частые вопросы'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Открытие FAQ...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Оцените поддержку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Как вам помощь специалиста?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          index < 4
                              ? 'Спасибо за оценку!'
                              : 'Спасибо! Мы станем лучше.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<ChatMessage> _getMockMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        text: 'Здравствуйте! Чем могу помочь?',
        isFromUser: false,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: '2',
        text: 'Как получить доступ к новым продуктам?',
        isFromUser: true,
        timestamp: now.subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        id: '3',
        text: 'Для доступа к новым продуктам необходимо:\n\n1. Пройти обучение в личном кабинете\n2. Подписать дополнительное соглашение\n3. Пройти сертификацию\n\nПосле этого продукты станут доступны в течение 24 часов.',
        isFromUser: false,
        timestamp: now.subtract(const Duration(minutes: 3)),
        status: MessageStatus.read,
      ),
    ];
  }
}
