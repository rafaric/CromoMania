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
                    Text(
                      'Album / ${team.groupName} / ${team.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      team.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stickers.length} stickers to track',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              if (onExportTeam != null)
                IconButton(
                  onPressed: onExportTeam,
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  tooltip: 'Export team',
                ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<CollectionCubit, CollectionState>(
            builder: (context, state) {
              return GridView.builder(
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
              );
            },
          ),
        ),
      ],
    );
  }
}
