import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';

class PerfilScreen extends StatelessWidget {
  final UserModel currentUser;
  const PerfilScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      drawer: AppDrawer(currentUser: currentUser),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${currentUser.nome}', style: TextStyle(fontSize: 18)),
            Text('Email: ${currentUser.email}', style: TextStyle(fontSize: 18)),
            Text('Telefone: ${currentUser.telefone}', style: TextStyle(fontSize: 18)),
            Text('Cidade: ${currentUser.cidade}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
