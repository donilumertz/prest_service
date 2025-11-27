import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_card.dart';

class HomeScreen extends StatefulWidget {
  final UserModel currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = FirebaseFirestore.instance;
  List<UserModel> prestadores = [];

  @override
  void initState() {
    super.initState();
    carregarPrestadoresComMedia();
  }

  Future<void> carregarPrestadoresComMedia() async {
    final snap = await db
        .collection('usuarios')
        .where('tipoUsuario', isEqualTo: 'Prestador')
        .get();

    List<UserModel> lista = [];

    for (var doc in snap.docs) {
      final user = UserModel.fromMap(doc.data());

      if (user.uid == widget.currentUser.uid) continue;

      final avalSnap = await db
          .collection('avaliacoes')
          .where('uidProfissional', isEqualTo: user.uid)
          .get();

      double media = 0;

      if (avalSnap.docs.isNotEmpty) {
        double soma = 0;
        for (var d in avalSnap.docs) {
          soma += (d['nota'] as num).toDouble();
        }
        media = soma / avalSnap.docs.length;
      }

      lista.add(user.copyWith(avaliacao: media));
    }

    setState(() => prestadores = lista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profissionais'),
        backgroundColor: Color(0xFF4A4A4A),
      ),
      drawer: AppDrawer(currentUser: widget.currentUser),
      body: prestadores.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prestadores.length,
        itemBuilder: (context, index) => UserCard(
          user: prestadores[index],
          uidUsuarioAtual: widget.currentUser.uid,
        ),
      ),
    );
  }
}
