import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../../domain/usecases/generate_trade_qr_usecase.dart';
import '../widgets/trade_qr_viewer.dart';

/// Page for displaying user's QR code
class TradeQRDisplayPage extends StatefulWidget {
  const TradeQRDisplayPage({super.key});

  @override
  State<TradeQRDisplayPage> createState() => _TradeQRDisplayPageState();
}

class _TradeQRDisplayPageState extends State<TradeQRDisplayPage> {
  final GenerateTradeQRUseCase _generateQRUseCase = GenerateTradeQRUseCase();
  String? _qrPayload;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _generateQR();
  }

  void _generateQR() {
    final collectionState = context.read<CollectionCubit>().state;
    final userId = context.read<CollectionCubit>().currentUserId;

    // Calculate missing and repeated sticker IDs
    final statusMap = collectionState.statusMap;
    final missingIds = <int>[];
    final repeatedIds = <int>[];

    for (final entry in statusMap.entries) {
      if (entry.value == 0) {
        missingIds.add(entry.key);
      } else if (entry.value > 1) {
        repeatedIds.add(entry.key);
      }
    }

    // Generate payload (expires in 10 minutes)
    _expiresAt = DateTime.now().add(const Duration(minutes: 10));
    _qrPayload = _generateQRUseCase.execute(
      uid: userId,
      missingStickerIds: missingIds,
      repeatedStickerIds: repeatedIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate QR',
            onPressed: () {
              setState(() {
                _generateQR();
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          if (state.status == CollectionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_qrPayload == null || _expiresAt == null) {
            return const Center(child: Text('Generating QR...'));
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: TradeQRViewer(
                payload: _qrPayload!,
                expiresAt: _expiresAt!,
              ),
            ),
          );
        },
      ),
    );
  }
}