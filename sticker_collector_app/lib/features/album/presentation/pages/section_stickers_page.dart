import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../../../collection/presentation/widgets/sticker_tile.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/sticker.dart';

/// Section stickers page with grid view
class SectionStickersPage extends StatelessWidget {
  final Section section;
  final List<Sticker> stickers;
  final VoidCallback? onExportSection;

  const SectionStickersPage({
    super.key,
    required this.section,
    required this.stickers,
    this.onExportSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryLight.withOpacity(0.1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stickers.length} stickers',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onExportSection != null)
                IconButton(
                  onPressed: onExportSection,
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export section',
                ),
            ],
          ),
        ),

        // Sticker grid
        Expanded(
          child: BlocBuilder<CollectionCubit, CollectionState>(
            builder: (context, state) {
              return GridView.builder(
                padding: const EdgeInsets.all(8),
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
                    onTap: () {
                      context.read<CollectionCubit>().incrementSticker(sticker.id);
                    },
                    onLongPress: () {
                      context.read<CollectionCubit>().decrementSticker(sticker.id);
                    },
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