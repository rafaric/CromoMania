// Trade feature barrel export
// Domain
export 'domain/entities/scanned_qr_data.dart';
export 'domain/entities/trade_offer.dart';
export 'domain/entities/trade_record.dart';
export 'domain/repositories/trade_repository.dart';
export 'domain/usecases/parse_qr_usecase.dart';
export 'domain/usecases/generate_trade_qr_usecase.dart';
export 'domain/usecases/calculate_trade_offer_usecase.dart';
export 'domain/usecases/execute_trade_usecase.dart';

// Data
export 'data/repositories/trade_repository_impl.dart';

// Presentation - State
export 'presentation/cubit/trade_state.dart';
export 'presentation/cubit/trade_cubit.dart';
export 'presentation/cubit/trade_scanner_state.dart';
export 'presentation/cubit/trade_scanner_cubit.dart';

// Presentation - Pages
export 'presentation/pages/trade_page.dart';
export 'presentation/pages/trade_qr_display_page.dart';
export 'presentation/pages/trade_scanner_page.dart';
export 'presentation/pages/trade_confirmation_page.dart';

// Presentation - Widgets
export 'presentation/widgets/countdown_timer_widget.dart';
export 'presentation/widgets/trade_qr_viewer.dart';
export 'presentation/widgets/trade_offer_card.dart';
export 'presentation/widgets/trade_history_list.dart';