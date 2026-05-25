import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/section.dart';

/// Section tile widget for album sections
class SectionTile extends StatelessWidget {
  final Section section;
  final VoidCallback onTap;
  final int? stickerCount;

  const SectionTile({
    super.key,
    required this.section,
    required this.onTap,
    this.stickerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${section.orderIndex + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        title: Text(
          section.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: stickerCount != null
            ? Text(
                '$stickerCount stickers',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.grid_view,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}