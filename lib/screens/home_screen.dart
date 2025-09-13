import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_card.dart';

class HomeScreen extends StatelessWidget {
  final UserModel currentUser;
  const HomeScreen({super.key, required this.currentUser});

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
        stream: _db.collection('usuarios')
            .where('tipoUsuario', isEqualTo: 'Prestador')
            .snapshots(),
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
              return UserCard(user: prestadores[index], onTap: () {
              });
            },
          );
        },
      ),
    );
  }
}
