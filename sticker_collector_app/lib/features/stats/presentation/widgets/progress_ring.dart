import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Circular progress ring widget
class ProgressRing extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 150,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 100.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.grey.shade200),
            ),
          ),

          // Progress ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clampedPercent / 100),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    AppTheme.getProgressColor(clampedPercent),
                  ),
                ),
              );
            },
          ),

          // Percentage text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${clampedPercent.round()}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}