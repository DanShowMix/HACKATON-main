import 'package:flutter/material.dart';

/// A card widget for displaying deal information
class DealCard extends StatelessWidget {
  final String id;
  final String clientName;
  final String product;
  final String amount;
  final String status;
  final DateTime date;
  final VoidCallback? onTap;

  const DealCard({
    super.key,
    required this.id,
    required this.clientName,
    required this.product,
    required this.amount,
    required this.status,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Icon
              CircleAvatar(
                backgroundColor: _getStatusColor().withOpacity(0.1),
                child: Icon(
                  _getProductIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'одобрена':
        return Colors.green;
      case 'pending':
      case 'на рассмотрении':
        return Colors.orange;
      case 'rejected':
      case 'отклонена':
        return Colors.red;
      case 'funded':
      case 'профинансирована':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getProductIcon() {
    switch (product.toLowerCase()) {
      case 'авто':
      case 'autocredit':
      case 'автокредит':
        return Icons.directions_car;
      case 'ипотека':
      case 'mortgage':
        return Icons.home;
      case 'кредит':
      case 'loan':
      case 'потребительский':
        return Icons.attach_money;
      case 'карт':
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${date.day}.${date.month}';
    }
  }
}
