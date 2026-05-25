import 'package:flutter/material.dart';
import '../../domain/entities/trade_record.dart';

/// Widget for displaying list of trade history entries
class TradeHistoryList extends StatelessWidget {
  final List<TradeRecord> history;
  final Future<void> Function()? onRefresh;

  const TradeHistoryList({
    super.key,
    required this.history,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No trades yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start trading with your friends!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final record = history[index];
          return _TradeHistoryTile(record: record);
        },
      ),
    );
  }
}

class _TradeHistoryTile extends StatelessWidget {
  final TradeRecord record;

  const _TradeHistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.swap_horiz,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        '📤 Gave ${record.stickersGiven} · Got ${record.stickersReceived}',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        record.partnerName,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        record.timeAgo,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }
}