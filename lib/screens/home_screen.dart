import 'package:flutter/material.dart';
import 'package:prest_service/services/auth_service.dart';
import 'initial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF006C67),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const InitialScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Bem-vindo à Home!', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
