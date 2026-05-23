import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/section.dart';
import '../widgets/section_tile.dart';

/// Album detail page showing sections
class AlbumDetailPage extends StatelessWidget {
  final Album album;
  final List<Section> sections;
  final Function(Section) onSectionTap;

  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.sections,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Album header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryLight.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (album.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  album.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.collections, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${album.totalStickers} total stickers',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Sections list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return SectionTile(
                section: section,
                onTap: () => onSectionTap(section),
              );
            },
          ),
        ),
      ],
    );
  }
}