import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final UserModel currentUser;
  const AppDrawer({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.nome),
            accountEmail: Text(currentUser.email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: currentUser.fotoBase64 != null
                  ? MemoryImage(
                Uri.parse(currentUser.fotoBase64!).data!.contentAsBytes(),
              )
                  : null,
              child: currentUser.fotoBase64 == null
                  ? Icon(Icons.person, size: 40)
                  : null,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Serviços'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/servicos', arguments: currentUser);
            },
          ),

          if (currentUser.tipoUsuario == 'profissional') ...[
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Minhas Atividades'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/atividades', arguments: currentUser);
              },
            ),
          ],

          if (currentUser.tipoUsuario == 'cliente') ...[
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Meus Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pedidos', arguments: currentUser);
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
