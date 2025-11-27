import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final UserModel currentUser;

  const AppDrawer({super.key, required this.currentUser});

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoBytes = _decodeImage(currentUser.fotoBase64);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4A4A4A),
            ),
            accountName: Text(currentUser.nome),
            accountEmail: Text(currentUser.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  fotoBytes != null ? MemoryImage(fotoBytes) : null,
              child:
                  fotoBytes == null ? const Icon(Icons.person, size: 40) : null,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home', arguments: currentUser);
            },
          ),

          ListTile(
            leading: const Icon(Icons.home_repair_service),
            title: const Text('Serviços'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/servicos', arguments: currentUser);
            },
          ),

          if (currentUser.tipoUsuario.toLowerCase() == 'profissional') ...[
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Minhas Atividades'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/atividades',
                  arguments: currentUser,
                );
              },
            ),
          ],

          if (currentUser.tipoUsuario.toLowerCase() == 'cliente') ...[
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Meus Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/pedidos',
                  arguments: currentUser,
                );
              },
            ),
          ],

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Meu Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/perfil', arguments: currentUser);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await AuthService().logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
