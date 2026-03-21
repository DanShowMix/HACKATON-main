import 'package:flutter/material.dart';

/// Reusable status badge widget for displaying employee level
class StatusBadge extends StatelessWidget {
  final String level;
  final double size;
  final bool showLabel;

  const StatusBadge({
    super.key,
    required this.level,
    this.size = 60,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getLevelIcon(),
            color: Colors.white,
            size: size * 0.4,
          ),
          if (showLabel) ...[
            const SizedBox(height: 2),
            Text(
              _getLevelShortName(),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLevelColor() {
    switch (level.toLowerCase()) {
      case 'silver':
        return Colors.grey.shade700;
      case 'gold':
        return Colors.amber.shade700;
      case 'black':
        return Colors.black87;
      case 'platinum':
        return Colors.blue.shade700;
      default:
        return Colors.blue;
    }
  }

  List<Color> _getGradientColors() {
    switch (level.toLowerCase()) {
      case 'silver':
        return [Colors.grey.shade600, Colors.grey.shade800];
      case 'gold':
        return [Colors.amber.shade400, Colors.amber.shade800];
      case 'black':
        return [Colors.grey.shade800, Colors.black];
      case 'platinum':
        return [Colors.blue.shade300, Colors.blue.shade700];
      default:
        return [Colors.blue.shade400, Colors.blue.shade700];
    }
  }

  IconData _getLevelIcon() {
    switch (level.toLowerCase()) {
      case 'silver':
        return Icons.star;
      case 'gold':
        return Icons.emoji_events;
      case 'black':
        return Icons.diamond;
      case 'platinum':
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }

  String _getLevelShortName() {
    switch (level.toLowerCase()) {
      case 'silver':
        return 'Silver';
      case 'gold':
        return 'Gold';
      case 'black':
        return 'Black';
      case 'platinum':
        return 'Platinum';
      default:
        return level;
    }
  }
}
