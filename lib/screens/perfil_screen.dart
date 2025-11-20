import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prest_service/models/user_model.dart';
import 'package:prest_service/screens/edit_profile_screen.dart';
import 'package:prest_service/services/auth_service.dart';
import 'package:prest_service/services/firestore_service.dart';
import '../screens/initial_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatefulWidget {
  final UserModel currentUser;
  const PerfilScreen({super.key, required this.currentUser});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.currentUser;
  }

  Future<void> carregarUsuario() async {
    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (snap.exists) {
      setState(() {
        user = UserModel.fromMap(snap.data()!);
      });
    }

  }

  Future<void> deletarConta(BuildContext context) async {
    final auth = AuthService();
    final firestore = FirestoreService();

    await firestore.deletarUsuario(user.uid);
    await auth.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const InitialScreen()),
          (route) => false,
    );
  }

  Future<void> logout(BuildContext context) async {
    final auth = AuthService();
    await auth.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const InitialScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final foto = user.fotoBase64 != null
        ? MemoryImage(base64Decode(user.fotoBase64!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFF006C67),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: foto,
              backgroundColor: const Color(0xFF92C9C3),
              child: foto == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(user.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user.email ?? '-', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(user.telefone ?? '-', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(user.cidade ?? '-', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            if (user.tipoUsuario == "Prestador") ...[
              Text(user.profissao ?? '-', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(user.descricao ?? '-', textAlign: TextAlign.center),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user),
                    ),
                  ).then((_) {
                    carregarUsuario(); // <<< RECARREGA AO VOLTAR
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('Editar Perfil'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => logout(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C67)),
                child: const Text('Deslogar'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => deletarConta(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Excluir Conta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
