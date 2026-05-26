import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../sync/presentation/cubit/sync_cubit.dart';
import '../../../sync/presentation/cubit/sync_state.dart';
import '../../../../sync/domain/sync_status.dart';
import 'sign_out_dialog.dart';

/// User profile drawer with avatar, info, sync status, and actions
class UserProfileDrawer extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const UserProfileDrawer({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: math.min(320, MediaQuery.of(context).size.width * 0.8),
      child: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(),

            // User info section
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final user = authState.user;

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Avatar
                      _buildAvatar(
                        context,
                        user?.displayName ?? 'User',
                        user?.photoUrl,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        user?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Google account connected',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  const _SectionLabel(title: 'Collection'),
                  const SizedBox(height: 8),
                  _DrawerActionTile(
                    icon: Icons.bar_chart,
                    title: 'Collection Stats',
                    subtitle: 'See progress, missing, and repeated',
                    onTap: () => _openTab(context, 1),
                  ),
                  _DrawerActionTile(
                    icon: Icons.picture_as_pdf,
                    title: 'Export PDF',
                    subtitle: 'Generate collection exports',
                    onTap: () => _openTab(context, 2),
                  ),
                  _DrawerActionTile(
                    icon: Icons.swap_horiz,
                    title: 'Trade Stickers',
                    subtitle: 'Open QR exchange tools',
                    onTap: () => _openTab(context, 3),
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(title: 'Sync'),
                  const SizedBox(height: 8),
                  _buildSyncStatusCard(context),
                  const SizedBox(height: 10),
                  _DrawerActionTile(
                    icon: Icons.sync,
                    title: 'Sync Now',
                    subtitle: 'Retry pending cloud changes',
                    onTap: () => _syncNow(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sign out button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleSignOut(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTab(BuildContext context, int index) {
    Navigator.of(context).pop();
    onSelectTab(index);
  }

  Future<void> _syncNow(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    final userId = authState.userId;

    Navigator.of(context).pop();

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authenticated user to sync.')),
      );
      return;
    }

    await context.read<SyncCubit>().initialize(userId);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sync refresh started.')));
    }
  }

  /// Build avatar with fallback to initials
  Widget _buildAvatar(BuildContext context, String name, String? photoUrl) {
    final initials = _getInitials(name);
    final color = _getColorForName(name);

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: color,
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Get color based on name hash
  Color _getColorForName(String name) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.cyan,
      Colors.brown,
      Colors.blueGrey,
      Colors.pink,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  /// Build sync status card
  Widget _buildSyncStatusCard(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getSyncIcon(state.status),
                      color: _getSyncColor(state.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sync Status',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.displayStatus,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (state.pendingCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${state.pendingCount} items pending',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get icon for sync status
  IconData _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.cloud_queue;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.error:
        return Icons.error_outline;
    }
  }

  /// Get color for sync status
  Color _getSyncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  /// Handle sign out button press
  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await SignOutDialog.show(context);

    if (confirmed && context.mounted) {
      // Clear sync first
      context.read<SyncCubit>().clearSync();

      // Then sign out
      context.read<AuthCubit>().signOut();

      Navigator.of(context).pop();
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.grey[600],
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _DrawerActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
