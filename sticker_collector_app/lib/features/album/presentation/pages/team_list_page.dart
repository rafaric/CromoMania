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
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryLight.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${group.teamCount} teams • ${group.stickerCount} stickers',
                style: Theme.of(context).textTheme.bodyMedium,
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    foregroundColor: AppTheme.primaryColor,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(team.name),
                  subtitle: Text('${team.stickerCount} stickers'),
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
