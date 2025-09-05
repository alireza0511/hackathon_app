import 'package:flutter/material.dart';

class ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForAction(title),
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForAction(String action) {
    switch (action) {
      case 'Zelle':
        return Icons.send_rounded;
      case 'Transfer':
        return Icons.swap_horiz;
      case 'Loan Access':
        return Icons.account_balance;
      case 'Check Deposit':
        return Icons.camera_alt;
      case 'Notification Alert':
        return Icons.notifications;
      case 'More':
        return Icons.more_horiz;
      case 'Profile':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}