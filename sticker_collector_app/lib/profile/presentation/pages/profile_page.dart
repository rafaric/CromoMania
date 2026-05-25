import 'package:flutter/material.dart';
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