import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
              Text(
                'Album / ${group.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.style,
                          size: 14,
                          color: AppTheme.accentBlue,
                        ),
                        const SizedBox(width: 6),
                        Text('${team.stickerCount} stickers'),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                  onTap: () => onTeamTap(team),
                ),
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
