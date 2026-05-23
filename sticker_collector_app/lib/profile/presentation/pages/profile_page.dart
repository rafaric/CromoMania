import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../sync/presentation/cubit/sync_cubit.dart';
import '../../../sync/presentation/cubit/sync_state.dart';
import '../widgets/sign_out_dialog.dart';
import '../widgets/user_profile_drawer.dart';

/// Profile page that wraps the user profile drawer
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const UserProfileDrawer(),
    );
  }
}