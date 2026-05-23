import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'database/app_database.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final database = AppDatabase();
  
  runApp(StickerCollectorApp(database: database));
}

class StickerCollectorApp extends StatelessWidget {
  final AppDatabase database;

  const StickerCollectorApp({
    super.key,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final albumDataSource = AlbumLocalDataSource(database);
    final albumRepository = AlbumRepositoryImpl(albumDataSource);
    final collectionRepository = CollectionRepositoryImpl(database);
    
    // Initialize PDF service
    final pdfGenerator = PdfGenerator();
    final pdfExportService = PdfExportService(pdfGenerator);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AlbumCubit>(
          create: (_) => AlbumCubit(albumRepository)..loadAlbums(),
        ),
        BlocProvider<CollectionCubit>(
          create: (_) => CollectionCubit(collectionRepository)..loadCollection(),
        ),
        BlocProvider<StatsCubit>(
          create: (_) => StatsCubit(),
        ),
        BlocProvider<PdfExportCubit>(
          create: (_) => PdfExportCubit(pdfExportService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigationPage(),
      ),
    );
  }
}

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
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AlbumsTab(),
          _StatsTab(),
          _ExportTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Albums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'Export',
          ),
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
                return Center(
                  child: Text('Error: ${state.errorMessage}'),
                );
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
                      stickers.add(PdfStickerData(
                        id: sticker.id,
                        number: sticker.stickerNumber,
                        name: sticker.name,
                        sectionName: albumState.selectedSection!.name,
                      ));
                    }
                  }

                  return PdfExportPage(
                    state: pdfState,
                    onExportFull: () {
                      context.read<PdfExportCubit>().generatePdf(
                        albumName: albumState.selectedAlbum?.name ?? 'My Collection',
                        sectionName: '',
                        stickers: stickers,
                        statusMap: collectionState.statusMap,
                        filter: ExportFilter.full,
                      );
                    },
                    onExportMissing: () {
                      context.read<PdfExportCubit>().generatePdf(
                        albumName: albumState.selectedAlbum?.name ?? 'My Collection',
                        sectionName: 'Missing Stickers Only',
                        stickers: stickers,
                        statusMap: collectionState.statusMap,
                        filter: ExportFilter.missingOnly,
                      );
                    },
                    onExportSection: () {
                      if (albumState.selectedSection != null) {
                        context.read<PdfExportCubit>().generatePdf(
                          albumName: albumState.selectedAlbum?.name ?? 'My Collection',
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