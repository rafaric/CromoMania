import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../../domain/entities/album_group.dart';
import '../../domain/entities/team.dart';

/// Team list page for a selected group.
class TeamListPage extends StatelessWidget {
  final AlbumGroup group;
  final List<Team> teams;
  final ValueChanged<Team> onTeamTap;

  const TeamListPage({
    super.key,
    required this.group,
    required this.teams,
    required this.onTeamTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentBlue.withValues(alpha: 0.95),
                AppTheme.primaryColor.withValues(alpha: 0.88),
              ],
            ),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Group',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                group.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TeamMetaChip(
                    icon: Icons.groups_2,
                    label: '${group.teamCount} teams',
                  ),
                  _TeamMetaChip(
                    icon: Icons.style,
                    label: '${group.stickerCount} stickers',
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
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final owned = team.stickerIds
                      .where(
                        (stickerId) => collectionState.getCount(stickerId) > 0,
                      )
                      .length;
                  final missing = team.stickerCount - owned;
                  final progress = team.stickerCount == 0
                      ? 0.0
                      : owned / team.stickerCount;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: AppTheme.primaryDark,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        team.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StatPill(
                                  label: '$owned owned',
                                  icon: Icons.check_circle,
                                ),
                                _StatPill(
                                  label: '$missing missing',
                                  icon: Icons.search_off,
                                ),
                                _StatPill(
                                  label: '${team.stickerCount} stickers',
                                  icon: Icons.style,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: progress,
                                backgroundColor:
                                    AppTheme.missingBackgroundColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.getProgressColor(progress * 100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      onTap: () => onTeamTap(team),
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

class _TeamMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TeamMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
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

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatPill({required this.label, required this.icon});

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
