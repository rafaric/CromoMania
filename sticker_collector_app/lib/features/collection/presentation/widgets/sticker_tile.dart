import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../album/domain/entities/sticker.dart';

/// Sticker tile widget with tap/long-press state machine
class StickerTile extends StatelessWidget {
  final Sticker sticker;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const StickerTile({
    super.key,
    required this.sticker,
    required this.count,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppTheme.getStatusBackgroundColor(count),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.getStatusBorderColor(count),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sticker number and name
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sticker.stickerNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: count == 0
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sticker.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Status indicator (top-right)
              if (count > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: _buildStatusIcon(),
                ),

              // Count badge (bottom-right)
              if (count > 1)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: _buildCountBadge(),
                ),

              // Special sticker indicator (top-left)
              if (sticker.isSpecial)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (count == 1) {
      return const Icon(
        Icons.check,
        color: AppTheme.ownedColor,
        size: 16,
      );
    }
    return const Icon(
      Icons.copy,
      color: AppTheme.repeatedColor,
      size: 16,
    );
  }

  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}