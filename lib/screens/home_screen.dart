import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  final UserModel currentUser;
  const HomeScreen({super.key, required this.currentUser});

  Color _corAleatoria(String seed) {
    final rand = Random(seed.hashCode);
    return Color.fromARGB(255, rand.nextInt(156) + 100, rand.nextInt(156) + 100, rand.nextInt(156) + 100);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profissionais'),
        backgroundColor: const Color(0xFF006C67),
      ),
      drawer: AppDrawer(currentUser: currentUser),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('usuarios').where('tipoUsuario', isEqualTo: 'Prestador').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum prestador encontrado'));
          }

          final prestadores = snapshot.data!.docs
              .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prestadores.length,
            itemBuilder: (context, index) {
              final user = prestadores[index];
              final avatarColor = _corAleatoria(user.nome);

              return Card(
                color: const Color(0xFF92C9C3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: user.fotoBase64 != null && user.fotoBase64!.isNotEmpty
                      ? CircleAvatar(radius: 28, backgroundImage: MemoryImage(base64Decode(user.fotoBase64!)))
                      : CircleAvatar(
                    radius: 28,
                    backgroundColor: avatarColor,
                    child: Text(
                      user.nome.isNotEmpty ? user.nome[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  title: Text(user.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.profissao != null) Text(user.profissao!, style: const TextStyle(color: Colors.black87)),
                      if (user.descricao != null) Text(user.descricao!, style: const TextStyle(color: Colors.black54)),
                      Text('Cidade: ${user.cidade}', style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) => Icon(i < user.avaliacao.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 20)),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
