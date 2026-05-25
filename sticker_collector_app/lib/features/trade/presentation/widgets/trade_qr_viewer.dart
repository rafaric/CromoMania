import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'countdown_timer_widget.dart';

/// Widget for displaying QR code with countdown timer
class TradeQRViewer extends StatelessWidget {
  final String payload;
  final DateTime expiresAt;

  const TradeQRViewer({
    super.key,
    required this.payload,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CountdownTimerWidget(expiresAt: expiresAt),
            const SizedBox(height: 8),
            Text(
              'Show this QR code to your friend',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}