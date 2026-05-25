import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../../../collection/presentation/widgets/sticker_tile.dart';
import '../../domain/entities/sticker.dart';
import '../../domain/entities/team.dart';

/// Team stickers page with grid view.
class TeamStickersPage extends StatelessWidget {
  final Team team;
  final List<Sticker> stickers;
  final VoidCallback? onExportTeam;

  const TeamStickersPage({
    super.key,
    required this.team,
    required this.stickers,
    this.onExportTeam,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionCubit, CollectionState>(
      builder: (context, state) {
        final owned = stickers
            .where((sticker) => state.getCount(sticker.id) > 0)
            .length;
        final missing = stickers.length - owned;
        final repeated = stickers.fold<int>(0, (sum, sticker) {
          final count = state.getCount(sticker.id);
          return count > 1 ? sum + (count - 1) : sum;
        });
        final progress = stickers.isEmpty ? 0.0 : owned / stickers.length;

        return Column(
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
              ),
              child: Row(
                children: [
                  Expanded(
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
                          child: Text(
                            team.groupName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          team.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stickers.length} stickers to track',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HeaderPill(
                              label: '$owned owned',
                              icon: Icons.check_circle,
                            ),
                            _HeaderPill(
                              label: '$missing missing',
                              icon: Icons.search_off,
                            ),
                            _HeaderPill(
                              label: '$repeated repeated',
                              icon: Icons.copy,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 9,
                            value: progress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onExportTeam != null)
                    IconButton(
                      onPressed: onExportTeam,
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                      tooltip: 'Export team',
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppConstants.defaultGridColumns,
                  childAspectRatio: AppConstants.stickerTileAspectRatio,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final sticker = stickers[index];
                  final count = state.getCount(sticker.id);

                  return StickerTile(
                    key: ValueKey(sticker.id),
                    sticker: sticker,
                    count: count,
                    onTap: () => context
                        .read<CollectionCubit>()
                        .incrementSticker(sticker.id),
                    onLongPress: () => context
                        .read<CollectionCubit>()
                        .decrementSticker(sticker.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeaderPill({required this.label, required this.icon});

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
