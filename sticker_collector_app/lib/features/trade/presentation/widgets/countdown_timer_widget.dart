import 'dart:async';
import 'package:flutter/material.dart';

/// Countdown timer widget that updates every second
class CountdownTimerWidget extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback? onExpired;

  const CountdownTimerWidget({
    super.key,
    required this.expiresAt,
    this.onExpired,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final remaining = widget.expiresAt.difference(now).inSeconds;

    if (remaining <= 0 && !_expired) {
      setState(() {
        _remainingSeconds = 0;
        _expired = true;
      });
      _timer.cancel();
      widget.onExpired?.call();
    } else if (remaining > 0) {
      setState(() {
        _remainingSeconds = remaining;
      });
    }
  }

  String _formatTime(int seconds) {
    if (seconds >= 600) {
      // 10 minutes or more: MM:SS
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    } else if (seconds >= 60) {
      // 1-9 minutes: M:SS
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    } else {
      // Less than a minute: SS
      return seconds.toString().padLeft(2, '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _expired ? 'QR Expired' : 'Expires in ${_formatTime(_remainingSeconds)}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _expired ? Colors.red : Colors.grey[600],
      ),
    );
  }
}