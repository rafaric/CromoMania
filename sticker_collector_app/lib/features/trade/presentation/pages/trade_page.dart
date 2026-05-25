import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../album/presentation/cubit/album_cubit.dart';
import '../../../album/presentation/cubit/album_state.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../cubit/trade_cubit.dart';
import '../cubit/trade_state.dart';
import '../widgets/trade_history_list.dart';
import 'trade_qr_display_page.dart';
import 'trade_scanner_page.dart';

/// Main trade page with sticker lists, QR display, scanner, and history
class TradePage extends StatelessWidget {
  const TradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<TradeCubit, TradeState>(
        builder: (context, tradeState) {
          return BlocBuilder<AlbumCubit, AlbumState>(
            builder: (context, albumState) {
              return BlocBuilder<CollectionCubit, CollectionState>(
                builder: (context, collectionState) {
                  // Get all sticker IDs from album and owned sticker IDs
                  final allStickerIds = albumState.allStickers
                      .map((s) => s.id)
                      .toSet();
                  final statusMap = collectionState.statusMap ?? {};
                  final ownedStickerIds = statusMap.keys.toSet();

                  // Missing = all stickers - owned stickers
                  final missingStickers =
                      allStickerIds.difference(ownedStickerIds).toList()
                        ..sort();

                  // Repeated = owned stickers with count > 1
                  final repeatedStickers =
                      statusMap.entries
                          .where((e) => e.value > 1)
                          .map((e) => e.key)
                          .toList()
                        ..sort();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Missing stickers section
                        _buildStickerListSection(
                          context,
                          title: 'Missing Stickers',
                          count: missingStickers.length,
                          icon: Icons.check_box_outline_blank,
                          color: Colors.red,
                          stickers: missingStickers,
                        ),
                        const SizedBox(height: 16),

                        // Repeated stickers section
                        _buildStickerListSection(
                          context,
                          title: 'Repeated Stickers',
                          count: repeatedStickers.length,
                          icon: Icons.copy,
                          color: Colors.orange,
                          stickers: repeatedStickers,
                        ),
                        const SizedBox(height: 24),

                        // Action buttons
                        ElevatedButton.icon(
                          onPressed: () => _navigateToQRDisplay(context),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Generate My QR Code'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () => _navigateToScanner(context),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan Friend\'s QR'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Trade history
                        Row(
                          children: [
                            const Icon(Icons.history, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Trade History',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildHistoryContent(context, tradeState),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStickerListSection(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required List<int> stickers,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (stickers.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No stickers in this category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stickers.take(20).map((id) {
                  return Chip(
                    label: Text('#$id', style: const TextStyle(fontSize: 12)),
                    backgroundColor: color.withAlpha(25),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              if (stickers.length > 20) ...[
                const SizedBox(height: 8),
                Text(
                  '+ ${stickers.length - 20} more...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, TradeState state) {
    if (state.status == TradeStateStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == TradeStateStatus.error) {
      return Center(
        child: Column(
          children: [
            Text(state.errorMessage ?? 'An error occurred'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<TradeCubit>().loadHistory(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TradeHistoryList(
      history: state.history,
      onRefresh: () => context.read<TradeCubit>().refreshHistory(),
    );
  }

  void _navigateToQRDisplay(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TradeQRDisplayPage()));
  }

  void _navigateToScanner(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TradeScannerPage()));
  }
}
