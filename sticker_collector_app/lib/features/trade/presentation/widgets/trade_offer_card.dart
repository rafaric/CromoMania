import 'package:flutter/material.dart';
import '../../domain/entities/trade_offer.dart';

/// Widget for displaying trade offer details with give/receive sections
class TradeOfferCard extends StatelessWidget {
  final TradeOffer offer;

  const TradeOfferCard({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Partner info header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trade with ${offer.partnerData.partnerUid.substring(0, 8)}...',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '10 min expiry',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // You Give section
            _buildSection(
              context,
              title: 'You Give',
              icon: Icons.arrow_upward,
              color: Colors.orange,
              items: offer.youGive,
              isEmpty: offer.youGive.isEmpty,
              emptyMessage: 'No stickers to give',
            ),

            const SizedBox(height: 16),

            // You Receive section
            _buildSection(
              context,
              title: 'You Receive',
              icon: Icons.arrow_downward,
              color: Colors.green,
              items: offer.youReceive,
              isEmpty: offer.youReceive.isEmpty,
              emptyMessage: 'No stickers to receive',
            ),

            const Divider(height: 24),

            // Summary footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSummaryChip(
                  context,
                  label: 'Give ${offer.youGiveCount}',
                  icon: Icons.arrow_upward,
                  color: Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildSummaryChip(
                  context,
                  label: 'Receive ${offer.youReceiveCount}',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List items,
    required bool isEmpty,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...items.map((item) => _buildStickerTile(item)),
      ],
    );
  }

  Widget _buildStickerTile(dynamic item) {
    final name = item.stickerName ?? 'Sticker #${item.stickerId}';
    final number = item.stickerNumber ?? item.stickerId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            '#$number',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}