import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/status_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/products_screen.dart';
import 'screens/support_screen.dart';
import 'screens/financial_effect_screen.dart';
import 'screens/monthly_tasks_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load auth state from storage
  await ApiService().loadAuthState();
  
  runApp(const DealerApp());
}

class DealerApp extends StatelessWidget {
  const DealerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дилер Партнёр',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, // Стиль Сбер
        primaryColor: Colors.green.shade700,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: ApiService().isAuthenticated
          ? const MainNavigation()
          : const LoginScreen(),
      routes: {
        '/calculator': (context) => const CalculatorScreen(),
        '/status': (context) => const StatusScreen(),
        '/rating': (context) => const RatingScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/products': (context) => const ProductsScreen(),
        '/support': (context) => const SupportScreen(),
        '/financial-effect': (context) => const FinancialEffectScreen(),
        '/monthly-tasks': (context) => const MonthlyTasksScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DealsScreen(),
    AchievementsScreen(),
    SupportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        elevation: 8,
        shadowColor: Colors.black26,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Сделки',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Достижения',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Поддержка',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

/// Screen for managing deals
class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои сделки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Фильтр',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Активные',
                    '5',
                    Colors.blue,
                    Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Одобрено',
                    '12',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Всего',
                    '15',
                    Colors.amber,
                    Icons.receipt,
                  ),
                ),
              ],
            ),
          ),
          
          // Deals list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDealItem(
                  context,
                  'Иванов Пётр',
                  'Автокредит',
                  '1 200 000 ₽',
                  'Одобрена',
                  Colors.green,
                ),
                _buildDealItem(
                  context,
                  'Смирнова Анна',
                  'Ипотека',
                  '5 500 000 ₽',
                  'На рассмотрении',
                  Colors.orange,
                ),
                _buildDealItem(
                  context,
                  'Кузнецов Алексей',
                  'Потребительский',
                  '500 000 ₽',
                  'Одобрена',
                  Colors.green,
                ),
                _buildDealItem(
                  context,
                  'Попова Мария',
                  'Рефинансирование',
                  '800 000 ₽',
                  'Отклонена',
                  Colors.red,
                ),
                _buildDealItem(
                  context,
                  'Васильев Дмитрий',
                  'Автокредит',
                  '2 100 000 ₽',
                  'Профинансирована',
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/products');
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая сделка'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
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
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealItem(
    BuildContext context,
    String client,
    String product,
    String amount,
    String status,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getProductIcon(product),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(client, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(product),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to deal details
        },
      ),
    );
  }

  IconData _getProductIcon(String product) {
    switch (product.toLowerCase()) {
      case 'автокредит':
        return Icons.directions_car;
      case 'ипотека':
        return Icons.home;
      case 'потребительский':
        return Icons.attach_money;
      case 'рефинансирование':
        return Icons.swap_horiz;
      default:
        return Icons.receipt;
    }
  }
}
