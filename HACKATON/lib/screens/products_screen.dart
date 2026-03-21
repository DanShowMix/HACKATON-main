import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double minRate;
  final double maxRate;
  final int minTerm;
  final int maxTerm;
  final double minAmount;
  final double maxAmount;
  final String iconEmoji;
  final List<String> features;
  final bool isPopular;
  final int pointsMultiplier;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.minRate,
    required this.maxRate,
    required this.minTerm,
    required this.maxTerm,
    required this.minAmount,
    required this.maxAmount,
    required this.iconEmoji,
    required this.features,
    this.isPopular = false,
    this.pointsMultiplier = 1,
  });
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'Все';
  
  final List<String> _categories = [
    'Все',
    'Автокредиты',
    'Потребительские',
    'Ипотека',
    'Рефинансирование',
    'Карты',
  ];

  @override
  Widget build(BuildContext context) {
    final products = _getMockProducts();
    final filteredProducts = _selectedCategory == 'Все'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты банка'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, products),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.green.shade200,
                    checkmarkColor: Colors.green.shade700,
                  ),
                );
              },
            ),
          ),
          
          // Products list
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Продукты не найдены',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProductDetails(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        product.iconEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (product.isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Популярный',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Key conditions
              Row(
                children: [
                  Expanded(
                    child: _buildConditionItem(
                      Icons.percent,
                      'Ставка',
                      '${product.minRate}–${product.maxRate}%',
                    ),
                  ),
                  Expanded(
                    child: _buildConditionItem(
                      Icons.calendar_today,
                      'Срок',
                      '${product.minTerm}–${product.maxTerm} мес',
                    ),
                  ),
                  Expanded(
                    child: _buildConditionItem(
                      Icons.attach_money,
                      'Сумма',
                      '${product.minAmount.toInt()}–${product.maxAmount.toInt()} млн',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Features
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: product.features.take(3).map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              
              // Points multiplier
              if (product.pointsMultiplier > 1)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Повышенные баллы: x${product.pointsMultiplier}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        product.iconEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Conditions
              const Text(
                'Условия',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildDetailRow(
                'Процентная ставка',
                '${product.minRate} – ${product.maxRate}%',
              ),
              _buildDetailRow(
                'Срок кредитования',
                '${product.minTerm} – ${product.maxTerm} месяцев',
              ),
              _buildDetailRow(
                'Сумма кредита',
                '${product.minAmount.toInt()} – ${product.maxAmount.toInt()} млн ₽',
              ),
              _buildDetailRow(
                'Баллы за сделку',
                'x${product.pointsMultiplier}',
                valueColor: Colors.green,
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Features
              const Text(
                'Преимущества',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ...product.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 24),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Заявка создана. Менеджер свяжется с вами.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Оформить заявку',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, List<Product> products) {
    showSearch(
      context: context,
      delegate: ProductSearchDelegate(products),
    );
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Автокредит',
        description: 'Кредит на покупку нового или подержанного автомобиля на выгодных условиях.',
        category: 'Автокредиты',
        minRate: 5.9,
        maxRate: 16.9,
        minTerm: 12,
        maxTerm: 84,
        minAmount: 0.1,
        maxAmount: 30,
        iconEmoji: '🚗',
        isPopular: true,
        pointsMultiplier: 2,
        features: [
          'Без первоначального взноса',
          'Без КАСКО',
          'Быстрое решение',
        ],
      ),
      Product(
        id: '2',
        name: 'Потребительский кредит',
        description: 'Кредит на любые цели без залога и поручителей.',
        category: 'Потребительские',
        minRate: 14.5,
        maxRate: 24.9,
        minTerm: 12,
        maxTerm: 60,
        minAmount: 0.05,
        maxAmount: 5,
        iconEmoji: '💳',
        pointsMultiplier: 1,
        features: [
          'Без справок о доходе',
          'Решение за 5 минут',
          'Доставка карты',
        ],
      ),
      Product(
        id: '3',
        name: 'Ипотека',
        description: 'Кредит на покупку жилья на первичном или вторичном рынке.',
        category: 'Ипотека',
        minRate: 5.3,
        maxRate: 16.5,
        minTerm: 36,
        maxTerm: 360,
        minAmount: 0.5,
        maxAmount: 50,
        iconEmoji: '🏠',
        isPopular: true,
        pointsMultiplier: 3,
        features: [
          'Господдержка',
          'Семейная ипотека',
          'Материнский капитал',
        ],
      ),
      Product(
        id: '4',
        name: 'Рефинансирование',
        description: 'Объедините кредиты из других банков в один с меньшей ставкой.',
        category: 'Рефинансирование',
        minRate: 13.5,
        maxRate: 19.9,
        minTerm: 12,
        maxTerm: 84,
        minAmount: 0.1,
        maxAmount: 10,
        iconEmoji: '🔄',
        pointsMultiplier: 1,
        features: [
          'До 5 кредитов',
          'Кэшбэк 5000 ₽',
          'Без визита в офис',
        ],
      ),
      Product(
        id: '5',
        name: 'Кредитная карта',
        description: 'Карта с льготным периодом до 120 дней и кэшбэком.',
        category: 'Карты',
        minRate: 0,
        maxRate: 39.9,
        minTerm: 0,
        maxTerm: 0,
        minAmount: 0.01,
        maxAmount: 1,
        iconEmoji: '💳',
        pointsMultiplier: 1,
        features: [
          '120 дней без %',
          'Кэшбэк до 30%',
          'Бесплатное обслуживание',
        ],
      ),
      Product(
        id: '6',
        name: 'Автокредит с господдержкой',
        description: 'Льготная ставка для семей с детьми и работников бюджетной сферы.',
        category: 'Автокредиты',
        minRate: 3.5,
        maxRate: 8.9,
        minTerm: 12,
        maxTerm: 60,
        minAmount: 0.1,
        maxAmount: 20,
        iconEmoji: '🚙',
        pointsMultiplier: 2,
        features: [
          'Льготная ставка',
          'Для семей с детьми',
          'Российское авто',
        ],
      ),
    ];
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()))
        .take(10)
        .toList();

    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
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
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(products[index].iconEmoji, style: const TextStyle(fontSize: 24)),
          title: Text(products[index].name),
          subtitle: Text(products[index].category),
          onTap: () {
            // Show details or navigate
          },
        );
      },
    );
  }
}
