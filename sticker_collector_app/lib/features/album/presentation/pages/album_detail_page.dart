import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/album_group.dart';

/// Album detail page showing groups.
class AlbumDetailPage extends StatelessWidget {
  final Album album;
  final List<AlbumGroup> groups;
  final ValueChanged<AlbumGroup> onGroupTap;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.groups,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Official Panini Album',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                album.name,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              if (album.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  album.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoPill(
                    icon: Icons.collections,
                    label: '${album.totalStickers} stickers',
                  ),
                  _InfoPill(
                    icon: Icons.category,
                    label: '${groups.length} groups',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<CollectionCubit, CollectionState>(
            builder: (context, collectionState) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final stats = _ProgressStats.fromIds(
                    group.stickerIds,
                    collectionState,
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryLight, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.cardBorderColor),
                        ),
                        child: Center(
                          child: Text(
                            '${group.orderIndex + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _CountBadge(
                                  icon: Icons.groups_2,
                                  label: '${group.teamCount} teams',
                                ),
                                _CountBadge(
                                  icon: Icons.style,
                                  label: '${group.stickerCount} stickers',
                                ),
                                _CountBadge(
                                  icon: Icons.search_off,
                                  label: '${stats.missing} missing',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _ProgressLine(stats: stats),
                          ],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                      ),
                      onTap: () => onGroupTap(group),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CountBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentBlue),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final _ProgressStats stats;

  const _ProgressLine({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: stats.percent,
                  backgroundColor: AppTheme.missingBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.getProgressColor(stats.percent * 100),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${(stats.percent * 100).round()}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${stats.owned}/${stats.total} owned • ${stats.repeated} repeated',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProgressStats {
  final int total;
  final int owned;
  final int missing;
  final int repeated;

  const _ProgressStats({
    required this.total,
    required this.owned,
    required this.missing,
    required this.repeated,
  });

  double get percent => total == 0 ? 0 : owned / total;

  factory _ProgressStats.fromIds(
    List<int> stickerIds,
    CollectionState collectionState,
  ) {
    final total = stickerIds.length;
    var owned = 0;
    var repeated = 0;

    for (final stickerId in stickerIds) {
      final count = collectionState.getCount(stickerId);
      if (count > 0) owned++;
      if (count > 1) repeated += count - 1;
    }

    return _ProgressStats(
      total: total,
      owned: owned,
      missing: total - owned,
      repeated: repeated,
    );
  }
}
