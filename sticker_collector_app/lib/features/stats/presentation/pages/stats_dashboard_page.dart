import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/stats_state.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_card.dart';

/// Stats dashboard page
class StatsDashboardPage extends StatelessWidget {
  final StatsState stats;

  const StatsDashboardPage({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress ring
          const SizedBox(height: 16),
          ProgressRing(percent: stats.completionPercent),
          const SizedBox(height: 24),

          // Completion text
          Text(
            '${stats.ownedCount} / ${stats.totalStickers}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'stickers owned',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),

          // Stat cards grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Owned',
                  value: stats.ownedCount,
                  icon: Icons.check_circle,
                  color: AppTheme.ownedColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Missing',
                  value: stats.missingCount,
                  icon: Icons.help_outline,
                  color: AppTheme.missingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Repeated',
                  value: stats.repeatedCount,
                  icon: Icons.copy,
                  color: AppTheme.repeatedColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Completion',
                  value: stats.completionPercent.round(),
                  icon: Icons.percent,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Legend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to use',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(
                    context,
                    Icons.touch_app,
                    'Tap a sticker to mark as owned',
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    context,
                    Icons.touch_app,
                    'Long-press to remove',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}