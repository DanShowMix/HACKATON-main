import 'package:flutter/material.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  final bool isRead;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? dateTime,
    NotificationType? type,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  achievement,
  deal,
  promotion,
  system,
  level,
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _getMockNotifications();
  }

  List<Notification> _getMockNotifications() {
    final now = DateTime.now();
    return [
      Notification(
        id: '1',
        title: 'Новый уровень!',
        message: 'Осталось 38 баллов до получения Gold статуса',
        dateTime: now.subtract(const Duration(minutes: 15)),
        type: NotificationType.level,
      ),
      Notification(
        id: '2',
        title: 'Сделка одобрена',
        message: 'Кредит на 1.2 млн ₽ по заявке №4521 профинансирован',
        dateTime: now.subtract(const Duration(hours: 2)),
        type: NotificationType.deal,
      ),
      Notification(
        id: '3',
        title: 'Акция месяца',
        message: 'Двойные баллы за все автокредиты до конца марта',
        dateTime: now.subtract(const Duration(hours: 5)),
        type: NotificationType.promotion,
      ),
      Notification(
        id: '4',
        title: 'Достижение разблокировано',
        message: '«Первые 10 сделок» — получено 20 бонусных баллов',
        dateTime: now.subtract(const Duration(days: 1)),
        type: NotificationType.achievement,
      ),
      Notification(
        id: '5',
        title: 'Обновление условий',
        message: 'Изменились ставки по продукту «Автокредит»',
        dateTime: now.subtract(const Duration(days: 2)),
        type: NotificationType.system,
      ),
      Notification(
        id: '6',
        title: 'Сделка отклонена',
        message: 'Заявка №4489 отклонена банком. Причина: низкий кредитный рейтинг',
        dateTime: now.subtract(const Duration(days: 3)),
        type: NotificationType.deal,
      ),
      Notification(
        id: '7',
        title: 'Новый продукт',
        message: 'Запускаем «Рефинансирование» — помогайте клиентам экономить',
        dateTime: now.subtract(const Duration(days: 5)),
        type: NotificationType.promotion,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Отметить все как прочитанные',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearReadNotifications,
            tooltip: 'Удалить прочитанные',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(_notifications[index]);
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
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет уведомлений',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будут появляться важные события',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Notification notification) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() {
          _notifications.removeAt(
            _notifications.indexWhere((n) => n.id == notification.id),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Уведомление удалено')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: notification.isRead ? Colors.white : Colors.green.shade50,
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.dateTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.achievement:
        return Colors.orange;
      case NotificationType.deal:
        return Colors.blue;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.level:
        return Colors.green;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.deal:
        return Icons.check_circle;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.level:
        return Icons.arrow_upward;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  void _markAsRead(Notification notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Все уведомления прочитаны')),
    );
  }

  void _clearReadNotifications() {
    setState(() {
      _notifications = _notifications.where((n) => !n.isRead).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Прочитанные уведомления удалены')),
    );
  }
}
