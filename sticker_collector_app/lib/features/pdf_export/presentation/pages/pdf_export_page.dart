import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/pdf_export_state.dart';

/// PDF export page with export options
class PdfExportPage extends StatelessWidget {
  final PdfExportState state;
  final VoidCallback onExportFull;
  final VoidCallback onExportMissing;
  final VoidCallback onExportSection;
  final VoidCallback onShare;

  const PdfExportPage({
    super.key,
    required this.state,
    required this.onExportFull,
    required this.onExportMissing,
    required this.onExportSection,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Export Collection',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate a PDF of your sticker collection',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Export options
          Text(
            'Export Options',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          _buildExportButton(
            context,
            icon: Icons.list_alt,
            title: 'Full Collection',
            subtitle: 'Export all stickers',
            onTap: onExportFull,
          ),
          const SizedBox(height: 12),

          _buildExportButton(
            context,
            icon: Icons.search_off,
            title: 'Missing Only',
            subtitle: 'Export stickers you need',
            onTap: onExportMissing,
          ),
          const SizedBox(height: 12),

          _buildExportButton(
            context,
            icon: Icons.folder,
            title: 'Current Section',
            subtitle: 'Export stickers from current section',
            onTap: onExportSection,
          ),

          // Status display
          if (state.status == PdfExportStatus.generating) ...[
            const SizedBox(height: 32),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ],

          if (state.status == PdfExportStatus.ready) ...[
            const SizedBox(height: 32),
            Card(
              color: AppTheme.ownedBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppTheme.ownedColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PDF Ready!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.ownedColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share),
                      label: const Text('Share PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (state.status == PdfExportStatus.error) ...[
            const SizedBox(height: 32),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error generating PDF',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}