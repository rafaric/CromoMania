import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../collection/presentation/cubit/collection_cubit.dart';
import '../../../collection/presentation/cubit/collection_state.dart';
import '../../domain/entities/scanned_qr_data.dart';
import '../../domain/entities/trade_offer.dart';
import '../../domain/repositories/trade_repository.dart';
import '../../domain/usecases/calculate_trade_offer_usecase.dart';
import '../../domain/usecases/execute_trade_usecase.dart';
import '../widgets/trade_offer_card.dart';

/// Page for confirming a trade after scanning QR
class TradeConfirmationPage extends StatefulWidget {
  final ScannedQRData scannedData;

  const TradeConfirmationPage({
    super.key,
    required this.scannedData,
  });

  @override
  State<TradeConfirmationPage> createState() => _TradeConfirmationPageState();
}

class _TradeConfirmationPageState extends State<TradeConfirmationPage> {
  final CalculateTradeOfferUseCase _calculateUseCase = CalculateTradeOfferUseCase();
  TradeOffer? _offer;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _calculateOffer();
  }

  void _calculateOffer() {
    final collectionState = context.read<CollectionCubit>().state;
    
    _offer = _calculateUseCase.execute(
      partnerData: widget.scannedData,
      myStatusMap: collectionState.statusMap,
    );
    
    setState(() {});
  }

  Future<void> _executeTrade() async {
    if (_offer == null) return;
    
    setState(() {
      _isExecuting = true;
    });

    try {
      final tradeRepository = context.read<TradeRepository>();
      final collectionCubit = context.read<CollectionCubit>();
      
      final executeUseCase = ExecuteTradeUseCase(
        tradeRepository: tradeRepository,
        onUpdateSticker: (stickerId, delta) async {
          if (delta > 0) {
            collectionCubit.incrementSticker(stickerId);
          } else {
            collectionCubit.decrementSticker(stickerId);
          }
        },
        getStickerCount: (stickerId) {
          return collectionCubit.state.getCount(stickerId);
        },
      );

      final result = await executeUseCase.execute(
        offer: _offer!,
        partnerName: 'Partner', // TODO: Get actual partner name
      );

      if (mounted) {
        setState(() {
          _isExecuting = false;
        });

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trade completed!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Trade failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExecuting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trade failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Trade'),
      ),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          if (_offer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Check if there's any exchange possible
                      if (!_offer!.hasExchange) ...[
                        const Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No stickers to trade',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'There are no stickers that you both want to exchange.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ] else ...[
                        TradeOfferCard(offer: _offer!),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom action buttons
              if (_offer!.hasExchange)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isExecuting ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isExecuting ? null : _executeTrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isExecuting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Confirm Trade'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}