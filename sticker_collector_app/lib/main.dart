import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth/data/firebase_auth_service.dart';
import 'auth/presentation/cubit/auth_cubit.dart';
import 'auth/presentation/cubit/auth_state.dart';
import 'auth/presentation/pages/auth_gate_page.dart';
import 'connectivity/connectivity_service.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'database/app_database.dart';
import 'firebase_options.dart';
import 'features/album/data/datasources/local/album_local_datasource.dart';
import 'features/album/data/repositories/album_repository_impl.dart';
import 'features/album/presentation/cubit/album_cubit.dart';
import 'features/album/presentation/cubit/album_state.dart';
import 'features/album/presentation/pages/album_detail_page.dart';
import 'features/album/presentation/pages/album_list_page.dart';
import 'features/album/presentation/pages/section_stickers_page.dart';
import 'features/collection/data/repositories/collection_repository_impl.dart';
import 'features/collection/presentation/cubit/collection_cubit.dart';
import 'features/collection/presentation/cubit/collection_state.dart';
import 'features/pdf_export/data/pdf_generator.dart';
import 'features/pdf_export/domain/pdf_export_service.dart';
import 'features/pdf_export/presentation/cubit/pdf_export_cubit.dart';
import 'features/pdf_export/presentation/cubit/pdf_export_state.dart';
import 'features/pdf_export/presentation/pages/pdf_export_page.dart';
import 'features/stats/presentation/cubit/stats_cubit.dart';
import 'features/stats/presentation/cubit/stats_state.dart';
import 'features/stats/presentation/pages/stats_dashboard_page.dart';
import 'features/trade/data/repositories/trade_repository_impl.dart';
import 'features/trade/presentation/cubit/trade_cubit.dart';
import 'features/trade/presentation/cubit/trade_scanner_cubit.dart';
import 'features/trade/domain/usecases/parse_qr_usecase.dart' as trade_usecases;
import 'features/trade/presentation/pages/trade_page.dart';
import 'profile/presentation/widgets/user_profile_drawer.dart';
import 'sync/data/firestore_repository.dart';
import 'sync/data/sync_queue_repository_impl.dart';
import 'sync/presentation/cubit/sync_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize database
  final database = AppDatabase();

  runApp(StickerCollectorApp(database: database));
}

class StickerCollectorApp extends StatelessWidget {
  final AppDatabase database;

  const StickerCollectorApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final authService = FirebaseAuthService();
    final firestoreRepo = FirestoreRepositoryImpl();
    final syncQueueRepo = SyncQueueRepositoryImpl(database);
    final connectivityService = ConnectivityService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
        RepositoryProvider<FirebaseAuthService>.value(value: authService),
        RepositoryProvider<FirestoreRepository>.value(value: firestoreRepo),
        RepositoryProvider<SyncQueueRepositoryImpl>.value(value: syncQueueRepo),
        RepositoryProvider<ConnectivityService>.value(
          value: connectivityService,
        ),
        RepositoryProvider<TradeRepositoryImpl>.value(
          value: TradeRepositoryImpl(database),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth cubit - handles authentication state
          BlocProvider<AuthCubit>(create: (context) => AuthCubit(authService)),
          // Sync cubit - manages cloud sync
          BlocProvider<SyncCubit>(
            create: (context) => SyncCubit(
              firestoreRepo: firestoreRepo,
              syncQueueRepo: syncQueueRepo,
            ),
          ),
          // Album cubit - manages albums
          BlocProvider<AlbumCubit>(
            create: (context) {
              final albumDataSource = AlbumLocalDataSource(database);
              final albumRepository = AlbumRepositoryImpl(albumDataSource);
              return AlbumCubit(albumRepository)..loadAlbums();
            },
          ),
          // Collection cubit - manages sticker collection
          BlocProvider<CollectionCubit>(
            create: (context) {
              final collectionRepository = CollectionRepositoryImpl(database);
              final syncCubit = context.read<SyncCubit>();
              final cubit = CollectionCubit(collectionRepository)
                ..loadCollection();
              cubit.setSyncCubit(syncCubit);
              return cubit;
            },
          ),
          // Stats cubit - calculates statistics
          BlocProvider<StatsCubit>(create: (_) => StatsCubit()),
          // PDF export cubit
          BlocProvider<PdfExportCubit>(
            create: (_) {
              final pdfGenerator = PdfGenerator();
              final pdfExportService = PdfExportService(pdfGenerator);
              return PdfExportCubit(pdfExportService);
            },
          ),
          // Trade cubit - manages QR trading
          BlocProvider<TradeCubit>(
            create: (context) {
              final tradeRepository = TradeRepositoryImpl(database);
              return TradeCubit(tradeRepository)..loadHistory();
            },
          ),
          // Trade scanner cubit - manages QR scanning
          BlocProvider<TradeScannerCubit>(
            create: (_) => TradeScannerCubit(trade_usecases.ParseQRUseCase()),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: BlocListener<AuthCubit, AuthState>(
            listener: (context, authState) {
              // When user authenticates, update CollectionCubit
              if (authState.status == AuthStateStatus.authenticated) {
                final collectionCubit = context.read<CollectionCubit>();
                collectionCubit.updateUserId();
              }
            },
            child: const AuthGate(),
          ),
        ),
      ),
    );
  }
}

/// Auth gate that shows appropriate screen based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loading while determining auth state
        if (state.status == AuthStateStatus.initial ||
            state.status == AuthStateStatus.loading) {
          return const _LoadingScreen();
        }

        // Show auth gate if not authenticated
        if (state.status == AuthStateStatus.unauthenticated ||
            state.status == AuthStateStatus.error) {
          return const AuthGatePage();
        }

        // Authenticated - show main app
        if (state.status == AuthStateStatus.authenticated) {
          // Initialize sync for the authenticated user
          context.read<SyncCubit>().initialize(state.userId ?? '');

          return const MainNavigationPage();
        }

        return const _LoadingScreen();
      },
    );
  }
}

/// Loading screen shown during auth check
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.collections_bookmark,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CromoManía 2026',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Main navigation with bottom nav bar
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CromoManía 2026'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawer: const UserProfileDrawer(),
      endDrawer: const UserProfileDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [_AlbumsTab(), _StatsTab(), _ExportTab(), TradePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Albums',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'Export',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Trade'),
        ],
      ),
    );
  }
}

/// Albums tab with navigation
class _AlbumsTab extends StatelessWidget {
  const _AlbumsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCubit, AlbumState>(
      builder: (context, state) {
        // If we're showing stickers, show the stickers page
        if (state.selectedSection != null) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              context.read<AlbumCubit>().clearSection();
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(state.selectedSection!.name),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.read<AlbumCubit>().clearSection();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      context.read<AlbumCubit>().clearAlbum();
                    },
                  ),
                ],
              ),
              body: SectionStickersPage(
                section: state.selectedSection!,
                stickers: state.currentSectionStickers,
              ),
            ),
          );
        }

        // If we're showing album detail, show the sections
        if (state.selectedAlbum != null) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              context.read<AlbumCubit>().clearAlbum();
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(state.selectedAlbum!.name),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.read<AlbumCubit>().clearAlbum();
                  },
                ),
              ),
              body: AlbumDetailPage(
                album: state.selectedAlbum!,
                sections: state.sections,
                onSectionTap: (section) {
                  context.read<AlbumCubit>().selectSection(section.id);
                },
              ),
            ),
          );
        }

        // Otherwise show the album list
        return Scaffold(
          appBar: AppBar(
            title: const Text('CromoManía 2026'),
            automaticallyImplyLeading: false,
          ),
          body: BlocBuilder<CollectionCubit, CollectionState>(
            builder: (context, collectionState) {
              // Update stats when collection changes
              context.read<StatsCubit>().updateFromCollection(
                statusMap: collectionState.statusMap,
                totalStickers: collectionState.totalStickers > 0
                    ? collectionState.totalStickers
                    : 100, // Default for MVP
              );

              if (state.status == AlbumStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == AlbumStatus.error) {
                return Center(child: Text('Error: ${state.errorMessage}'));
              }

              return AlbumListPage(
                albums: state.albums,
                onAlbumTap: (album) {
                  context.read<AlbumCubit>().selectAlbum(album.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Stats tab
class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection Stats'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          return StatsDashboardPage(stats: state);
        },
      ),
    );
  }
}

/// Export tab
class _ExportTab extends StatelessWidget {
  const _ExportTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Collection'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<PdfExportCubit, PdfExportState>(
        builder: (context, pdfState) {
          return BlocBuilder<AlbumCubit, AlbumState>(
            builder: (context, albumState) {
              return BlocBuilder<CollectionCubit, CollectionState>(
                builder: (context, collectionState) {
                  // Prepare sticker data for PDF
                  final stickers = <PdfStickerData>[];

                  // If we have stickers from selected section, use those
                  if (albumState.selectedSection != null &&
                      albumState.currentSectionStickers.isNotEmpty) {
                    for (final sticker in albumState.currentSectionStickers) {
                      stickers.add(
                        PdfStickerData(
                          id: sticker.id,
                          number: sticker.stickerNumber,
                          name: sticker.name,
                          sectionName: albumState.selectedSection!.name,
                        ),
                      );
                    }
                  }

                  return PdfExportPage(
                    state: pdfState,
                    onExportFull: () {
                      context.read<PdfExportCubit>().generatePdf(
                        albumName:
                            albumState.selectedAlbum?.name ?? 'My Collection',
                        sectionName: '',
                        stickers: stickers,
                        statusMap: collectionState.statusMap,
                        filter: ExportFilter.full,
                      );
                    },
                    onExportMissing: () {
                      context.read<PdfExportCubit>().generatePdf(
                        albumName:
                            albumState.selectedAlbum?.name ?? 'My Collection',
                        sectionName: 'Missing Stickers Only',
                        stickers: stickers,
                        statusMap: collectionState.statusMap,
                        filter: ExportFilter.missingOnly,
                      );
                    },
                    onExportSection: () {
                      if (albumState.selectedSection != null) {
                        context.read<PdfExportCubit>().generatePdf(
                          albumName:
                              albumState.selectedAlbum?.name ?? 'My Collection',
                          sectionName: albumState.selectedSection!.name,
                          stickers: stickers,
                          statusMap: collectionState.statusMap,
                          filter: ExportFilter.section,
                        );
                      }
                    },
                    onShare: () {
                      context.read<PdfExportCubit>().sharePdf();
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
