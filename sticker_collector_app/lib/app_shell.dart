import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/presentation/cubit/auth_cubit.dart';
import 'auth/presentation/cubit/auth_state.dart';
import 'auth/presentation/pages/auth_gate_page.dart';
import 'sync/presentation/cubit/sync_cubit.dart';
import 'profile/presentation/widgets/user_profile_drawer.dart';

/// Main app shell with auth gate and profile drawer
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStateStatus.authenticated) {
          return _AuthenticatedShell(child: child);
        }
        return const AuthGatePage();
      },
    );
  }
}

/// Shell for authenticated users
class _AuthenticatedShell extends StatelessWidget {
  final Widget child;

  const _AuthenticatedShell({required this.child});

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
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  borderRadius: BorderRadius.circular(16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: _getColorForName(user?.displayName ?? 'User'),
                    child: Text(
                      _getInitials(user?.displayName ?? 'User'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const UserProfileDrawer(),
      body: child,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  Color _getColorForName(String name) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.cyan,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}