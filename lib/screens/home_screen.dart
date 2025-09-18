import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_card.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  final UserModel currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  HomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profissionais'), backgroundColor: const Color(0xFF006C67)),
      drawer: AppDrawer(currentUser: currentUser),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios')
            .where('tipoUsuario', isEqualTo: 'Prestador')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final prestadores = snapshot.data!.docs
              .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          if (prestadores.isEmpty) return const Center(child: Text('Nenhum prestador encontrado'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prestadores.length,
            itemBuilder: (context, index) => UserCard(user: prestadores[index]),
          );
        },
      ),
    );
  }
}
