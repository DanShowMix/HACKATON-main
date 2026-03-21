import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int pointsReward;
  final AchievementTier tier;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final int progress;
  final int target;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.pointsReward,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedDate,
    this.progress = 0,
    required this.target,
  });
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = _getMockAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => _showStatsDialog(context, achievements),
            tooltip: 'Статистика',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          _buildSummaryCard(achievements.length, unlockedCount),
          
          // Filter tabs and list
          Expanded(
            child: _buildFilterTabs(context, achievements),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total, int unlocked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.emoji_events,
            '$unlocked',
            'Получено',
            Colors.white,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildSummaryItem(
            Icons.lock_outline,
            '${total - unlocked}',
            'В пути',
            Colors.white.withOpacity(0.8),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildSummaryItem(
            Icons.star,
            '$total',
            'Всего',
            Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context, List<Achievement> achievements) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Все'),
              Tab(text: 'Полученные'),
            ],
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAchievementsList(context, achievements),
                _buildAchievementsList(
                  context,
                  achievements.where((a) => a.isUnlocked).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Здесь пока пусто',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(context, achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
  ) {
    final tierColor = _getTierColor(achievement.tier);
    final progressPercent = (achievement.progress / achievement.target) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? tierColor.withOpacity(0.2)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: achievement.isUnlocked ? tierColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.iconEmoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: achievement.isUnlocked
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tierColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTierName(achievement.tier),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  if (!achievement.isUnlocked) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.progress} / ${achievement.target}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.pointsReward} баллов',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.orange.shade700;
      case AchievementTier.silver:
        return Colors.grey.shade700;
      case AchievementTier.gold:
        return Colors.amber.shade700;
      case AchievementTier.platinum:
        return Colors.blue.shade700;
    }
  }

  String _getTierName(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Бронза';
      case AchievementTier.silver:
        return 'Серебро';
      case AchievementTier.gold:
        return 'Золото';
      case AchievementTier.platinum:
        return 'Платина';
    }
  }

  void _showStatsDialog(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final totalPoints = unlocked.fold<int>(0, (sum, a) => sum + a.pointsReward);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ваша статистика'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Всего достижений', '${achievements.length}'),
            _buildStatRow('Получено', '${unlocked.length}'),
            _buildStatRow('В пути', '${achievements.length - unlocked.length}'),
            const Divider(),
            _buildStatRow('Бонусных баллов', '+$totalPoints'),
            const Divider(),
            _buildStatRow(
              'Процент выполнения',
              '${((unlocked.length / achievements.length) * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Achievement> _getMockAchievements() {
    return [
      Achievement(
        id: '1',
        title: 'Первые шаги',
        description: 'Совершите первую сделку',
        iconEmoji: '🎯',
        pointsReward: 10,
        tier: AchievementTier.bronze,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 30)),
        progress: 1,
        target: 1,
      ),
      Achievement(
        id: '2',
        title: 'Десяточка',
        description: 'Достигните 10 сделок',
        iconEmoji: '🏆',
        pointsReward: 20,
        tier: AchievementTier.silver,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(const Duration(days: 15)),
        progress: 10,
        target: 10,
      ),
      Achievement(
        id: '3',
        title: 'Миллионер',
        description: 'Достигните объёма 1 млн ₽',
        iconEmoji: '💰',
        pointsReward: 25,
        tier: AchievementTier.silver,
        isUnlocked: true,
        progress: 27,
        target: 1,
      ),
      Achievement(
        id: '4',
        title: 'Золотой статус',
        description: 'Достигните Gold уровня',
        iconEmoji: '👑',
        pointsReward: 50,
        tier: AchievementTier.gold,
        progress: 62,
        target: 100,
      ),
      Achievement(
        id: '5',
        title: 'Супер продавец',
        description: 'Оформите 50 сделок за месяц',
        iconEmoji: '⭐',
        pointsReward: 100,
        tier: AchievementTier.gold,
        progress: 15,
        target: 50,
      ),
      Achievement(
        id: '6',
        title: 'Легенда',
        description: 'Достигните Black уровня',
        iconEmoji: '💎',
        pointsReward: 200,
        tier: AchievementTier.platinum,
        progress: 62,
        target: 200,
      ),
    ];
  }
}
